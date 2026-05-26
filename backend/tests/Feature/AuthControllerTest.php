<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_stores_user_in_database_and_returns_token(): void
    {
        $payload = [
            'name' => 'Booky Go',
            'email' => 'bookygo@example.com',
            'password' => 'secret123',
        ];

        $response = $this->postJson('/api/register', $payload);

        $response
            ->assertCreated()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.user.email', $payload['email']);

        $this->assertDatabaseHas('users', [
            'name' => $payload['name'],
            'email' => $payload['email'],
        ]);

        $user = User::where('email', $payload['email'])->firstOrFail();
        $this->assertTrue(Hash::check($payload['password'], $user->password));
    }

    public function test_login_returns_token_for_existing_user(): void
    {
        $user = User::create([
            'name' => 'Existing User',
            'gender' => null,
            'no_telp' => null,
            'email' => 'existing@example.com',
            'password' => Hash::make('secret123'),
            'foto' => null,
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'secret123',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('status', true)
            ->assertJsonPath('data.user.email', $user->email);

        $this->assertNotEmpty($response->json('data.token'));
    }

    public function test_login_rejects_invalid_password(): void
    {
        User::create([
            'name' => 'Existing User',
            'gender' => null,
            'no_telp' => null,
            'email' => 'existing@example.com',
            'password' => Hash::make('secret123'),
            'foto' => null,
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'existing@example.com',
            'password' => 'wrong-pass',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }
}
