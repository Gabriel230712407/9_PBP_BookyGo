<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Carbon\Carbon;

class NotificationController extends Controller
{
    // Dipanggil otomatis saat user buka app — generate notif review yang belum ada
    public function generateReviewNotifications(Request $request)
    {
        $user = $request->user();

        // Cari booking yang sudah checkout dan belum punya ulasan dan belum ada notifnya
        $bookings = Pemesanan::with(['kamar.hotel', 'ulasan'])
            ->where('user_id', $user->id)
            ->where('tgl_checkout', '<=', Carbon::now())
            ->where('status_pesan', 'confirmed') // sesuaikan dengan status kamu
            ->get();

        foreach ($bookings as $booking) {
            // Skip kalau sudah direview
            if ($booking->ulasan) continue;

            // Skip kalau notif sudah ada
            $exists = Notification::where('user_id', $user->id)
                ->where('type', 'review')
                ->where('data->pemesanan_id', $booking->id)
                ->exists();

            if ($exists) continue;

            // Buat notifikasi baru
            Notification::create([
                'user_id'  => $user->id,
                'type'     => 'review',
                'title'    => 'Bagaimana pengalaman menginapmu?',
                'message'  => 'Kamu baru saja checkout dari ' . $booking->kamar->hotel->nama . '. Yuk, bagikan ulasanmu!',
                'is_read'  => false,
                'data'     => json_encode([
                    'pemesanan_id' => $booking->id,
                    'kamar_id'     => $booking->kamar_id,
                    'hotel_nama'   => $booking->kamar->hotel->nama,
                    'kode_booking' => $booking->kode_booking,
                ]),
            ]);
        }

        return response()->json(['status' => true]);
    }

    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'status' => true,
            'data'   => $notifications,
        ]);
    }

    public function markAllAsRead(Request $request)
    {
        Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['status' => true]);
    }

    public function markAsRead(Request $request, $id)
    {
        $notif = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $notif->update(['is_read' => true]);

        return response()->json(['status' => true]);
    }

    public function unreadCount(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json(['status' => true, 'count' => $count]);
    }
}