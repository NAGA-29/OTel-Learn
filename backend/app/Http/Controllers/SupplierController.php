<?php

namespace App\Http\Controllers;

use App\Services\SupplierService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class SupplierController extends Controller
{
    public function __construct(private readonly SupplierService $suppliers) {}

    public function index(): JsonResponse
    {
        $suppliers = $this->suppliers->all();
        Log::info('Suppliers listed', ['supplier_count' => $suppliers->count()]);
        return response()->json(['data' => $suppliers]);
    }

    public function show(int $id): JsonResponse
    {
        $supplier = $this->suppliers->find($id);
        Log::info('Supplier fetched', ['supplier_id' => $supplier->id]);
        return response()->json(['data' => $supplier]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:suppliers,email'],
        ]);
        $supplier = $this->suppliers->create($validated);
        Log::info('Supplier created', ['supplier_id' => $supplier->id]);
        return response()->json(['data' => $supplier], 201);
    }

    public function destroy(int $id): JsonResponse
    {
        $supplier = $this->suppliers->delete($id);
        Log::info('Supplier deleted', ['supplier_id' => $supplier->id]);

        return response()->json(null, 204);
    }
}

