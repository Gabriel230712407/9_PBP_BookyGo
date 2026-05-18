<?php

namespace App\Http\Controllers;

use App\Models\Pemesanan;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PemesananController extends Controller
{
    public function index()
    {
        $pemesanans = Pemesanan::with(['user', 'kamar.hotel', 'addons', 'ulasan'])
            ->latest()
            ->get();

        return response()->json([
            'status' => true,
            'message' => 'Data pemesanan berhasil diambil',
            'data' => $pemesanans
        ]);
    }

    public function show($id)
    {
        $pemesanan = Pemesanan::with(['user', 'kamar.hotel', 'addons', 'ulasan'])
            ->find($id);

        if (!$pemesanan) {
            return response()->json([
                'status' => false,
                'message' => 'Pemesanan tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail pemesanan berhasil diambil',
            'data' => $pemesanan
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'kamar_id' => 'required|exists:kamars,id',
            'tgl_checkin' => 'required|date',
            'tgl_checkout' => 'required|date|after:tgl_checkin',
            'status_pesan' => 'nullable|string|max:255',
            'metode_bayar' => 'nullable|string|max:255',
            'kode_booking' => 'nullable|string|max:255|unique:pemesanans,kode_booking',
            'nama' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'no_telp' => 'required|string|max:255',
            'addon_ids' => 'nullable|array',
            'addon_ids.*' => 'exists:addons,id',
        ]);

        $pemesanan = Pemesanan::create([
            'user_id' => $request->user_id,
            'kamar_id' => $request->kamar_id,
            'tgl_checkin' => $request->tgl_checkin,
            'tgl_checkout' => $request->tgl_checkout,
            'status_pesan' => $request->status_pesan ?? 'pending',
            'metode_bayar' => $request->metode_bayar,
            'kode_booking' => $request->kode_booking ?? 'BK-' . strtoupper(Str::random(8)),
            'nama' => $request->nama,
            'email' => $request->email,
            'no_telp' => $request->no_telp,
        ]);

        if ($request->has('addon_ids')) {
            $syncData = [];

            foreach ($request->addon_ids as $addonId) {
                $syncData[$addonId] = [
                    'user_id' => $request->user_id,
                ];
            }

            $pemesanan->addons()->sync($syncData);
        }

        return response()->json([
            'status' => true,
            'message' => 'Pemesanan berhasil dibuat',
            'data' => $pemesanan->load(['user', 'kamar.hotel', 'addons'])
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $pemesanan = Pemesanan::find($id);

        if (!$pemesanan) {
            return response()->json([
                'status' => false,
                'message' => 'Pemesanan tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'user_id' => 'sometimes|required|exists:users,id',
            'kamar_id' => 'sometimes|required|exists:kamars,id',
            'tgl_checkin' => 'sometimes|required|date',
            'tgl_checkout' => 'sometimes|required|date|after:tgl_checkin',
            'status_pesan' => 'nullable|string|max:255',
            'metode_bayar' => 'nullable|string|max:255',
            'kode_booking' => 'nullable|string|max:255|unique:pemesanans,kode_booking,' . $pemesanan->id,
            'nama' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|max:255',
            'no_telp' => 'sometimes|required|string|max:255',
            'addon_ids' => 'nullable|array',
            'addon_ids.*' => 'exists:addons,id',
        ]);

        $pemesanan->update($request->only([
            'user_id',
            'kamar_id',
            'tgl_checkin',
            'tgl_checkout',
            'status_pesan',
            'metode_bayar',
            'kode_booking',
            'nama',
            'email',
            'no_telp',
        ]));

        if ($request->has('addon_ids')) {
            $syncData = [];
            $userId = $request->user_id ?? $pemesanan->user_id;

            foreach ($request->addon_ids as $addonId) {
                $syncData[$addonId] = [
                    'user_id' => $userId,
                ];
            }

            $pemesanan->addons()->sync($syncData);
        }

        return response()->json([
            'status' => true,
            'message' => 'Pemesanan berhasil diperbarui',
            'data' => $pemesanan->load(['user', 'kamar.hotel', 'addons', 'ulasan'])
        ]);
    }

    public function destroy($id)
    {
        $pemesanan = Pemesanan::find($id);

        if (!$pemesanan) {
            return response()->json([
                'status' => false,
                'message' => 'Pemesanan tidak ditemukan'
            ], 404);
        }

        $pemesanan->delete();

        return response()->json([
            'status' => true,
            'message' => 'Pemesanan berhasil dihapus'
        ]);
    }
}