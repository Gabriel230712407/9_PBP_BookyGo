<?php

namespace App\Http\Controllers;

use App\Models\Ulasan;
use App\Models\Kamar;
use App\Models\Hotel;
use App\Models\UlasanHelpful;
use Illuminate\Http\Request;

class UlasanController extends Controller
{
    public function index(Request $request)
    {
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
            'kamar_id' => 'required|exists:kamars,id',
            'user_id' => 'required|exists:users,id',
            'hotel_id' => 'required|exists:hotels,id',
            'rating' => 'required|numeric|min:1|max:5',
            'komentar' => 'nullable|string',
            'photos.*' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
        ]);

        $photoPaths = [];

        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoPaths[] = $photo->store('reviews', 'public');
            }
        }

        $ulasan = Ulasan::create([
            'pemesanan_id' => $validated['pemesanan_id'],
            'kamar_id' => $validated['kamar_id'],
            'user_id' => $validated['user_id'],
            'hotel_id' => $validated['hotel_id'],
            'rating' => $validated['rating'],
            'komentar' => $validated['komentar'] ?? null,
            'photos' => $photoPaths,
        ]);
        $this->updateJumlahUlasanKamar($validated['kamar_id']);
        $this->updateRatingHotel($validated['hotel_id']);

        return response()->json([
            'message' => 'Ulasan berhasil disimpan',
            'data' => $ulasan,
        ], 201);
    }

    public function update(Request $request, Ulasan $ulasan)
    {
        $validated = $request->validate([
            'pemesanan_id' => 'required|exists:pemesanans,id|unique:ulasans,pemesanan_id,' . $ulasan->id,
            'kamar_id' => 'required|exists:kamars,id',
            'user_id' => 'required|exists:users,id',
            'hotel_id' => 'required|exists:hotels,id',
            'rating' => 'required|numeric|min:1|max:5',
            'komentar' => 'nullable|string',
            'photos.*' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'existing_photos' => 'nullable|string',
        ]);

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
            'kamar_id' => $validated['kamar_id'],
            'user_id' => $validated['user_id'],
            'hotel_id' => $validated['hotel_id'],
            'rating' => $validated['rating'],
            'komentar' => $validated['komentar'] ?? null,
            'photos' => $photoPaths,
        ]);

        $this->updateJumlahUlasanKamar($validated['kamar_id']);
        $this->updateRatingHotel($validated['hotel_id']);

        return response()->json([
            'message' => 'Ulasan berhasil diupdate',
            'data' => $ulasan->fresh(),
        ]);
    }

    public function destroy($id)
    {
        $ulasan = Ulasan::find($id);

        if (!$ulasan) {
            return response()->json([
                'status' => false,
                'message' => 'Ulasan tidak ditemukan'
            ], 404);
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
    $request->validate([
        'user_id' => 'required|exists:users,id',
    ]);

    $helpful = UlasanHelpful::where('ulasan_id', $ulasan->id)
        ->where('user_id', $request->user_id)
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
        'user_id' => $request->user_id,
    ]);

    return response()->json([
        'status' => true,
        'message' => 'Review ditandai helpful',
        'is_helpful' => true,
        'helpful_count' => $ulasan->helpfuls()->count(),
    ]);
}
}