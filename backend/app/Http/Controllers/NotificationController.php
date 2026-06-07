<?php

namespace App\Http\Controllers;

use App\Helpers\FcmHelper;
use App\Models\Notification;
use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Carbon\Carbon;

class NotificationController extends Controller
{
    // ─── Helper: simpan notif ke DB + kirim push FCM ──────────────────────────
    private function createAndPush(
        int $userId,
        ?string $fcmToken,      // ← fix: ?string bukan string = null
        string $type,
        string $title,
        string $message,
        ?array $data = null     // ← fix: ?array bukan array = null
    ): void {
        Notification::create([
            'user_id' => $userId,
            'type'    => $type,
            'title'   => $title,
            'message' => $message,
            'is_read' => false,
            'data'    => $data,
        ]);

        if ($fcmToken) {
            FcmHelper::sendNotification(
                $fcmToken,
                $title,
                $message,
                $data ? array_merge(['type' => $type], $data) : ['type' => $type]
            );
        }
    }

    // ─── Generate review notifications ────────────────────────────────────────
    public function generateReviewNotifications(Request $request)
    {
        $user = $request->user();

        $bookings = Pemesanan::with(['kamar.hotel', 'ulasan'])
            ->where('user_id', $user->id)
            ->where('tgl_checkout', '<=', Carbon::now())
            ->where('status_pesan', 'confirmed')
            ->get();

        foreach ($bookings as $booking) {
            if ($booking->ulasan) continue;

            $exists = Notification::where('user_id', $user->id)
                ->where('type', 'review')
                ->get()
                ->contains(function ($notif) use ($booking) {
                    return isset($notif->data['pemesanan_id']) &&
                        (int) $notif->data['pemesanan_id'] === (int) $booking->id;
                });

            if ($exists) continue;

            $this->createAndPush(
                $user->id,
                $user->fcm_token,
                'review',
                'How was your stay?',
                'You just checked out from ' . $booking->kamar->hotel->nama . '. Share your experience!',
                [
                    'pemesanan_id' => (string) $booking->id,
                    'kamar_id'     => (string) $booking->kamar_id,
                    'hotel_nama'   => $booking->kamar->hotel->nama,
                    'kode_booking' => $booking->kode_booking,
                ]
            );
        }

        return response()->json(['status' => true]);
    }

    // ─── Index ─────────────────────────────────────────────────────────────────
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

    // ─── Mark all as read ──────────────────────────────────────────────────────
    public function markAllAsRead(Request $request)
    {
        Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['status' => true]);
    }

    // ─── Mark one as read ──────────────────────────────────────────────────────
    public function markAsRead(Request $request, $id)
    {
        $notif = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $notif->update(['is_read' => true]);

        return response()->json(['status' => true]);
    }

    // ─── Unread count ──────────────────────────────────────────────────────────
    public function unreadCount(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json(['status' => true, 'count' => $count]);
    }

    // ─── Destroy ───────────────────────────────────────────────────────────────
    public function destroy(Request $request, $id)
    {
        $notif = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $notif->delete();

        return response()->json(['status' => true]);
    }

    // ─── Log login ─────────────────────────────────────────────────────────────
    public function logLoginActivity(Request $request)
    {
        $user = $request->user();
        $this->createAndPush(
            $user->id,
            $user->fcm_token,
            'activity',
            'Signed In',
            'Your account was signed in successfully.'
        );
        return response()->json(['status' => true]);
    }

    // ─── Log profile update ────────────────────────────────────────────────────
    public function logProfileUpdate(Request $request)
    {
        $user = $request->user();
        $this->createAndPush(
            $user->id,
            $user->fcm_token,
            'profile',
            'Profile Updated',
            'Your profile details were updated successfully.'
        );
        return response()->json(['status' => true]);
    }

    // ─── Log location preference ───────────────────────────────────────────────
    public function logLocationPreference(Request $request)
    {
        $user = $request->user();
        $this->createAndPush(
            $user->id,
            $user->fcm_token,
            'location',
            'Location Preference Saved',
            'Your location access preference has been saved for BookyGo.'
        );
        return response()->json(['status' => true]);
    }

    // ─── Seed welcome notifications ────────────────────────────────────────────
    public function seedWelcomeNotifications(Request $request)
    {
        $user   = $request->user();
        $userId = $user->id;

        $exists = Notification::where('user_id', $userId)
            ->where('type', 'welcome')
            ->exists();

        if ($exists) {
            return response()->json(['status' => true]);
        }

        $this->createAndPush(
            $userId,
            $user->fcm_token,
            'system',
            'Notifications Enabled',
            'You will now receive booking updates and useful reminders.'
        );

        $this->createAndPush(
            $userId,
            $user->fcm_token,
            'welcome',
            'Welcome to BookyGo',
            'Discover stays, save favorites, and keep your trips organized.'
        );

        return response()->json(['status' => true]);
    }
}
