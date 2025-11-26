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
        Schema::create('media', function (Blueprint $table) {
            $table->id();
            $table->foreignId('event_id')->constrained('events')->onDelete('cascade');
            $table->foreignId('uploader_id')->constrained('users')->onDelete('cascade');
            $table->string('file_path');
            $table->enum('file_type', ['photo', 'video']);
            $table->unsignedBigInteger('file_size')->nullable();
            $table->string('thumbnail_path')->nullable();
            $table->text('caption')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('approved');
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index('event_id');
            $table->index('uploader_id');
            $table->index('file_type');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('media');
    }
};
