<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckSubscriptionLimits
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @param  string  $limitType  The type of limit to check (events, storage, guests, media)
     */
    public function handle(Request $request, Closure $next, string $limitType): Response
    {
        $user = $request->user();

        // Allow if no user (will be caught by auth middleware)
        if (!$user) {
            return $next($request);
        }

        // Get user's current plan
        $plan = $user->currentPlan();

        // If no plan, deny access (user should have at least free plan)
        if (!$plan) {
            return response()->json([
                'message' => 'No active subscription plan found',
                'error' => 'Please subscribe to a plan to continue',
            ], 403);
        }

        // Check the specific limit type
        switch ($limitType) {
            case 'events':
                return $this->checkEventLimit($user, $plan);

            case 'storage':
                return $this->checkStorageLimit($user, $plan, $request);

            case 'guests':
                return $this->checkGuestLimit($user, $plan, $request);

            case 'media':
                return $this->checkMediaLimit($user, $plan, $request);

            default:
                // Unknown limit type, allow request
                return $next($request);
        }
    }

    /**
     * Check if user can create more events
     */
    protected function checkEventLimit($user, $plan)
    {
        // Unlimited events
        if ($plan->hasUnlimitedEvents()) {
            return response()->json(['check' => 'passed']);
        }

        $eventCount = $user->createdEvents()->count();

        if ($eventCount >= $plan->max_events) {
            return response()->json([
                'message' => 'Event limit reached',
                'error' => "Your {$plan->name} plan allows {$plan->max_events} event(s). Please upgrade to create more events.",
                'current_count' => $eventCount,
                'limit' => $plan->max_events,
            ], 403);
        }

        return response()->json(['check' => 'passed']);
    }

    /**
     * Check if user has enough storage space
     */
    protected function checkStorageLimit($user, $plan, $request)
    {
        // Get file size from request
        $file = $request->file('file') ?? $request->file('media');

        if (!$file) {
            return response()->json(['check' => 'passed']);
        }

        $fileSize = $file->getSize();
        $currentUsage = $user->totalStorageUsed();
        $limit = $plan->getStorageLimitBytes();

        if (($currentUsage + $fileSize) > $limit) {
            $limitMB = $plan->storage_limit_mb;
            $currentUsageMB = round($currentUsage / (1024 * 1024), 2);

            return response()->json([
                'message' => 'Storage limit exceeded',
                'error' => "Your {$plan->name} plan allows {$limitMB}MB of storage. Please upgrade for more space.",
                'current_usage_mb' => $currentUsageMB,
                'limit_mb' => $limitMB,
            ], 403);
        }

        return response()->json(['check' => 'passed']);
    }

    /**
     * Check if event can accept more guests
     */
    protected function checkGuestLimit($user, $plan, $request)
    {
        // Get event from request
        $eventId = $request->route('event') ?? $request->input('event_id');

        if (!$eventId) {
            return response()->json(['check' => 'passed']);
        }

        $event = $user->createdEvents()->find($eventId);

        if (!$event) {
            return response()->json(['check' => 'passed']);
        }

        $guestCount = $event->guests()->count();

        if ($guestCount >= $plan->max_guests_per_event) {
            return response()->json([
                'message' => 'Guest limit reached',
                'error' => "Your {$plan->name} plan allows {$plan->max_guests_per_event} guests per event. Please upgrade for more capacity.",
                'current_count' => $guestCount,
                'limit' => $plan->max_guests_per_event,
            ], 403);
        }

        return response()->json(['check' => 'passed']);
    }

    /**
     * Check if event can accept more media uploads
     */
    protected function checkMediaLimit($user, $plan, $request)
    {
        // Unlimited media
        if ($plan->max_media_per_event === -1) {
            return response()->json(['check' => 'passed']);
        }

        // Get event from request
        $eventId = $request->route('event') ?? $request->input('event_id');

        if (!$eventId) {
            return response()->json(['check' => 'passed']);
        }

        $event = $user->createdEvents()->find($eventId);

        if (!$event) {
            return response()->json(['check' => 'passed']);
        }

        $mediaCount = $event->media()->count();

        if ($mediaCount >= $plan->max_media_per_event) {
            return response()->json([
                'message' => 'Media limit reached',
                'error' => "Your {$plan->name} plan allows {$plan->max_media_per_event} media items per event. Please upgrade for unlimited uploads.",
                'current_count' => $mediaCount,
                'limit' => $plan->max_media_per_event,
            ], 403);
        }

        return response()->json(['check' => 'passed']);
    }
}
