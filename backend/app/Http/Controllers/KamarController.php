<?php

namespace App\Http\Controllers;

use App\Models\Kamar;
use Illuminate\Http\Request;

class KamarController extends Controller
{
    public function index()
    {
        $kamars = Kamar::with(['hotel', 'fasilitas', 'fotoKamars'])
            ->latest()
            ->get();

        return response()->json([
            'status' => true,
            'message' => 'Data kamar berhasil diambil',
            'data' => $kamars
        ]);
    }

    public function show($id)
    {
        $kamar = Kamar::with([
            'hotel',
            'fasilitas',
            'fotoKamars',
            'ulasans.user'
        ])->find($id);

        if (!$kamar) {
            return response()->json([
                'status' => false,
                'message' => 'Kamar tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail kamar berhasil diambil',
            'data' => $kamar
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'hotel_id' => 'required|exists:hotels,id',
            'nama' => 'required|string|max:255',
            'smoking_policy' => 'nullable|in:smoking,non_smoking',
            'jenis_kasur' => 'required|string|max:255',
            'kapasitas' => 'required|integer|min:1',
            'harga' => 'required|numeric|min:0',
            'jumlah_ulasan' => 'nullable|integer|min:0',
            'fasilitas_ids' => 'nullable|array',
            'fasilitas_ids.*' => 'exists:fasilitas,id',
        ]);

        $kamar = Kamar::create([
            'hotel_id' => $request->hotel_id,
            'nama' => $request->nama,
            'smoking_policy' => $request->smoking_policy ?? 'non_smoking',
            'jenis_kasur' => $request->jenis_kasur,
            'kapasitas' => $request->kapasitas,
            'harga' => $request->harga,
            'jumlah_ulasan' => $request->jumlah_ulasan ?? 0,
        ]);

        if ($request->has('fasilitas_ids')) {
            $kamar->fasilitas()->sync($request->fasilitas_ids);
        }

        return response()->json([
            'status' => true,
            'message' => 'Kamar berhasil ditambahkan',
            'data' => $kamar->load(['hotel', 'fasilitas', 'fotoKamars'])
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $kamar = Kamar::find($id);

        if (!$kamar) {
            return response()->json([
                'status' => false,
                'message' => 'Kamar tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'hotel_id' => 'sometimes|required|exists:hotels,id',
            'nama' => 'sometimes|required|string|max:255',
            'smoking_policy' => 'sometimes|nullable|in:smoking,non_smoking',
            'jenis_kasur' => 'sometimes|required|string|max:255',
            'kapasitas' => 'sometimes|required|integer|min:1',
            'harga' => 'sometimes|required|numeric|min:0',
            'jumlah_ulasan' => 'nullable|integer|min:0',
            'fasilitas_ids' => 'nullable|array',
            'fasilitas_ids.*' => 'exists:fasilitas,id',
        ]);

        $kamar->update($request->only([
            'hotel_id',
            'nama',
            'smoking_policy',
            'jenis_kasur',
            'kapasitas',
            'harga',
            'jumlah_ulasan',
        ]));

        if ($request->has('fasilitas_ids')) {
            $kamar->fasilitas()->sync($request->fasilitas_ids);
        }

        return response()->json([
            'status' => true,
            'message' => 'Kamar berhasil diperbarui',
            'data' => $kamar->load(['hotel', 'fasilitas', 'fotoKamars'])
        ]);
    }

    public function destroy($id)
    {
        $kamar = Kamar::find($id);

        if (!$kamar) {
            return response()->json([
                'status' => false,
                'message' => 'Kamar tidak ditemukan'
            ], 404);
        }

        $kamar->delete();

        return response()->json([
            'status' => true,
            'message' => 'Kamar berhasil dihapus'
        ]);
    }
}