<?php

namespace App\Providers;

use App\Contracts\StorageServiceInterface;
use App\Services\Storage\CloudinaryStorageService;
use App\Services\Storage\DigitalOceanStorageService;
use Illuminate\Support\ServiceProvider;

class StorageServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->singleton(StorageServiceInterface::class, function ($app) {
            $driver = config('filesystems.cloud_storage_driver', 'cloudinary');

            return match ($driver) {
                'digitalocean' => new DigitalOceanStorageService(),
                default => new CloudinaryStorageService(),
            };
        });
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
