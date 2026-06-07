<?php

namespace App\Http\Controllers;

use App\Helpers\FcmHelper;
use App\Models\Notification;
use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Carbon\Carbon;

class NotificationController extends Controller
{
    private function createAndPush(
        int $userId,
        ?string $fcmToken,    
        string $type,
        string $title,
        string $message,
        ?array $data = null    
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

    public function generateReviewNotifications(Request $request)
    {
        $user = $request->user();

        $bookings = Pemesanan::with(['kamar.hotel', 'ulasan'])
            ->where('user_id', $user->id)
            ->where('status_pesan', 'confirmed')
            // ->where('tgl_checkout', '<=', Carbon::now()) // ← comment dulu untuk testing
            ->get();

        foreach ($bookings as $booking) {
            if ($booking->ulasan) continue;
            if ($booking->review_notified) continue;

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

            $booking->update(['review_notified' => true]);
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

    public function destroy(Request $request, $id)
    {
        $notif = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $notif->delete();

        return response()->json(['status' => true]);
    }

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
