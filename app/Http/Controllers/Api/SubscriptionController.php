<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPlan;
use App\Models\UserSubscription;
use App\Models\SubscriptionTransaction;
use App\Services\PaystackService;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SubscriptionController extends Controller
{
    protected $paystackService;

    public function __construct(PaystackService $paystackService)
    {
        $this->paystackService = $paystackService;
    }

    /**
     * List all subscription plans
     *
     * GET /api/plans
     */
    public function index()
    {
        $plans = SubscriptionPlan::where('is_active', true)
            ->orderBy('price', 'asc')
            ->get();

        return response()->json([
            'plans' => $plans,
        ]);
    }

    /**
     * Get current user's subscription
     *
     * GET /api/subscription
     */
    public function show(Request $request)
    {
        $subscription = $request->user()
            ->activeSubscription()
            ->with('plan')
            ->first();

        if (!$subscription) {
            return response()->json([
                'message' => 'No active subscription found',
                'subscription' => null,
            ]);
        }

        return response()->json([
            'subscription' => $subscription,
        ]);
    }

    /**
     * Initialize subscription payment
     *
     * POST /api/subscribe
     */
    public function subscribe(Request $request)
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:subscription_plans,id',
            'callback_url' => 'nullable|url',
        ]);

        $plan = SubscriptionPlan::findOrFail($validated['plan_id']);
        $user = $request->user();

        // Check if user already has an active subscription
        if ($user->hasActiveSubscription()) {
            return response()->json([
                'message' => 'You already have an active subscription. Please cancel or upgrade instead.',
            ], 400);
        }

        // Free plan - activate immediately
        if ($plan->isFree()) {
            $subscription = UserSubscription::create([
                'user_id' => $user->id,
                'plan_id' => $plan->id,
                'status' => 'active',
                'starts_at' => now(),
                'ends_at' => null, // Free plan doesn't expire
            ]);

            return response()->json([
                'message' => 'Free plan activated successfully',
                'subscription' => $subscription->load('plan'),
            ]);
        }

        // Generate unique reference
        $reference = $this->paystackService->generateReference();

        // Create pending transaction
        $transaction = SubscriptionTransaction::create([
            'user_id' => $user->id,
            'plan_id' => $plan->id,
            'reference' => $reference,
            'amount' => $plan->price,
            'currency' => $plan->currency,
            'status' => 'pending',
            'type' => 'subscription',
        ]);

        // Initialize Paystack payment
        $payment = $this->paystackService->initializeTransaction([
            'email' => $user->email,
            'amount' => $plan->price,
            'currency' => $plan->currency,
            'reference' => $reference,
            'callback_url' => $validated['callback_url'] ?? config('app.url') . '/api/payment/callback',
            'metadata' => [
                'plan_id' => $plan->id,
                'plan_name' => $plan->name,
                'user_id' => $user->id,
                'transaction_id' => $transaction->id,
            ],
        ]);

        if (!$payment['status']) {
            $transaction->markAsFailed('Payment initialization failed');

            return response()->json([
                'message' => 'Failed to initialize payment',
                'error' => $payment['message'] ?? 'Unknown error',
            ], 500);
        }

        // Update transaction with Paystack reference
        $transaction->update([
            'paystack_reference' => $payment['data']['reference'],
        ]);

        return response()->json([
            'message' => 'Payment initialized successfully',
            'transaction' => $transaction,
            'payment_url' => $payment['data']['authorization_url'],
            'access_code' => $payment['data']['access_code'],
            'reference' => $payment['data']['reference'],
        ]);
    }

    /**
     * Verify payment and activate subscription
     *
     * GET /api/payment/verify/{reference}
     */
    public function verifyPayment(Request $request, $reference)
    {
        $transaction = SubscriptionTransaction::where('reference', $reference)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        if ($transaction->isSuccessful()) {
            return response()->json([
                'message' => 'Payment already verified',
                'transaction' => $transaction->load('subscription'),
            ]);
        }

        // Verify with Paystack
        $verification = $this->paystackService->verifyTransaction($reference);

        if (!$verification['status'] || $verification['data']['status'] !== 'success') {
            $transaction->markAsFailed($verification['message'] ?? 'Payment verification failed');

            return response()->json([
                'message' => 'Payment verification failed',
                'error' => $verification['message'] ?? 'Unknown error',
            ], 400);
        }

        // Mark transaction as successful
        $transaction->markAsSuccessful([
            'gateway_response' => json_encode($verification['data']),
            'authorization_code' => $verification['data']['authorization']['authorization_code'] ?? null,
        ]);

        // Create or activate subscription
        $subscription = UserSubscription::create([
            'user_id' => $transaction->user_id,
            'plan_id' => $transaction->plan_id,
            'status' => 'active',
            'starts_at' => now(),
            'ends_at' => now()->addMonth(),
            'paystack_customer_code' => $verification['data']['customer']['customer_code'] ?? null,
            'authorization_code' => $verification['data']['authorization']['authorization_code'] ?? null,
        ]);

        $transaction->update(['subscription_id' => $subscription->id]);

        return response()->json([
            'message' => 'Payment verified and subscription activated',
            'transaction' => $transaction,
            'subscription' => $subscription->load('plan'),
        ]);
    }

    /**
     * Cancel subscription
     *
     * POST /api/subscription/cancel
     */
    public function cancel(Request $request)
    {
        $subscription = $request->user()
            ->activeSubscription()
            ->firstOrFail();

        $subscription->cancel();

        return response()->json([
            'message' => 'Subscription cancelled successfully',
            'subscription' => $subscription->fresh()->load('plan'),
        ]);
    }

    /**
     * Upgrade/Downgrade subscription
     *
     * POST /api/subscription/upgrade
     */
    public function upgrade(Request $request)
    {
        $validated = $request->validate([
            'plan_id' => 'required|exists:subscription_plans,id',
            'callback_url' => 'nullable|url',
        ]);

        $newPlan = SubscriptionPlan::findOrFail($validated['plan_id']);
        $user = $request->user();

        $currentSubscription = $user->activeSubscription()->with('plan')->firstOrFail();

        // Check if it's actually a change
        if ($currentSubscription->plan_id === $newPlan->id) {
            return response()->json([
                'message' => 'You are already subscribed to this plan',
            ], 400);
        }

        // Cancel current subscription
        $currentSubscription->cancel();

        // If downgrading to free, activate immediately
        if ($newPlan->isFree()) {
            $subscription = UserSubscription::create([
                'user_id' => $user->id,
                'plan_id' => $newPlan->id,
                'status' => 'active',
                'starts_at' => now(),
                'ends_at' => null,
            ]);

            return response()->json([
                'message' => 'Downgraded to free plan successfully',
                'subscription' => $subscription->load('plan'),
            ]);
        }

        // Generate unique reference
        $reference = $this->paystackService->generateReference();

        // Create transaction for upgrade
        $transaction = SubscriptionTransaction::create([
            'user_id' => $user->id,
            'plan_id' => $newPlan->id,
            'reference' => $reference,
            'amount' => $newPlan->price,
            'currency' => $newPlan->currency,
            'status' => 'pending',
            'type' => $newPlan->price > $currentSubscription->plan->price ? 'upgrade' : 'downgrade',
        ]);

        // Initialize payment
        $payment = $this->paystackService->initializeTransaction([
            'email' => $user->email,
            'amount' => $newPlan->price,
            'currency' => $newPlan->currency,
            'reference' => $reference,
            'callback_url' => $validated['callback_url'] ?? config('app.url') . '/api/payment/callback',
            'metadata' => [
                'plan_id' => $newPlan->id,
                'plan_name' => $newPlan->name,
                'user_id' => $user->id,
                'transaction_id' => $transaction->id,
                'type' => 'upgrade',
            ],
        ]);

        if (!$payment['status']) {
            $transaction->markAsFailed('Payment initialization failed');

            return response()->json([
                'message' => 'Failed to initialize payment',
                'error' => $payment['message'] ?? 'Unknown error',
            ], 500);
        }

        $transaction->update([
            'paystack_reference' => $payment['data']['reference'],
        ]);

        return response()->json([
            'message' => 'Payment initialized successfully',
            'transaction' => $transaction,
            'payment_url' => $payment['data']['authorization_url'],
            'access_code' => $payment['data']['access_code'],
            'reference' => $payment['data']['reference'],
        ]);
    }

    /**
     * Get user's transaction history
     *
     * GET /api/transactions
     */
    public function transactions(Request $request)
    {
        $transactions = $request->user()
            ->subscriptionTransactions()
            ->with('plan')
            ->latest()
            ->paginate(20);

        return response()->json($transactions);
    }
}
