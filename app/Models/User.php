<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * Check if user is a creator
     */
    public function isCreator(): bool
    {
        return $this->role === 'creator';
    }

    /**
     * Check if user is a guest
     */
    public function isGuest(): bool
    {
        return $this->role === 'guest';
    }

    /**
     * Events created by this user
     */
    public function createdEvents()
    {
        return $this->hasMany(Event::class, 'creator_id');
    }

    /**
     * Events this user has joined as a guest
     */
    public function joinedEvents()
    {
        return $this->belongsToMany(Event::class, 'event_guests', 'guest_id', 'event_id')
            ->withTimestamps()
            ->withPivot('joined_at');
    }

    /**
     * Media uploaded by this user
     */
    public function media()
    {
        return $this->hasMany(Media::class, 'uploader_id');
    }
}
