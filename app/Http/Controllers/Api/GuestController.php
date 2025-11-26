<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\User;
use App\Models\EventGuest;
use App\Models\Media;
use App\Models\QrScan;
use App\Contracts\StorageServiceInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class GuestController extends Controller
{
    protected $storageService;

    public function __construct(StorageServiceInterface $storageService)
    {
        $this->storageService = $storageService;
    }

    /**
     * Scan QR and get event details
     *
     * POST /api/scan
     */
    public function scan(Request $request)
    {
        $validated = $request->validate([
            'qr_code_data' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $event = Event::where('qr_code_data', $validated['qr_code_data'])
            ->with('creator')
            ->firstOrFail();

        if ($event->status !== 'active') {
            return response()->json([
                'message' => 'This event is not active',
                'event_status' => $event->status,
            ], 403);
        }

        // Track QR scan
        $locationData = null;
        if (isset($validated['latitude']) && isset($validated['longitude'])) {
            $locationData = [
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
            ];
        }

        QrScan::create([
            'event_id' => $event->id,
            'qr_code_data' => $validated['qr_code_data'],
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'location_data' => $locationData,
            'guest_id' => $request->user() ? $request->user()->id : null,
            'scanned_at' => now(),
        ]);

        // Get geofence info if enabled
        $geofenceInfo = null;
        if ($event->hasGeofence()) {
            $geofenceInfo = $event->getGeofence();
        }

        return response()->json([
            'event' => [
                'id' => $event->id,
                'title' => $event->title,
                'description' => $event->description,
                'event_date' => $event->event_date,
                'location' => $event->location,
                'creator_name' => $event->creator->name,
                'geofence' => $geofenceInfo,
            ],
        ]);
    }

    /**
     * Join event (register guest)
     *
     * POST /api/events/{id}/join
     */
    public function join(Request $request, $id)
    {
        $event = Event::where('status', 'active')->findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|max:255',
            'phone' => 'nullable|string|max:20',
        ]);

        // Find or create guest user
        $user = User::where('email', $validated['email'])->first();

        if (!$user) {
            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'phone' => $validated['phone'] ?? null,
                'password' => null,
                'role' => 'guest',
            ]);
        }

        // Check if already joined
        $alreadyJoined = EventGuest::where('event_id', $event->id)
            ->where('guest_id', $user->id)
            ->exists();

        if (!$alreadyJoined) {
            EventGuest::create([
                'event_id' => $event->id,
                'guest_id' => $user->id,
                'joined_at' => now(),
            ]);
        }

        // Create token for guest
        $token = $user->createToken('guest-token')->plainTextToken;

        return response()->json([
            'message' => 'Successfully joined event',
            'user' => $user,
            'event' => $event,
            'token' => $token,
        ], 200);
    }

    /**
     * Upload photo/video
     *
     * POST /api/events/{id}/media
     */
    public function uploadMedia(Request $request, $id)
    {
        $event = Event::where('status', 'active')->findOrFail($id);

        // Verify user is a guest of this event
        $isGuest = EventGuest::where('event_id', $event->id)
            ->where('guest_id', $request->user()->id)
            ->exists();

        if (!$isGuest) {
            return response()->json([
                'message' => 'You must join this event before uploading media',
            ], 403);
        }

        $validated = $request->validate([
            'file' => 'required|file|mimes:jpg,jpeg,png,gif,mp4,mov,avi|max:102400', // 100MB max
            'caption' => 'nullable|string|max:500',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        // Check geofencing if enabled
        if ($event->hasGeofence()) {
            if (!isset($validated['latitude']) || !isset($validated['longitude'])) {
                return response()->json([
                    'message' => 'Location required for this event',
                    'error' => 'This event requires location data. Please enable GPS and try again.',
                ], 400);
            }

            $isWithinGeofence = $event->isWithinGeofence(
                $validated['latitude'],
                $validated['longitude']
            );

            if (!$isWithinGeofence) {
                $geofence = $event->getGeofence();
                return response()->json([
                    'message' => 'Outside event location',
                    'error' => 'You must be within ' . $geofence['radius_meters'] . ' meters of the event location to upload media.',
                    'geofence' => $geofence,
                ], 403);
            }
        }

        $file = $request->file('file');

        // Determine file type
        $mimeType = $file->getMimeType();
        $fileType = str_starts_with($mimeType, 'video/') ? 'video' : 'photo';

        // Upload to storage
        $uploadResult = $this->storageService->upload(
            $file,
            "events/{$event->id}",
            ['resource_type' => 'auto']
        );

        // Generate thumbnail for videos
        $thumbnailPath = null;
        if ($fileType === 'video') {
            $thumbnailPath = $this->storageService->generateVideoThumbnail($uploadResult['public_id']);
        }

        // Prepare metadata
        $metadata = [
            'public_id' => $uploadResult['public_id'],
            'format' => $uploadResult['format'],
            'width' => $uploadResult['width'] ?? null,
            'height' => $uploadResult['height'] ?? null,
        ];

        // Add location data if provided
        if (isset($validated['latitude']) && isset($validated['longitude'])) {
            $metadata['location'] = [
                'latitude' => $validated['latitude'],
                'longitude' => $validated['longitude'],
            ];
        }

        // Create media record
        $media = Media::create([
            'event_id' => $event->id,
            'uploader_id' => $request->user()->id,
            'file_path' => $uploadResult['url'],
            'file_type' => $fileType,
            'file_size' => $uploadResult['size'],
            'thumbnail_path' => $thumbnailPath,
            'caption' => $validated['caption'] ?? null,
            'status' => 'approved', // Auto-approve by default
            'metadata' => $metadata,
        ]);

        return response()->json([
            'message' => 'Media uploaded successfully',
            'media' => $media->load('uploader'),
        ], 201);
    }

    /**
     * Get guest's own uploads
     *
     * GET /api/events/{id}/my-media
     */
    public function getMyMedia(Request $request, $id)
    {
        $event = Event::findOrFail($id);

        $media = Media::where('event_id', $event->id)
            ->where('uploader_id', $request->user()->id)
            ->latest()
            ->paginate(20);

        return response()->json($media);
    }

    /**
     * Delete own upload
     *
     * DELETE /api/media/{id}
     */
    public function deleteMedia(Request $request, $id)
    {
        $media = Media::where('uploader_id', $request->user()->id)
            ->findOrFail($id);

        // Delete from storage
        if (isset($media->metadata['public_id'])) {
            $this->storageService->delete($media->metadata['public_id']);
        }

        $media->delete();

        return response()->json([
            'message' => 'Media deleted successfully',
        ]);
    }
}
