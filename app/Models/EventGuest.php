<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class EventGuest extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'guest_id',
        'joined_at',
    ];

    protected $casts = [
        'joined_at' => 'datetime',
    ];

    /**
     * The event this record belongs to
     */
    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    /**
     * The guest user
     */
    public function guest()
    {
        return $this->belongsTo(User::class, 'guest_id');
    }
}
