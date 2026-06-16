<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Validation\Rule;
use App\Models\Pemesanan;
use App\Models\Wishlist;
use App\Models\Ulasan;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Http;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:users,email',
            'password' => 'required|string|min:6',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('bookygo-token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Register berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Email atau password salah.'],
            ]);
        }

        $token = $user->createToken('bookygo-token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => $user,
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'status' => true,
            'message' => 'Data user berhasil diambil',
            'data' => $request->user(),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => true,
            'message' => 'Logout berhasil',
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => [
                'sometimes',
                'required',
                'email',
                'max:255',
                Rule::unique('users', 'email')->ignore($user->id),
            ],
            'gender' => 'sometimes|required|in:Pria,Wanita',
            'no_telp' => 'sometimes|nullable|string|max:255',
            'foto' => 'nullable|string|max:2048',
        ]);

        if ($request->has('name')) {
            $user->name = $validated['name'];
        }

        if ($request->has('email')) {
            $user->email = $validated['email'];
        }

        if ($request->has('gender')) {
            $user->gender = $validated['gender'];
        }

        if ($request->has('no_telp')) {
            $user->no_telp = $request->filled('no_telp') ? $validated['no_telp'] : null;
        }

        if ($request->has('foto')) {
            $user->foto = $request->filled('foto') ? $validated['foto'] : null;
        }

        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'Profile berhasil diperbarui',
            'data' => $user->fresh(),
        ]);
    }
    public function deleteAccount(Request $request)
    {
        $user = $request->user();

        DB::transaction(function () use ($user) {
            Wishlist::where('user_id', $user->id)->delete();
            Ulasan::where('user_id', $user->id)->delete();
            Pemesanan::where('user_id', $user->id)->delete();

            if (method_exists($user, 'tokens')) {
                $user->tokens()->delete();
            }

            $user->delete();
        });

        return response()->json([
            'status' => true,
            'message' => 'Account berhasil dihapus',
        ]);
    }

    public function updateFoto(Request $request)
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $user = $request->user();

        // Hapus foto lama kalau ada
        if ($user->foto && Storage::disk('public')->exists($user->foto)) {
            Storage::disk('public')->delete($user->foto);
        }

        $path = $request->file('foto')->store('profile_photos', 'public');
        $user->foto = $path;
        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'Foto profil berhasil diperbarui',
            'data' => [
                'foto_url' => asset('storage/' . $path),
            ],
        ]);
    }

    public function saveFcmToken(Request $request)
    {
        $request->validate(['fcm_token' => 'required|string']);

        $request->user()->update([
            'fcm_token' => $request->fcm_token,
        ]);

        return response()->json(['status' => true]);
    }

    public function googleLogin(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        $response = Http::withoutVerifying()->get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $request->id_token,
        ]);

        if ($response->failed() || !$response->json('email')) {
            return response()->json([
                'status' => false,
                'message' => 'Token Google tidak valid.',
            ], 401);
        }

        $googleData = $response->json();
        $email = $googleData['email'];
        $name = $googleData['name'] ?? 'User';
        $photo = $googleData['picture'] ?? null;
        $uid = $googleData['sub'];

        $user = User::firstOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'password' => Hash::make(str()->random(32)),
                'foto' => $photo,
                'google_uid' => $uid,
            ]
        );

        if (!$user->wasRecentlyCreated) {
            $user->update([
                'google_uid' => $uid,
                'foto' => $user->foto ?? $photo,
            ]);
        }

        $token = $user->createToken('bookygo-token')->plainTextToken;

        return response()->json([
            'status' => true,
            'message' => 'Login dengan Google berhasil',
            'data' => [
                'user' => $user->fresh(),
                'token' => $token,
                'token_type' => 'Bearer',
            ],
        ]);
    }
}
