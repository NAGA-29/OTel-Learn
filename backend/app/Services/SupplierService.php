<?php

namespace App\Services;

use App\Models\Supplier;
use Illuminate\Database\Eloquent\Collection;

class SupplierService
{
    /** @return Collection<int, Supplier> */
    public function all(): Collection
    {
        return Supplier::query()->orderBy('id')->get();
    }

    public function find(int $id): Supplier
    {
        return Supplier::query()->findOrFail($id);
    }

    /** @param array{name:string,email:string} $data */
    public function create(array $data): Supplier
    {
        return Supplier::query()->create($data);
    }
}

