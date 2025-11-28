<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\SubscriptionPlan;

class SubscriptionPlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $plans = [
            [
                'name' => 'Free',
                'slug' => 'free',
                'description' => 'Perfect for trying out the platform',
                'price' => 0,
                'currency' => 'NGN',
                'billing_period' => 'monthly',
                'max_events' => 1,
                'max_guests_per_event' => 50,
                'storage_limit_mb' => 1024, // 1GB
                'max_media_per_event' => 100,
                'features' => [
                    '1 event at a time',
                    'Up to 50 guests per event',
                    '1GB storage',
                    '100 media items per event',
                    'Basic QR code generation',
                    'Email support',
                ],
                'is_active' => true,
                'is_featured' => false,
                'trial_days' => 0,
            ],
            [
                'name' => 'Pro',
                'slug' => 'pro',
                'description' => 'For professional event organizers',
                'price' => 5000,
                'currency' => 'NGN',
                'billing_period' => 'monthly',
                'max_events' => 10,
                'max_guests_per_event' => 500,
                'storage_limit_mb' => 10240, // 10GB
                'max_media_per_event' => -1, // Unlimited
                'features' => [
                    'Up to 10 active events',
                    'Up to 500 guests per event',
                    '10GB storage',
                    'Unlimited media uploads',
                    'Custom QR code designs',
                    'Event analytics & QR scan tracking',
                    'Geofencing support',
                    'Priority email support',
                    'Auto-moderation',
                ],
                'is_active' => true,
                'is_featured' => true,
                'trial_days' => 7,
            ],
            [
                'name' => 'Enterprise',
                'slug' => 'enterprise',
                'description' => 'For large organizations and agencies',
                'price' => 20000,
                'currency' => 'NGN',
                'billing_period' => 'monthly',
                'max_events' => -1, // Unlimited
                'max_guests_per_event' => -1, // Unlimited
                'storage_limit_mb' => 102400, // 100GB
                'max_media_per_event' => -1, // Unlimited
                'features' => [
                    'Unlimited events',
                    'Unlimited guests',
                    '100GB storage',
                    'Unlimited media uploads',
                    'Custom QR code designs',
                    'Advanced analytics & reporting',
                    'Geofencing support',
                    'Custom branding',
                    'API access',
                    'Dedicated account manager',
                    '24/7 priority support',
                    'White-label options',
                ],
                'is_active' => true,
                'is_featured' => false,
                'trial_days' => 14,
            ],
        ];

        foreach ($plans as $plan) {
            SubscriptionPlan::updateOrCreate(
                ['slug' => $plan['slug']],
                $plan
            );
        }

        $this->command->info('Subscription plans seeded successfully!');
    }
}
