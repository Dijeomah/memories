<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Media extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'uploader_id',
        'file_path',
        'file_type',
        'file_size',
        'thumbnail_path',
        'caption',
        'status',
        'metadata',
    ];

    protected $casts = [
        'metadata' => 'array',
        'file_size' => 'integer',
    ];

    /**
     * The event this media belongs to
     */
    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    /**
     * The user who uploaded this media
     */
    public function uploader()
    {
        return $this->belongsTo(User::class, 'uploader_id');
    }

    /**
     * Check if media is a photo
     */
    public function isPhoto(): bool
    {
        return $this->file_type === 'photo';
    }

    /**
     * Check if media is a video
     */
    public function isVideo(): bool
    {
        return $this->file_type === 'video';
    }

    /**
     * Check if media is approved
     */
    public function isApproved(): bool
    {
        return $this->status === 'approved';
    }
}
