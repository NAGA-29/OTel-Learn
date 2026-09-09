<?php

namespace Database\Seeders;

use App\Models\Supplier;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        foreach ([
            ['name' => 'OpenTelemetry Supplier', 'email' => 'otel@example.com'],
            ['name' => 'AWS Supplier', 'email' => 'aws@example.com'],
            ['name' => 'Demo Supplier', 'email' => 'demo@example.com'],
        ] as $supplier) {
            Supplier::query()->firstOrCreate(['email' => $supplier['email']], $supplier);
        }
    }
}

