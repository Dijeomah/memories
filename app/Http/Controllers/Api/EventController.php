<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\QrScan;
use App\Services\QRCodeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;
use ZipArchive;

class EventController extends Controller
{
    protected $qrCodeService;

    public function __construct(QRCodeService $qrCodeService)
    {
        $this->qrCodeService = $qrCodeService;
    }

    /**
     * List all creator's events
     *
     * GET /api/events
     */
    public function index(Request $request)
    {
        $events = $request->user()
            ->createdEvents()
            ->withCount(['media', 'guests'])
            ->latest()
            ->paginate(15);

        return response()->json($events);
    }

    /**
     * Create new event
     *
     * POST /api/events
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'event_date' => 'nullable|date',
            'location' => 'nullable|string|max:255',
            'status' => 'nullable|in:draft,active,expired',
            'settings' => 'nullable|array',
        ]);

        $event = Event::create([
            'creator_id' => $request->user()->id,
            'title' => $validated['title'],
            'description' => $validated['description'] ?? null,
            'event_date' => $validated['event_date'] ?? null,
            'location' => $validated['location'] ?? null,
            'qr_code_data' => $this->qrCodeService->generateUniqueCode(),
            'status' => $validated['status'] ?? 'active',
            'settings' => $validated['settings'] ?? null,
        ]);

        return response()->json([
            'message' => 'Event created successfully',
            'event' => $event->load('creator'),
        ], 201);
    }

    /**
     * Get single event details
     *
     * GET /api/events/{id}
     */
    public function show(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->withCount(['media', 'guests'])
            ->findOrFail($id);

        return response()->json([
            'event' => $event->load(['creator', 'media', 'guests']),
        ]);
    }

    /**
     * Update event
     *
     * PUT /api/events/{id}
     */
    public function update(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'event_date' => 'nullable|date',
            'location' => 'nullable|string|max:255',
            'status' => 'nullable|in:draft,active,expired',
            'settings' => 'nullable|array',
        ]);

        $event->update($validated);

        return response()->json([
            'message' => 'Event updated successfully',
            'event' => $event->fresh()->load('creator'),
        ]);
    }

    /**
     * Delete event
     *
     * DELETE /api/events/{id}
     */
    public function destroy(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        $event->delete();

        return response()->json([
            'message' => 'Event deleted successfully',
        ]);
    }

    /**
     * Generate/get QR code
     *
     * GET /api/events/{id}/qr
     */
    public function getQRCode(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        $scanUrl = $this->qrCodeService->getScanUrl($event->qr_code_data);
        $qrCodeImage = $this->qrCodeService->generate($scanUrl);
        $qrCodeSvg = $this->qrCodeService->generateSvg($scanUrl);

        return response()->json([
            'qr_code_data' => $event->qr_code_data,
            'scan_url' => $scanUrl,
            'qr_code_base64' => 'data:image/png;base64,' . $qrCodeImage,
            'qr_code_svg' => $qrCodeSvg,
        ]);
    }

    /**
     * Get all event media
     *
     * GET /api/events/{id}/media
     */
    public function getMedia(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        $media = $event->media()
            ->with('uploader')
            ->latest()
            ->paginate(20);

        return response()->json($media);
    }

    /**
     * Get all contributors/guests
     *
     * GET /api/events/{id}/guests
     */
    public function getGuests(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        $guests = $event->guests()
            ->withCount('media')
            ->withPivot('joined_at')
            ->latest('event_guests.joined_at')
            ->paginate(20);

        return response()->json($guests);
    }

    /**
     * Bulk download all media
     *
     * POST /api/events/{id}/download
     */
    public function downloadMedia(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        $media = $event->media()->get();

        if ($media->isEmpty()) {
            return response()->json([
                'message' => 'No media to download',
            ], 404);
        }

        // This should be queued for large sets
        // For now, return URLs for client-side download
        $mediaUrls = $media->map(function ($item) {
            return [
                'id' => $item->id,
                'url' => $item->file_path,
                'filename' => basename($item->file_path),
                'type' => $item->file_type,
            ];
        });

        return response()->json([
            'message' => 'Media list retrieved successfully',
            'media' => $mediaUrls,
            'total' => $media->count(),
        ]);
    }

    /**
     * Get QR scan history
     *
     * GET /api/events/{id}/scans
     */
    public function getQRScans(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        $scans = $event->qrScans()
            ->with('guest:id,name,email')
            ->latest('scanned_at')
            ->paginate(50);

        return response()->json($scans);
    }

    /**
     * Get QR scan statistics
     *
     * GET /api/events/{id}/scans/stats
     */
    public function getQRScanStats(Request $request, $id)
    {
        $event = Event::where('creator_id', $request->user()->id)
            ->findOrFail($id);

        // Total scans
        $totalScans = $event->qrScans()->count();

        // Unique scanners (based on IP)
        $uniqueScanners = $event->qrScans()
            ->distinct('ip_address')
            ->count('ip_address');

        // Scans with location data
        $scansWithLocation = $event->qrScans()
            ->whereNotNull('location_data')
            ->count();

        // Scans by registered guests
        $scansByGuests = $event->qrScans()
            ->whereNotNull('guest_id')
            ->distinct('guest_id')
            ->count('guest_id');

        // Scans over time (last 30 days)
        $scansOverTime = $event->qrScans()
            ->where('scanned_at', '>=', now()->subDays(30))
            ->select(DB::raw('DATE(scanned_at) as date'), DB::raw('count(*) as count'))
            ->groupBy('date')
            ->orderBy('date', 'asc')
            ->get();

        // Top locations (if location data exists)
        $topLocations = $event->qrScans()
            ->whereNotNull('location_data')
            ->select('location_data')
            ->get()
            ->map(function ($scan) {
                return $scan->location_data;
            })
            ->filter()
            ->take(10);

        // Most active hours
        $scansbyHour = $event->qrScans()
            ->select(DB::raw('HOUR(scanned_at) as hour'), DB::raw('count(*) as count'))
            ->groupBy('hour')
            ->orderBy('count', 'desc')
            ->get();

        return response()->json([
            'total_scans' => $totalScans,
            'unique_scanners' => $uniqueScanners,
            'scans_with_location' => $scansWithLocation,
            'scans_by_registered_guests' => $scansByGuests,
            'conversion_rate' => $totalScans > 0 ? round(($scansByGuests / $totalScans) * 100, 2) : 0,
            'scans_over_time' => $scansOverTime,
            'scans_by_hour' => $scansbyHour,
            'top_locations' => $topLocations,
        ]);
    }
}
