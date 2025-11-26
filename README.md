# Memories - QR-Based Event Photo/Video Sharing Platform

A Laravel-based REST API for a QR-based event photo and video sharing platform. Event creators can generate unique QR codes, guests scan to join events, register themselves, and upload media that creators can view and download.

## Features

- **Event Management**: Create, update, and manage events with unique QR codes
- **QR Code Generation**: Automatic QR code generation for easy event access
- **Guest Registration**: Simple registration flow for event attendees
- **Media Upload**: Support for photos and videos up to 100MB
- **Cloud Storage**: Flexible storage with Cloudinary or DigitalOcean Spaces
- **Media Moderation**: Approve or reject uploaded content
- **Bulk Download**: Download all event media in one go
- **RESTful API**: Clean, well-documented API endpoints
- **Laravel Sanctum**: Secure API authentication

## Tech Stack

- **Framework**: Laravel 11.x
- **PHP**: 8.4+
- **Database**: MySQL/PostgreSQL
- **Authentication**: Laravel Sanctum
- **Cloud Storage**: Cloudinary (with DigitalOcean Spaces support)
- **QR Code**: SimpleSoftwareIO QR Code Generator
- **File Storage**: AWS S3 SDK (for DigitalOcean Spaces)

## Installation

### Prerequisites

- PHP 8.4 or higher
- Composer
- MySQL or PostgreSQL
- Cloudinary account (or DigitalOcean Spaces)

### Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd memories
```

2. **Install dependencies**
```bash
composer install
```

3. **Environment Configuration**
```bash
cp .env.example .env
php artisan key:generate
```

4. **Configure Database**

Edit `.env` file:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=memories
DB_USERNAME=root
DB_PASSWORD=your_password
```

5. **Configure Cloud Storage**

For Cloudinary (default):
```env
STORAGE_DRIVER=cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_FOLDER=memories
```

For DigitalOcean Spaces:
```env
STORAGE_DRIVER=digitalocean
DO_SPACES_KEY=your_spaces_key
DO_SPACES_SECRET=your_spaces_secret
DO_SPACES_ENDPOINT=https://nyc3.digitaloceanspaces.com
DO_SPACES_REGION=nyc3
DO_SPACES_BUCKET=your_bucket_name
```

6. **Run Migrations**
```bash
php artisan migrate
```

7. **Seed Database (Optional)**
```bash
php artisan db:seed
```

This creates:
- A creator account: `creator@memories.app` / `password`
- Sample guest users
- A sample event with QR code

8. **Start Development Server**
```bash
php artisan serve
```

The API will be available at `http://localhost:8000`

## API Documentation

Comprehensive API documentation is available in [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)

### Quick Start Examples

#### 1. Register a Creator
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

#### 2. Create an Event
```bash
curl -X POST http://localhost:8000/api/events \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Wedding Celebration",
    "description": "Join us for our special day",
    "event_date": "2025-12-01T18:00:00",
    "location": "Grand Hotel"
  }'
```

#### 3. Get QR Code
```bash
curl -X GET http://localhost:8000/api/events/1/qr \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### 4. Scan QR Code (Guest)
```bash
curl -X POST http://localhost:8000/api/scan \
  -H "Content-Type: application/json" \
  -d '{
    "qr_code_data": "QR_CODE_UUID"
  }'
```

#### 5. Join Event (Guest)
```bash
curl -X POST http://localhost:8000/api/events/1/join \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "email": "jane@example.com",
    "phone": "+1234567890"
  }'
```

#### 6. Upload Media (Guest)
```bash
curl -X POST http://localhost:8000/api/events/1/media \
  -H "Authorization: Bearer GUEST_TOKEN" \
  -F "file=@photo.jpg" \
  -F "caption=Great moment!"
```

## Project Structure

```
memories/
├── app/
│   ├── Contracts/
│   │   └── StorageServiceInterface.php    # Storage abstraction
│   ├── Http/
│   │   └── Controllers/
│   │       └── Api/
│   │           ├── AuthController.php     # Authentication endpoints
│   │           ├── EventController.php    # Event management
│   │           ├── GuestController.php    # Guest operations
│   │           └── MediaController.php    # Media management
│   ├── Models/
│   │   ├── User.php                       # User model
│   │   ├── Event.php                      # Event model
│   │   ├── EventGuest.php                 # Event-Guest pivot
│   │   └── Media.php                      # Media model
│   ├── Providers/
│   │   └── StorageServiceProvider.php     # Storage service binding
│   └── Services/
│       ├── QRCodeService.php              # QR code generation
│       └── Storage/
│           ├── CloudinaryStorageService.php
│           └── DigitalOceanStorageService.php
├── database/
│   ├── migrations/                        # Database migrations
│   └── seeders/                           # Database seeders
├── routes/
│   ├── api.php                            # API routes
│   └── web.php                            # Web routes
└── config/
    ├── cloudinary.php                     # Cloudinary config
    ├── filesystems.php                    # Storage config
    └── sanctum.php                        # Sanctum config
```

## Database Schema

### Users Table
- `id`: Primary key
- `name`: User name
- `email`: Unique email
- `phone`: Phone number (optional)
- `password`: Hashed password (nullable for guests)
- `role`: Enum (creator, guest)
- `created_at`, `updated_at`

### Events Table
- `id`: Primary key
- `creator_id`: Foreign key to users
- `title`: Event title
- `description`: Event description
- `event_date`: Date and time of event
- `location`: Event location
- `qr_code_data`: Unique QR code identifier
- `status`: Enum (draft, active, expired)
- `settings`: JSON field for event settings
- `created_at`, `updated_at`

### Event_Guests Table (Pivot)
- `id`: Primary key
- `event_id`: Foreign key to events
- `guest_id`: Foreign key to users
- `joined_at`: Timestamp when guest joined
- `created_at`, `updated_at`

### Media Table
- `id`: Primary key
- `event_id`: Foreign key to events
- `uploader_id`: Foreign key to users
- `file_path`: Storage URL
- `file_type`: Enum (photo, video)
- `file_size`: File size in bytes
- `thumbnail_path`: Thumbnail URL (for videos)
- `caption`: Optional caption
- `status`: Enum (pending, approved, rejected)
- `metadata`: JSON field for additional data
- `created_at`, `updated_at`

## API Endpoints Summary

### Authentication
- `POST /api/auth/register` - Register creator
- `POST /api/auth/login` - Login creator
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user

### Events (Creator)
- `GET /api/events` - List all events
- `POST /api/events` - Create event
- `GET /api/events/{id}` - Get event details
- `PUT /api/events/{id}` - Update event
- `DELETE /api/events/{id}` - Delete event
- `GET /api/events/{id}/qr` - Get QR code
- `GET /api/events/{id}/media` - Get event media
- `GET /api/events/{id}/guests` - Get event guests
- `POST /api/events/{id}/download` - Download media

### Guest Access
- `POST /api/scan` - Scan QR code
- `POST /api/events/{id}/join` - Join event
- `POST /api/events/{id}/media` - Upload media
- `GET /api/events/{id}/my-media` - Get own uploads
- `DELETE /api/media/{id}` - Delete own upload

### Media Management
- `GET /api/media/{id}` - Get media details
- `PUT /api/media/{id}/moderate` - Moderate media

## Testing

Run the test suite:
```bash
php artisan test
```

## Security Features

- **Sanctum Authentication**: Token-based API authentication
- **Password Hashing**: Bcrypt password hashing
- **Input Validation**: Comprehensive request validation
- **Authorization**: Role-based access control
- **File Validation**: Type and size validation for uploads
- **CORS Protection**: Configurable CORS settings
- **Rate Limiting**: API rate limiting

## Performance Considerations

- **Database Indexing**: Optimized indexes on foreign keys
- **Pagination**: All list endpoints support pagination
- **Eager Loading**: Relationships are eagerly loaded to prevent N+1 queries
- **Queue Support**: Ready for queue integration for heavy tasks

## Future Enhancements

- [ ] Real-time notifications (Pusher/WebSockets)
- [ ] Image compression and optimization
- [ ] Video transcoding
- [ ] Event analytics dashboard
- [ ] Social media sharing
- [ ] Email notifications
- [ ] Guest invite system
- [ ] Event templates
- [ ] Advanced media filters
- [ ] Mobile app (Flutter)

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is open-sourced software licensed under the MIT license.

## Support

For issues, questions, or contributions, please open an issue on GitHub.

## Credits

Developed as part of the Memories App project - A comprehensive event photo/video sharing platform.
