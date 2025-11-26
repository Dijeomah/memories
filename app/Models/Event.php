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
}
