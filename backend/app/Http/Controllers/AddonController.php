<?php

namespace App\Http\Controllers;

use App\Models\Addon;
use Illuminate\Http\Request;

class AddonController extends Controller
{
    public function index()
    {
        $addons = Addon::latest()->get();

        return response()->json([
            'status' => true,
            'message' => 'Data addon berhasil diambil',
            'data' => $addons
        ]);
    }

    public function show($id)
    {
        $addon = Addon::find($id);

        if (!$addon) {
            return response()->json([
                'status' => false,
                'message' => 'Addon tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'message' => 'Detail addon berhasil diambil',
            'data' => $addon
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:255',
            'harga' => 'required|numeric|min:0',
        ]);

        $addon = Addon::create([
            'nama' => $request->nama,
            'harga' => $request->harga,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Addon berhasil ditambahkan',
            'data' => $addon
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $addon = Addon::find($id);

        if (!$addon) {
            return response()->json([
                'status' => false,
                'message' => 'Addon tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama' => 'required|string|max:255',
            'harga' => 'required|numeric|min:0',
        ]);

        $addon->update([
            'nama' => $request->nama,
            'harga' => $request->harga,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Addon berhasil diperbarui',
            'data' => $addon
        ]);
    }

    public function destroy($id)
    {
        $addon = Addon::find($id);

        if (!$addon) {
            return response()->json([
                'status' => false,
                'message' => 'Addon tidak ditemukan'
            ], 404);
        }

        $addon->delete();

        return response()->json([
            'status' => true,
            'message' => 'Addon berhasil dihapus'
        ]);
    }
}
