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
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('creator_id')->constrained('users')->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->dateTime('event_date')->nullable();
            $table->string('location')->nullable();
            $table->string('qr_code_data')->unique();
            $table->enum('status', ['draft', 'active', 'expired'])->default('active');
            $table->json('settings')->nullable();
            $table->timestamps();

            $table->index('creator_id');
            $table->index('qr_code_data');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};
