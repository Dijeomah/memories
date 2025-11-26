<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionTransaction;
use App\Models\UserSubscription;
use App\Services\PaystackService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaystackWebhookController extends Controller
{
    protected $paystackService;

    public function __construct(PaystackService $paystackService)
    {
        $this->paystackService = $paystackService;
    }

    /**
     * Handle Paystack webhook events
     *
     * POST /api/webhook/paystack
     */
    public function handleWebhook(Request $request)
    {
        // Verify webhook signature
        $signature = $request->header('X-Paystack-Signature');
        $payload = $request->getContent();

        if (!$this->paystackService->validateWebhookSignature($payload, $signature)) {
            Log::warning('Invalid Paystack webhook signature', [
                'signature' => $signature,
                'payload' => $payload,
            ]);

            return response()->json(['message' => 'Invalid signature'], 401);
        }

        $event = $request->input('event');
        $data = $request->input('data');

        Log::info('Paystack webhook received', [
            'event' => $event,
            'data' => $data,
        ]);

        // Handle different event types
        switch ($event) {
            case 'charge.success':
                $this->handleChargeSuccess($data);
                break;

            case 'subscription.create':
                $this->handleSubscriptionCreate($data);
                break;

            case 'subscription.disable':
                $this->handleSubscriptionDisable($data);
                break;

            case 'invoice.create':
            case 'invoice.update':
                $this->handleInvoiceUpdate($data);
                break;

            default:
                Log::info('Unhandled Paystack event', ['event' => $event]);
        }

        return response()->json(['message' => 'Webhook handled successfully']);
    }

    /**
     * Handle successful charge
     *
     * @param array $data
     */
    protected function handleChargeSuccess(array $data)
    {
        $reference = $data['reference'] ?? null;

        if (!$reference) {
            Log::error('Charge success without reference', ['data' => $data]);
            return;
        }

        $transaction = SubscriptionTransaction::where('reference', $reference)->first();

        if (!$transaction) {
            Log::warning('Transaction not found for reference', ['reference' => $reference]);
            return;
        }

        if ($transaction->isSuccessful()) {
            Log::info('Transaction already processed', ['reference' => $reference]);
            return;
        }

        // Mark transaction as successful
        $transaction->markAsSuccessful([
            'gateway_response' => json_encode($data),
            'authorization_code' => $data['authorization']['authorization_code'] ?? null,
        ]);

        // Create or update subscription
        if ($transaction->type === 'renewal') {
            $this->handleRenewal($transaction, $data);
        } else {
            $this->handleNewSubscription($transaction, $data);
        }

        Log::info('Charge success processed', ['reference' => $reference]);
    }

    /**
     * Handle new subscription creation
     *
     * @param SubscriptionTransaction $transaction
     * @param array $data
     */
    protected function handleNewSubscription(SubscriptionTransaction $transaction, array $data)
    {
        // Check if subscription already exists
        if ($transaction->subscription_id) {
            Log::info('Subscription already exists', ['transaction_id' => $transaction->id]);
            return;
        }

        $subscription = UserSubscription::create([
            'user_id' => $transaction->user_id,
            'plan_id' => $transaction->plan_id,
            'status' => 'active',
            'starts_at' => now(),
            'ends_at' => now()->addMonth(),
            'paystack_customer_code' => $data['customer']['customer_code'] ?? null,
            'paystack_subscription_code' => $data['subscription_code'] ?? null,
            'metadata' => [
                'authorization' => $data['authorization'] ?? null,
            ],
        ]);

        $transaction->update(['subscription_id' => $subscription->id]);

        Log::info('New subscription created', [
            'subscription_id' => $subscription->id,
            'user_id' => $transaction->user_id,
        ]);
    }

    /**
     * Handle subscription renewal
     *
     * @param SubscriptionTransaction $transaction
     * @param array $data
     */
    protected function handleRenewal(SubscriptionTransaction $transaction, array $data)
    {
        $subscription = UserSubscription::where('user_id', $transaction->user_id)
            ->where('plan_id', $transaction->plan_id)
            ->latest()
            ->first();

        if (!$subscription) {
            Log::error('Subscription not found for renewal', ['transaction_id' => $transaction->id]);
            return;
        }

        $subscription->renew();
        $transaction->update(['subscription_id' => $subscription->id]);

        Log::info('Subscription renewed', [
            'subscription_id' => $subscription->id,
            'new_end_date' => $subscription->ends_at,
        ]);
    }

    /**
     * Handle subscription creation
     *
     * @param array $data
     */
    protected function handleSubscriptionCreate(array $data)
    {
        $customerCode = $data['customer']['customer_code'] ?? null;
        $subscriptionCode = $data['subscription_code'] ?? null;

        if (!$customerCode) {
            Log::error('Subscription create without customer code', ['data' => $data]);
            return;
        }

        // Find subscription by customer code
        $subscription = UserSubscription::where('paystack_customer_code', $customerCode)
            ->latest()
            ->first();

        if ($subscription) {
            $subscription->update([
                'paystack_subscription_code' => $subscriptionCode,
                'status' => 'active',
            ]);

            Log::info('Subscription updated with Paystack code', [
                'subscription_id' => $subscription->id,
                'subscription_code' => $subscriptionCode,
            ]);
        }
    }

    /**
     * Handle subscription disable
     *
     * @param array $data
     */
    protected function handleSubscriptionDisable(array $data)
    {
        $subscriptionCode = $data['subscription_code'] ?? null;

        if (!$subscriptionCode) {
            Log::error('Subscription disable without code', ['data' => $data]);
            return;
        }

        $subscription = UserSubscription::where('paystack_subscription_code', $subscriptionCode)->first();

        if ($subscription) {
            $subscription->cancel();

            Log::info('Subscription cancelled via webhook', [
                'subscription_id' => $subscription->id,
                'subscription_code' => $subscriptionCode,
            ]);
        }
    }

    /**
     * Handle invoice update
     *
     * @param array $data
     */
    protected function handleInvoiceUpdate(array $data)
    {
        // Handle invoice updates for subscription renewals
        Log::info('Invoice update received', ['data' => $data]);
    }
}
