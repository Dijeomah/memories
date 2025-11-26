<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SubscriptionTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'subscription_id',
        'plan_id',
        'reference',
        'amount',
        'currency',
        'status',
        'type',
        'paystack_reference',
        'authorization_code',
        'gateway_response',
        'paid_at',
        'metadata',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'paid_at' => 'datetime',
        'metadata' => 'array',
    ];

    /**
     * The user who made the transaction
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * The subscription associated with this transaction
     */
    public function subscription()
    {
        return $this->belongsTo(UserSubscription::class, 'subscription_id');
    }

    /**
     * The plan for this transaction
     */
    public function plan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }

    /**
     * Check if transaction is successful
     */
    public function isSuccessful(): bool
    {
        return $this->status === 'success';
    }

    /**
     * Check if transaction is pending
     */
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    /**
     * Check if transaction failed
     */
    public function failed(): bool
    {
        return $this->status === 'failed';
    }

    /**
     * Mark transaction as successful
     */
    public function markAsSuccessful(array $data = []): bool
    {
        $this->status = 'success';
        $this->paid_at = now();

        if (isset($data['gateway_response'])) {
            $this->gateway_response = $data['gateway_response'];
        }

        if (isset($data['authorization_code'])) {
            $this->authorization_code = $data['authorization_code'];
        }

        return $this->save();
    }

    /**
     * Mark transaction as failed
     */
    public function markAsFailed(string $reason = null): bool
    {
        $this->status = 'failed';

        if ($reason) {
            $this->gateway_response = $reason;
        }

        return $this->save();
    }
}
