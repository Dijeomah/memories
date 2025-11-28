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
        Schema::table('subscription_plans', function (Blueprint $table) {
            // Rename interval to billing_period
            $table->renameColumn('interval', 'billing_period');

            // Add is_featured column
            $table->boolean('is_featured')->default(false)->after('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('subscription_plans', function (Blueprint $table) {
            // Rename billing_period back to interval
            $table->renameColumn('billing_period', 'interval');

            // Drop is_featured column
            $table->dropColumn('is_featured');
        });
    }
};
