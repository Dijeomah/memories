<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\GuestController;
use App\Http\Controllers\Api\MediaController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\PaystackWebhookController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes (no authentication required)
Route::post('/scan', [GuestController::class, 'scan']);
Route::post('/events/{id}/join', [GuestController::class, 'join']);

// Webhook routes (no authentication - verified by signature)
Route::post('/webhook/paystack', [PaystackWebhookController::class, 'handleWebhook']);

// Authentication routes
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    // Protected auth routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
    });
});

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {

    // Subscription routes
    Route::prefix('subscription')->group(function () {
        Route::get('/plans', [SubscriptionController::class, 'index']);
        Route::get('/', [SubscriptionController::class, 'show']);
        Route::post('/subscribe', [SubscriptionController::class, 'subscribe']);
        Route::post('/upgrade', [SubscriptionController::class, 'upgrade']);
        Route::post('/cancel', [SubscriptionController::class, 'cancel']);
        Route::get('/transactions', [SubscriptionController::class, 'transactions']);
    });

    // Payment verification
    Route::get('/payment/verify/{reference}', [SubscriptionController::class, 'verifyPayment']);

    // Event routes (Creator only)
    Route::prefix('events')->group(function () {
        Route::get('/', [EventController::class, 'index']);
        Route::post('/', [EventController::class, 'store']);
        Route::get('/{id}', [EventController::class, 'show']);
        Route::put('/{id}', [EventController::class, 'update']);
        Route::delete('/{id}', [EventController::class, 'destroy']);
        Route::get('/{id}/qr', [EventController::class, 'getQRCode']);
        Route::get('/{id}/media', [EventController::class, 'getMedia']);
        Route::get('/{id}/guests', [EventController::class, 'getGuests']);
        Route::post('/{id}/download', [EventController::class, 'downloadMedia']);

        // QR scan analytics
        Route::get('/{id}/scans', [EventController::class, 'getQRScans']);
        Route::get('/{id}/scans/stats', [EventController::class, 'getQRScanStats']);

        // Guest media upload
        Route::post('/{id}/media', [GuestController::class, 'uploadMedia']);

        // Guest's own media
        Route::get('/{id}/my-media', [GuestController::class, 'getMyMedia']);
    });

    // Media routes
    Route::prefix('media')->group(function () {
        Route::get('/{id}', [MediaController::class, 'show']);
        Route::put('/{id}/moderate', [MediaController::class, 'moderate']);
        Route::delete('/{id}', [GuestController::class, 'deleteMedia']);
    });
});
