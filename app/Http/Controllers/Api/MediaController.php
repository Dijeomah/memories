<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Media;
use Illuminate\Http\Request;

class MediaController extends Controller
{
    /**
     * Get single media details
     *
     * GET /api/media/{id}
     */
    public function show(Request $request, $id)
    {
        $media = Media::with(['event', 'uploader'])->findOrFail($id);

        // Check if user has access to this media
        // Either the creator of the event or the uploader
        $user = $request->user();
        $hasAccess = $media->uploader_id === $user->id ||
                     $media->event->creator_id === $user->id;

        if (!$hasAccess) {
            return response()->json([
                'message' => 'Unauthorized to view this media',
            ], 403);
        }

        return response()->json([
            'media' => $media,
        ]);
    }

    /**
     * Moderate media (approve/reject) - Creator only
     *
     * PUT /api/media/{id}/moderate
     */
    public function moderate(Request $request, $id)
    {
        $media = Media::with('event')->findOrFail($id);

        // Verify user is the event creator
        if ($media->event->creator_id !== $request->user()->id) {
            return response()->json([
                'message' => 'Only the event creator can moderate media',
            ], 403);
        }

        $validated = $request->validate([
            'status' => 'required|in:approved,rejected,pending',
        ]);

        $media->update([
            'status' => $validated['status'],
        ]);

        return response()->json([
            'message' => 'Media status updated successfully',
            'media' => $media->fresh(),
        ]);
    }
}
