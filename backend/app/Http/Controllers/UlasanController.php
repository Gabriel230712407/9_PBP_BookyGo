<?php

namespace App\Http\Controllers;

use App\Models\Ulasan;
use App\Models\Kamar;
use App\Models\Hotel;
use App\Models\Notification;
use App\Models\Pemesanan;
use App\Models\UlasanHelpful;
use Illuminate\Http\Request;

class UlasanController extends Controller
{
    private const REVIEW_NOTIFICATION_TYPES = ['review', 'review_reminder'];

    private function deleteReviewNotifications(int $userId, int $pemesananId): void
    {
        Notification::where('user_id', $userId)
            ->whereIn('type', self::REVIEW_NOTIFICATION_TYPES)
            ->get()
            ->filter(function ($notification) use ($pemesananId) {
                return (int) ($notification->data['pemesanan_id'] ?? 0) === $pemesananId;
            })
            ->each
            ->delete();
    }

    private function reviewableBooking(Request $request, int $pemesananId): array
    {
        $pemesanan = Pemesanan::with('kamar.hotel')->find($pemesananId);

        if (!$pemesanan) {
            return [null, response()->json([
                'status' => false,
                'message' => 'Booking not found',
            ], 404)];
        }

        if ((int) $pemesanan->user_id !== (int) $request->user()->id) {
            return [null, response()->json([
                'status' => false,
                'message' => 'You can only review your own booking',
            ], 403)];
        }

        if (!in_array($pemesanan->status_pesan, ['confirmed', 'completed'], true)) {
            return [null, response()->json([
                'status' => false,
                'message' => 'Only paid or completed bookings can be reviewed',
            ], 422)];
        }

        if (!$pemesanan->kamar || !$pemesanan->kamar->hotel) {
            return [null, response()->json([
                'status' => false,
                'message' => 'Booking room or hotel data is invalid',
            ], 422)];
        }

        return [$pemesanan, null];
    }

    private function ensureReviewOwner(Request $request, Ulasan $ulasan)
    {
        if ((int) $ulasan->user_id !== (int) $request->user()->id) {
            return response()->json([
                'status' => false,
                'message' => 'You can only manage your own review',
            ], 403);
        }

        return null;
    }

    public function index(Request $request)
    {
        $userId = optional($request->user())->id;
        $query = Ulasan::with(['pemesanan', 'user', 'kamar', 'hotel'])
            ->withCount('helpfuls')
            ->latest();

        if ($request->filled('hotel_id')) {
            $query->where('hotel_id', $request->hotel_id);
        }

        if ($request->filled('kamar_id')) {
            $query->where('kamar_id', $request->kamar_id);
        }

        $ulasans = $query->get();

        $ulasans->transform(function($ulasan) use ($userId) {
            $ulasan->isHelpful = $userId
                ? $ulasan->helpfuls()->where('user_id', $userId)->exists()
                : false; // default false kalau user belum login
            return $ulasan;
        });

        return response()->json([
            'status' => true,
            'message' => 'Data ulasan berhasil diambil',
            'summary' => [
                'average_rating' => round($ulasans->avg('rating') ?? 0, 1),
                'total_review' => $ulasans->count(),
            ],
            'data' => $ulasans
        ]);
    }

    public function show($id)
    {
        $ulasan = Ulasan::with(['pemesanan', 'user', 'kamar', 'hotel'])
            ->find($id);

        if (!$ulasan) {
            return response()->json([
                'status' => false,
                'message' => 'Ulasan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail ulasan berhasil diambil',
            'data' => $ulasan
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'pemesanan_id' => 'required|exists:pemesanans,id|unique:ulasans,pemesanan_id',
            'rating' => 'required|numeric|min:1|max:5',
            'komentar' => 'nullable|string',
            'photos.*' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        [$pemesanan, $errorResponse] = $this->reviewableBooking(
            $request,
            (int) $validated['pemesanan_id']
        );

        if ($errorResponse) {
            return $errorResponse;
        }

        $photoPaths = [];

        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = $photo->store('reviews', 'public');
            }
        }

        $ulasan = Ulasan::create([
            'pemesanan_id' => $validated['pemesanan_id'],
            'kamar_id' => $pemesanan->kamar_id,
            'user_id' => $request->user()->id,
            'hotel_id' => $pemesanan->kamar->hotel_id,
            'rating' => $validated['rating'],
            'komentar' => $validated['komentar'] ?? null,
            'photos' => $photoPaths,
        ]);
        $this->updateJumlahUlasanKamar($pemesanan->kamar_id);
        $this->updateRatingHotel($pemesanan->kamar->hotel_id);
        $this->deleteReviewNotifications(
            (int) $request->user()->id,
            (int) $validated['pemesanan_id']
        );

        return response()->json([
            'message' => 'Ulasan berhasil disimpan',
            'data' => $ulasan,
        ], 201);
    }

    public function update(Request $request, Ulasan $ulasan)
    {
        if ($errorResponse = $this->ensureReviewOwner($request, $ulasan)) {
            return $errorResponse;
        }

        $validated = $request->validate([
            'pemesanan_id' => 'required|exists:pemesanans,id|unique:ulasans,pemesanan_id,' . $ulasan->id,
            'rating' => 'required|numeric|min:1|max:5',
            'komentar' => 'nullable|string',
            'photos.*' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'existing_photos' => 'nullable|string',
        ]);

        [$pemesanan, $errorResponse] = $this->reviewableBooking(
            $request,
            (int) $validated['pemesanan_id']
        );

        if ($errorResponse) {
            return $errorResponse;
        }

        $photoPaths = [];

        if ($request->filled('existing_photos')) {
            $decodedExistingPhotos = json_decode($request->existing_photos, true);

            if (is_array($decodedExistingPhotos)) {
                $photoPaths = $decodedExistingPhotos;
            }
        } else {
            $photoPaths = $ulasan->photos ?? [];
        }

        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = $photo->store('reviews', 'public');
            }
        }

        $ulasan->update([
            'pemesanan_id' => $validated['pemesanan_id'],
            'kamar_id' => $pemesanan->kamar_id,
            'user_id' => $request->user()->id,
            'hotel_id' => $pemesanan->kamar->hotel_id,
            'rating' => $validated['rating'],
            'komentar' => $validated['komentar'] ?? null,
            'photos' => $photoPaths,
        ]);

        $this->updateJumlahUlasanKamar($pemesanan->kamar_id);
        $this->updateRatingHotel($pemesanan->kamar->hotel_id);
        $this->deleteReviewNotifications(
            (int) $request->user()->id,
            (int) $validated['pemesanan_id']
        );

        return response()->json([
            'message' => 'Ulasan berhasil diupdate',
            'data' => $ulasan->fresh(),
        ]);
    }

    public function destroy(Request $request, Ulasan $ulasan)
    {
        if ($errorResponse = $this->ensureReviewOwner($request, $ulasan)) {
            return $errorResponse;
        }

        $hotelId = $ulasan->hotel_id;
        $kamarId = $ulasan->kamar_id;

        $ulasan->delete();

        $this->updateRatingHotel($hotelId);
        $this->updateJumlahUlasanKamar($kamarId);

        return response()->json([
            'status' => true,
            'message' => 'Ulasan berhasil dihapus'
        ]);
    }

    private function updateRatingHotel($hotelId)
    {
        $hotel = Hotel::find($hotelId);

        if ($hotel) {
            $hotel->update([
                'total_rating' => Ulasan::where('hotel_id', $hotelId)->avg('rating') ?? 0
            ]);
        }
    }

    private function updateJumlahUlasanKamar($kamarId)
    {
        $kamar = Kamar::find($kamarId);

        if ($kamar) {
            $kamar->update([
                'jumlah_ulasan' => Ulasan::where('kamar_id', $kamarId)->count()
            ]);
        }
    }
    
    public function toggleHelpful(Request $request, Ulasan $ulasan)
    {
        $userId = $request->user()->id;

        $helpful = UlasanHelpful::where('ulasan_id', $ulasan->id)
            ->where('user_id', $userId)
            ->first();

        if ($helpful) {
            $helpful->delete();
            return response()->json([
                'status' => true,
                'message' => 'Helpful dibatalkan',
                'is_helpful' => false,
                'helpful_count' => $ulasan->helpfuls()->count(),
            ]);
        }

        UlasanHelpful::create([
            'ulasan_id' => $ulasan->id,
            'user_id' => $userId,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Review ditandai helpful',
            'is_helpful' => true,
            'helpful_count' => $ulasan->helpfuls()->count(),
        ]);
    }
}
