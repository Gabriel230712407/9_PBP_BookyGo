<?php

namespace App\Http\Controllers;

use App\Helpers\FcmHelper;
use App\Models\Notification;
use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PemesananController extends Controller
{
    public function index(Request $request)
    {
        $pemesanans = Pemesanan::with(['user', 'kamar.hotel.fotoHotels', 'kamar.fotoKamars', 'addons', 'ulasan'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'status'  => true,
            'message' => 'Data pemesanan berhasil diambil',
            'data'    => $pemesanans,
        ]);
    }

    public function show(Request $request, $id)
    {
        $pemesanan = Pemesanan::with(['user', 'kamar.hotel.fotoHotels', 'kamar.fotoKamars', 'addons', 'ulasan'])
            ->find($id);

        if (!$pemesanan) {
            return response()->json(['status' => false, 'message' => 'Pemesanan tidak ditemukan'], 404);
        }

        if ((int) $pemesanan->user_id !== (int) $request->user()->id) {
            return response()->json(['status' => false, 'message' => 'Anda tidak memiliki akses ke pemesanan ini'], 403);
        }

        return response()->json([
            'status'  => true,
            'message' => 'Detail pemesanan berhasil diambil',
            'data'    => $pemesanan,
        ]);
    }

    public function myBookings(Request $request)
    {
        $user = $request->user();

        $pemesanans = Pemesanan::with(['user', 'kamar.hotel.fotoHotels', 'kamar.fotoKamars', 'addons', 'ulasan'])
            ->where('user_id', $user->id)
            ->latest()
            ->get();

        return response()->json([
            'status'  => true,
            'message' => 'Data pemesanan user berhasil diambil',
            'data'    => $pemesanans,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'kamar_id'     => 'required|exists:kamars,id',
            'tgl_checkin'  => 'required|date',
            'tgl_checkout' => 'required|date|after:tgl_checkin',
            'room_count'   => 'nullable|integer|min:1',
            'guest_count'  => 'nullable|integer|min:1',
            'status_pesan' => 'nullable|string|max:255',
            'metode_bayar' => 'nullable|string|max:255',
            'kode_booking' => 'nullable|string|max:255|unique:pemesanans,kode_booking',
            'nama'         => 'required|string|max:255',
            'email'        => 'required|email|max:255',
            'no_telp'      => 'required|string|max:255',
            'addon_ids'    => 'nullable|array',
            'addon_ids.*'  => 'exists:addons,id',
        ]);

        $user = $request->user();

        $pemesanan = Pemesanan::create([
            'user_id'      => $user->id,
            'kamar_id'     => $request->kamar_id,
            'tgl_checkin'  => $request->tgl_checkin,
            'tgl_checkout' => $request->tgl_checkout,
            'room_count'   => $request->room_count ?? 1,
            'guest_count'  => $request->guest_count ?? 1,
            'status_pesan' => $request->status_pesan ?? 'pending',
            'metode_bayar' => $request->metode_bayar,
            'kode_booking' => $request->kode_booking ?? 'BK-' . strtoupper(Str::random(8)),
            'nama'         => $request->nama,
            'email'        => $request->email,
            'no_telp'      => $request->no_telp,
        ]);

        if ($request->has('addon_ids')) {
            $syncData = [];
            foreach ($request->addon_ids as $addonId) {
                $syncData[$addonId] = ['user_id' => $user->id];
            }
            $pemesanan->addons()->sync($syncData);
        }

        $pemesanan->load(['kamar.hotel', 'addons']);
        $hotelNama = $pemesanan->kamar->hotel->nama ?? 'hotel';

        Notification::create([
            'user_id' => $user->id,
            'type'    => 'booking',
            'title'   => 'Booking Confirmed!',
            'message' => "Your booking at {$hotelNama} has been confirmed. Booking code: {$pemesanan->kode_booking}.",
            'is_read' => false,
            'data'    => [
                'pemesanan_id' => (string) $pemesanan->id,
                'kode_booking' => $pemesanan->kode_booking,
                'hotel_nama'   => $hotelNama,
            ],
        ]);

        if ($user->fcm_token) {
            FcmHelper::sendNotification(
                $user->fcm_token,
                'Booking Confirmed! 🎉',
                "Your booking at {$hotelNama} has been confirmed. Code: {$pemesanan->kode_booking}",
                [
                    'type'         => 'booking',
                    'pemesanan_id' => (string) $pemesanan->id,
                    'kode_booking' => $pemesanan->kode_booking,
                ]
            );
        }
        return response()->json([
            'status'  => true,
            'message' => 'Pemesanan berhasil dibuat',
            'data'    => $pemesanan->load(['user', 'kamar.hotel.fotoHotels', 'kamar.fotoKamars', 'addons']),
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $pemesanan = Pemesanan::find($id);

        if (!$pemesanan) {
            return response()->json(['status' => false, 'message' => 'Pemesanan tidak ditemukan'], 404);
        }

        $user = $request->user();
        if ((int) $pemesanan->user_id !== (int) $user->id) {
            return response()->json(['status' => false, 'message' => 'Anda tidak memiliki akses ke pemesanan ini'], 403);
        }

        $request->validate([
            'kamar_id'     => 'sometimes|required|exists:kamars,id',
            'tgl_checkin'  => 'sometimes|required|date',
            'tgl_checkout' => 'sometimes|required|date|after:tgl_checkin',
            'room_count'   => 'nullable|integer|min:1',
            'guest_count'  => 'nullable|integer|min:1',
            'status_pesan' => 'nullable|string|max:255',
            'metode_bayar' => 'nullable|string|max:255',
            'kode_booking' => 'nullable|string|max:255|unique:pemesanans,kode_booking,' . $pemesanan->id,
            'nama'         => 'sometimes|required|string|max:255',
            'email'        => 'sometimes|required|email|max:255',
            'no_telp'      => 'sometimes|required|string|max:255',
            'addon_ids'    => 'nullable|array',
            'addon_ids.*'  => 'exists:addons,id',
        ]);

        $oldStatus = $pemesanan->status_pesan;

        $pemesanan->update($request->only([
            'kamar_id', 'tgl_checkin', 'tgl_checkout', 'room_count', 'guest_count',
            'status_pesan', 'metode_bayar', 'kode_booking',
            'nama', 'email', 'no_telp',
        ]));

        if ($request->has('addon_ids')) {
            $syncData = [];
            foreach ($request->addon_ids as $addonId) {
                $syncData[$addonId] = ['user_id' => $user->id];
            }
            $pemesanan->addons()->sync($syncData);
        }

        $pemesanan->load(['kamar.hotel', 'user']);
        $hotelNama  = $pemesanan->kamar->hotel->nama ?? 'hotel';
        $bookingUser = $pemesanan->user;

        if ($oldStatus !== 'completed' && $pemesanan->status_pesan === 'completed') {
            Notification::create([
                'user_id' => $pemesanan->user_id,
                'type'    => 'review',
                'title'   => 'How was your stay?',
                'message' => "You've checked out from {$hotelNama}. Share your experience!",
                'is_read' => false,
                'data'    => [
                    'pemesanan_id' => (string) $pemesanan->id,
                    'kode_booking' => $pemesanan->kode_booking,
                    'hotel_nama'   => $hotelNama,
                ],
            ]);

            if ($bookingUser?->fcm_token) {
                FcmHelper::sendNotification(
                    $bookingUser->fcm_token,
                    'How was your stay? ⭐',
                    "You've checked out from {$hotelNama}. Leave a review!",
                    [
                        'type'         => 'review',
                        'pemesanan_id' => (string) $pemesanan->id,
                    ]
                );
            }
        }

        return response()->json([
            'status'  => true,
            'message' => 'Pemesanan berhasil diperbarui',
            'data'    => $pemesanan->load(['user', 'kamar.hotel.fotoHotels', 'kamar.fotoKamars', 'addons', 'ulasan']),
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $pemesanan = Pemesanan::find($id);

        if (!$pemesanan) {
            return response()->json(['status' => false, 'message' => 'Pemesanan tidak ditemukan'], 404);
        }

        $user = $request->user();
        if ((int) $pemesanan->user_id !== (int) $user->id) {
            return response()->json(['status' => false, 'message' => 'Anda tidak memiliki akses ke pemesanan ini'], 403);
        }

        $pemesanan->delete();

        return response()->json(['status' => true, 'message' => 'Pemesanan berhasil dihapus']);
    }
}
