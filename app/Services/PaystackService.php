<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PaystackService
{
    protected $secretKey;
    protected $publicKey;
    protected $baseUrl;

    public function __construct()
    {
        $this->secretKey = config('services.paystack.secret_key');
        $this->publicKey = config('services.paystack.public_key');
        $this->baseUrl = 'https://api.paystack.co';
    }

    /**
     * Initialize a payment transaction
     *
     * @param array $data
     * @return array
     */
    public function initializeTransaction(array $data): array
    {
        $response = Http::withToken($this->secretKey)
            ->post("{$this->baseUrl}/transaction/initialize", [
                'email' => $data['email'],
                'amount' => $data['amount'] * 100, // Convert to kobo
                'currency' => $data['currency'] ?? 'NGN',
                'reference' => $data['reference'] ?? $this->generateReference(),
                'callback_url' => $data['callback_url'] ?? config('app.url') . '/api/payment/callback',
                'metadata' => $data['metadata'] ?? [],
            ]);

        return $response->json();
    }

    /**
     * Verify a payment transaction
     *
     * @param string $reference
     * @return array
     */
    public function verifyTransaction(string $reference): array
    {
        $response = Http::withToken($this->secretKey)
            ->get("{$this->baseUrl}/transaction/verify/{$reference}");

        return $response->json();
    }

    /**
     * Create a subscription plan on Paystack
     *
     * @param array $data
     * @return array
     */
    public function createPlan(array $data): array
    {
        $response = Http::withToken($this->secretKey)
            ->post("{$this->baseUrl}/plan", [
                'name' => $data['name'],
                'amount' => $data['amount'] * 100, // Convert to kobo
                'interval' => $data['interval'] ?? 'monthly',
                'currency' => $data['currency'] ?? 'NGN',
                'description' => $data['description'] ?? null,
            ]);

        return $response->json();
    }

    /**
     * Create a subscription
     *
     * @param array $data
     * @return array
     */
    public function createSubscription(array $data): array
    {
        $response = Http::withToken($this->secretKey)
            ->post("{$this->baseUrl}/subscription", [
                'customer' => $data['customer_code'],
                'plan' => $data['plan_code'],
                'authorization' => $data['authorization_code'],
            ]);

        return $response->json();
    }

    /**
     * Cancel a subscription
     *
     * @param string $subscriptionCode
     * @param string $emailToken
     * @return array
     */
    public function cancelSubscription(string $subscriptionCode, string $emailToken): array
    {
        $response = Http::withToken($this->secretKey)
            ->post("{$this->baseUrl}/subscription/disable", [
                'code' => $subscriptionCode,
                'token' => $emailToken,
            ]);

        return $response->json();
    }

    /**
     * Create a customer
     *
     * @param array $data
     * @return array
     */
    public function createCustomer(array $data): array
    {
        $response = Http::withToken($this->secretKey)
            ->post("{$this->baseUrl}/customer", [
                'email' => $data['email'],
                'first_name' => $data['first_name'] ?? null,
                'last_name' => $data['last_name'] ?? null,
                'phone' => $data['phone'] ?? null,
            ]);

        return $response->json();
    }

    /**
     * Fetch a customer
     *
     * @param string $emailOrCode
     * @return array
     */
    public function fetchCustomer(string $emailOrCode): array
    {
        $response = Http::withToken($this->secretKey)
            ->get("{$this->baseUrl}/customer/{$emailOrCode}");

        return $response->json();
    }

    /**
     * List all transactions
     *
     * @param array $params
     * @return array
     */
    public function listTransactions(array $params = []): array
    {
        $response = Http::withToken($this->secretKey)
            ->get("{$this->baseUrl}/transaction", $params);

        return $response->json();
    }

    /**
     * Generate a unique payment reference
     *
     * @return string
     */
    public function generateReference(): string
    {
        return 'MEM-' . strtoupper(Str::random(10)) . '-' . time();
    }

    /**
     * Validate webhook signature
     *
     * @param string $payload
     * @param string $signature
     * @return bool
     */
    public function validateWebhookSignature(string $payload, string $signature): bool
    {
        $hash = hash_hmac('sha512', $payload, $this->secretKey);
        return hash_equals($hash, $signature);
    }

    /**
     * Get public key
     *
     * @return string
     */
    public function getPublicKey(): string
    {
        return $this->publicKey;
    }
}
