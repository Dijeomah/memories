<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Carbon\Carbon;

class UserSubscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'plan_id',
        'status',
        'starts_at',
        'ends_at',
        'trial_ends_at',
        'cancelled_at',
        'paystack_subscription_code',
        'paystack_customer_code',
        'paystack_email_token',
        'auto_renew',
        'metadata',
    ];

    protected $casts = [
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'trial_ends_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'auto_renew' => 'boolean',
        'metadata' => 'array',
    ];

    /**
     * The user who owns the subscription
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * The subscription plan
     */
    public function plan()
    {
        return $this->belongsTo(SubscriptionPlan::class, 'plan_id');
    }

    /**
     * Transactions for this subscription
     */
    public function transactions()
    {
        return $this->hasMany(SubscriptionTransaction::class, 'subscription_id');
    }

    /**
     * Check if subscription is active
     */
    public function isActive(): bool
    {
        return $this->status === 'active' &&
               ($this->ends_at === null || $this->ends_at->isFuture());
    }

    /**
     * Check if subscription is on trial
     */
    public function onTrial(): bool
    {
        return $this->status === 'trial' &&
               $this->trial_ends_at !== null &&
               $this->trial_ends_at->isFuture();
    }

    /**
     * Check if subscription is expired
     */
    public function isExpired(): bool
    {
        return $this->status === 'expired' ||
               ($this->ends_at !== null && $this->ends_at->isPast());
    }

    /**
     * Check if subscription is cancelled
     */
    public function isCancelled(): bool
    {
        return $this->status === 'cancelled';
    }

    /**
     * Cancel subscription
     */
    public function cancel(): bool
    {
        $this->status = 'cancelled';
        $this->cancelled_at = now();
        $this->auto_renew = false;
        return $this->save();
    }

    /**
     * Activate subscription
     */
    public function activate(Carbon $endsAt = null): bool
    {
        $this->status = 'active';
        $this->starts_at = now();

        if ($endsAt) {
            $this->ends_at = $endsAt;
        } else {
            // Default to 1 month
            $this->ends_at = now()->addMonth();
        }

        return $this->save();
    }

    /**
     * Renew subscription
     */
    public function renew(int $months = 1): bool
    {
        $this->ends_at = $this->ends_at ?
            $this->ends_at->addMonths($months) :
            now()->addMonths($months);

        $this->status = 'active';

        return $this->save();
    }

    /**
     * Check if subscription can be renewed
     */
    public function canRenew(): bool
    {
        return $this->auto_renew && !$this->isCancelled();
    }
}
