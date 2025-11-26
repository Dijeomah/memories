<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create a creator user
        $creator = User::create([
            'name' => 'John Creator',
            'email' => 'creator@memories.app',
            'password' => bcrypt('password'),
            'role' => 'creator',
            'phone' => '+1234567890',
        ]);

        // Create some guest users
        $guest1 = User::create([
            'name' => 'Jane Guest',
            'email' => 'guest1@example.com',
            'password' => null,
            'role' => 'guest',
            'phone' => '+1234567891',
        ]);

        $guest2 = User::create([
            'name' => 'Bob Guest',
            'email' => 'guest2@example.com',
            'password' => null,
            'role' => 'guest',
            'phone' => '+1234567892',
        ]);

        // Create an event
        $event = \App\Models\Event::create([
            'creator_id' => $creator->id,
            'title' => 'Sample Wedding Event',
            'description' => 'A beautiful wedding celebration',
            'event_date' => now()->addDays(30),
            'location' => 'Grand Hotel Ballroom',
            'qr_code_data' => \Illuminate\Support\Str::uuid()->toString(),
            'status' => 'active',
            'settings' => [
                'moderation_enabled' => false,
                'max_upload_per_guest' => 20,
            ],
        ]);

        // Join guests to event
        \App\Models\EventGuest::create([
            'event_id' => $event->id,
            'guest_id' => $guest1->id,
            'joined_at' => now(),
        ]);

        \App\Models\EventGuest::create([
            'event_id' => $event->id,
            'guest_id' => $guest2->id,
            'joined_at' => now(),
        ]);

        $this->command->info('Database seeded successfully!');
        $this->command->info('Creator: creator@memories.app / password');
        $this->command->info("Event QR Code: {$event->qr_code_data}");
    }
}
