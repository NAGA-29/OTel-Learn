<?php

namespace Tests\Feature;

use App\Models\Supplier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SupplierApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_supplier_can_be_created_and_fetched(): void
    {
        $response = $this->postJson('/api/suppliers', [
            'name' => 'Test Supplier',
            'email' => 'test@example.com',
        ])->assertCreated()->assertHeader('X-Request-ID');

        $id = $response->json('data.id');
        $this->getJson("/api/suppliers/{$id}")
            ->assertOk()
            ->assertJsonPath('data.email', 'test@example.com');
        $this->assertDatabaseHas(Supplier::class, ['id' => $id]);

        $this->deleteJson("/api/suppliers/{$id}")
            ->assertNoContent()
            ->assertHeader('X-Request-ID');
        $this->assertDatabaseMissing(Supplier::class, ['id' => $id]);
        $this->getJson("/api/suppliers/{$id}")->assertNotFound();

        $this->postJson('/api/suppliers', [])
            ->assertUnprocessable()
            ->assertHeader('X-Request-ID');
    }
}
