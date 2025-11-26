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
        Schema::create('qr_scans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('event_id')->constrained('events')->onDelete('cascade');
            $table->string('qr_code_data');
            $table->string('ip_address')->nullable();
            $table->text('user_agent')->nullable();
            $table->json('location_data')->nullable(); // Optional geographic data
            $table->foreignId('guest_id')->nullable()->constrained('users')->onDelete('set null'); // If they joined
            $table->timestamp('scanned_at')->useCurrent();
            $table->timestamps();

            $table->index('event_id');
            $table->index('qr_code_data');
            $table->index('guest_id');
            $table->index('scanned_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('qr_scans');
    }
};
