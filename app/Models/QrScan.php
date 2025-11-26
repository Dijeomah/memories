<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class QrScan extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'qr_code_data',
        'ip_address',
        'user_agent',
        'location_data',
        'guest_id',
        'scanned_at',
    ];

    protected $casts = [
        'location_data' => 'array',
        'scanned_at' => 'datetime',
    ];

    /**
     * The event that was scanned
     */
    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    /**
     * The guest who scanned (if they joined)
     */
    public function guest()
    {
        return $this->belongsTo(User::class, 'guest_id');
    }
}
