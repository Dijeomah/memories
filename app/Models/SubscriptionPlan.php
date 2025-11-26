<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class SubscriptionPlan extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'price',
        'currency',
        'interval',
        'max_events',
        'max_guests_per_event',
        'storage_limit_mb',
        'max_media_per_event',
        'features',
        'is_active',
        'trial_days',
        'paystack_plan_code',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'features' => 'array',
        'is_active' => 'boolean',
        'max_events' => 'integer',
        'max_guests_per_event' => 'integer',
        'storage_limit_mb' => 'integer',
        'max_media_per_event' => 'integer',
        'trial_days' => 'integer',
    ];

    /**
     * Subscriptions using this plan
     */
    public function subscriptions()
    {
        return $this->hasMany(UserSubscription::class, 'plan_id');
    }

    /**
     * Transactions for this plan
     */
    public function transactions()
    {
        return $this->hasMany(SubscriptionTransaction::class, 'plan_id');
    }

    /**
     * Check if plan is free
     */
    public function isFree(): bool
    {
        return $this->price == 0 || $this->slug === 'free';
    }

    /**
     * Check if plan has unlimited events
     */
    public function hasUnlimitedEvents(): bool
    {
        return $this->max_events === -1;
    }

    /**
     * Check if plan has unlimited media
     */
    public function hasUnlimitedMedia(): bool
    {
        return $this->max_media_per_event === -1;
    }

    /**
     * Get storage limit in bytes
     */
    public function getStorageLimitBytes(): int
    {
        return $this->storage_limit_mb * 1024 * 1024;
    }
}
