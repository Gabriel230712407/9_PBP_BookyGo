<?php

namespace App\Http\Controllers;

use App\Models\Wishlist;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    public function index(Request $request)
    {
        $wishlists = Wishlist::with(['hotel.fotoHotels'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'status' => true,
            'message' => 'Data wishlist berhasil diambil',
            'data' => $wishlists
        ]);
    }

    public function show(Request $request, $id)
    {
        $wishlist = Wishlist::with(['hotel.fotoHotels'])
            ->where('user_id', $request->user()->id)
            ->find($id);

        if (!$wishlist) {
            return response()->json([
                'status' => false,
                'message' => 'Wishlist tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail wishlist berhasil diambil',
            'data' => $wishlist
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'hotel_id' => 'required|exists:hotels,id',
        ]);

        $userId = $request->user()->id;

        $exists = Wishlist::where('user_id', $userId)
            ->where('hotel_id', $request->hotel_id)
            ->first();

        if ($exists) {
            return response()->json([
                'status' => false,
                'message' => 'Hotel sudah ada di wishlist'
            ], 409);
        }

        $wishlist = Wishlist::create([
            'user_id' => $userId,
            'hotel_id' => $request->hotel_id,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Wishlist berhasil ditambahkan',
            'data' => $wishlist->load(['hotel.fotoHotels'])
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $wishlist = Wishlist::where('user_id', $request->user()->id)->find($id);

        if (!$wishlist) {
            return response()->json([
                'status' => false,
                'message' => 'Wishlist tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'hotel_id' => 'sometimes|required|exists:hotels,id',
        ]);

        $userId = $request->user()->id;
        $hotelId = $request->hotel_id ?? $wishlist->hotel_id;

        $exists = Wishlist::where('user_id', $userId)
            ->where('hotel_id', $hotelId)
            ->where('id', '!=', $wishlist->id)
            ->first();

        if ($exists) {
            return response()->json([
                'status' => false,
                'message' => 'Hotel sudah ada di wishlist'
            ], 409);
        }

        $wishlist->update([
            'user_id' => $userId,
            'hotel_id' => $hotelId,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Wishlist berhasil diperbarui',
            'data' => $wishlist->load(['hotel.fotoHotels'])
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $wishlist = Wishlist::where('user_id', $request->user()->id)->find($id);

        if (!$wishlist) {
            return response()->json([
                'status' => false,
                'message' => 'Wishlist tidak ditemukan'
            ], 404);
        }

        $wishlist->delete();

        return response()->json([
            'status' => true,
            'message' => 'Wishlist berhasil dihapus'
        ]);
    }

    public function myWishlists(Request $request)
    {
        $wishlists = Wishlist::with(['hotel.fotoHotels'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'status' => true,
            'data' => $wishlists
        ]);
    }

    public function toggle(Request $request)
    {
        $request->validate(['hotel_id' => 'required|exists:hotels,id']);

        $existing = Wishlist::where('user_id', $request->user()->id)
            ->where('hotel_id', $request->hotel_id)
            ->first();

        if ($existing) {
            $existing->delete();
            return response()->json([
                'status' => true,
                'action' => 'removed',
                'message' => 'Dihapus dari wishlist'
            ]);
        }

        $wishlist = Wishlist::create([
            'user_id'  => $request->user()->id,
            'hotel_id' => $request->hotel_id,
        ]);

        return response()->json([
            'status' => true,
            'action' => 'added',
            'message' => 'Ditambahkan ke wishlist',
            'data' => $wishlist
        ], 201);
    }
}