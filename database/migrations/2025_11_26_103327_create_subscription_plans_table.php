<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('subscription_plans', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Free, Pro, Enterprise
            $table->string('slug')->unique(); // free, pro, enterprise
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2)->default(0); // Monthly price
            $table->string('currency', 3)->default('NGN'); // NGN for Paystack
            $table->string('billing_period')->default('monthly'); // monthly, yearly
            $table->integer('max_events')->default(1); // -1 for unlimited
            $table->integer('max_guests_per_event')->default(50);
            $table->bigInteger('storage_limit_mb')->default(1024); // 1GB in MB
            $table->integer('max_media_per_event')->default(-1); // -1 for unlimited
            $table->json('features')->nullable(); // Additional features
            $table->boolean('is_active')->default(true);
            $table->boolean('is_featured')->default(false);
            $table->integer('trial_days')->default(0);
            $table->string('paystack_plan_code')->nullable(); // Paystack plan code
            $table->timestamps();

            $table->index('slug');
            $table->index('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subscription_plans');
    }
};
