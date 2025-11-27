<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Event extends Model
{
    use HasFactory;

    protected $fillable = [
        'creator_id',
        'title',
        'description',
        'event_date',
        'location',
        'event_image',
        'qr_code_data',
        'status',
        'settings',
    ];

    protected $casts = [
        'event_date' => 'datetime',
        'settings' => 'array',
    ];

    /**
     * The creator of this event
     */
    public function creator()
    {
        return $this->belongsTo(User::class, 'creator_id');
    }

    /**
     * Guests who have joined this event
     */
    public function guests()
    {
        return $this->belongsToMany(User::class, 'event_guests', 'event_id', 'guest_id')
            ->withTimestamps()
            ->withPivot('joined_at');
    }

    /**
     * Media uploaded to this event
     */
    public function media()
    {
        return $this->hasMany(Media::class);
    }

    /**
     * QR scans for this event
     */
    public function qrScans()
    {
        return $this->hasMany(QrScan::class);
    }

    /**
     * Check if event is active
     */
    public function isActive(): bool
    {
        return $this->status === 'active';
    }

    /**
     * Check if event is expired
     */
    public function isExpired(): bool
    {
        return $this->status === 'expired';
    }

    /**
     * Check if geofencing is enabled for this event
     */
    public function hasGeofence(): bool
    {
        return isset($this->settings['geofence_enabled']) && $this->settings['geofence_enabled'] === true;
    }

    /**
     * Get geofence configuration
     */
    public function getGeofence(): ?array
    {
        if (!$this->hasGeofence()) {
            return null;
        }

        return [
            'latitude' => $this->settings['geofence_latitude'] ?? null,
            'longitude' => $this->settings['geofence_longitude'] ?? null,
            'radius_meters' => $this->settings['geofence_radius'] ?? 100,
        ];
    }

    /**
     * Check if a location is within the event's geofence
     * Uses Haversine formula to calculate distance between two points
     *
     * @param float $latitude
     * @param float $longitude
     * @return bool
     */
    public function isWithinGeofence(float $latitude, float $longitude): bool
    {
        if (!$this->hasGeofence()) {
            return true; // No geofence, allow all locations
        }

        $geofence = $this->getGeofence();

        if (!$geofence['latitude'] || !$geofence['longitude']) {
            return true;
        }

        $distance = $this->calculateDistance(
            $geofence['latitude'],
            $geofence['longitude'],
            $latitude,
            $longitude
        );

        return $distance <= $geofence['radius_meters'];
    }

    /**
     * Calculate distance between two GPS coordinates in meters
     * Using Haversine formula
     *
     * @param float $lat1
     * @param float $lon1
     * @param float $lat2
     * @param float $lon2
     * @return float Distance in meters
     */
    protected function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371000; // Earth's radius in meters

        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) +
            cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));

        return $angle * $earthRadius;
    }
}
