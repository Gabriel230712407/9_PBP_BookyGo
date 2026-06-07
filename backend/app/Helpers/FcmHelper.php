<?php

namespace App\Helpers;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Google\Auth\Credentials\ServiceAccountCredentials;

class FcmHelper
{
    private static function getAccessToken(): string
    {
        $credentialsPath = storage_path('app/firebase-service-account.json');
        
        $credentials = new ServiceAccountCredentials(
            'https://www.googleapis.com/auth/firebase.messaging',
            json_decode(file_get_contents($credentialsPath), true)
        );

        $token = $credentials->fetchAuthToken();
        return $token['access_token'];
    }

    public static function sendNotification(
        string $fcmToken,
        string $title,
        string $body,
        array $data = []
    ): bool {
        try {
            $projectId = 'pbp-bookygo-e278e';
            $accessToken = self::getAccessToken();

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type'  => 'application/json',
            ])->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", [
                'message' => [
                    'token' => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body'  => $body,
                    ],
                    'data' => array_map('strval', $data),
                    'android' => [
                        'priority' => 'high',
                        'notification' => [
                            'channel_id' => 'bookygo_high_importance',
                        ],
                    ],
                ],
            ]);

            if ($response->successful()) {
                Log::info('FCM sent', ['token' => substr($fcmToken, 0, 20), 'title' => $title]);
                return true;
            }

            Log::error('FCM failed', ['response' => $response->body()]);
            return false;

        } catch (\Exception $e) {
            Log::error('FCM exception', ['error' => $e->getMessage()]);
            return false;
        }
    }

    // Kirim ke banyak user sekaligus
    public static function sendToUsers(array $fcmTokens, string $title, string $body, array $data = []): void
    {
        foreach ($fcmTokens as $token) {
            if ($token) {
                self::sendNotification($token, $title, $body, $data);
            }
        }
    }
}
