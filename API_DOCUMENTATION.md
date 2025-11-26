# Memories App - API Documentation

## Base URL
```
http://localhost:8000/api
```

## Authentication
The API uses Laravel Sanctum for authentication. Most endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer {token}
```

---

## Authentication Endpoints

### Register (Creator)
Create a new creator account.

**Endpoint:** `POST /api/auth/register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response:** `201 Created`
```json
{
  "message": "Registration successful",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "role": "creator"
  },
  "token": "1|abc123..."
}
```

---

### Login (Creator)
Login for event creators.

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:** `200 OK`
```json
{
  "message": "Login successful",
  "user": { ... },
  "token": "2|xyz789..."
}
```

---

### Logout
Logout and invalidate current token.

**Endpoint:** `POST /api/auth/logout`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "message": "Logged out successfully"
}
```

---

### Get Current User
Get authenticated user details.

**Endpoint:** `GET /api/auth/me`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "creator",
    "created_events": [...],
    "joined_events": [...],
    "media": [...]
  }
}
```

---

## Event Endpoints (Creator Only)

### List All Events
Get all events created by the authenticated user.

**Endpoint:** `GET /api/events`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "title": "Wedding Celebration",
      "description": "Join us for our special day",
      "event_date": "2025-12-01T18:00:00Z",
      "location": "Grand Hotel",
      "status": "active",
      "qr_code_data": "uuid-string",
      "media_count": 45,
      "guests_count": 23,
      "created_at": "2025-11-01T10:00:00Z"
    }
  ],
  "links": {...},
  "meta": {...}
}
```

---

### Create Event
Create a new event.

**Endpoint:** `POST /api/events`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "title": "Birthday Party",
  "description": "25th Birthday Celebration",
  "event_date": "2025-12-15T19:00:00",
  "location": "My House",
  "status": "active"
}
```

**Response:** `201 Created`
```json
{
  "message": "Event created successfully",
  "event": {
    "id": 2,
    "title": "Birthday Party",
    "description": "25th Birthday Celebration",
    "qr_code_data": "generated-uuid",
    "status": "active",
    ...
  }
}
```

---

### Get Event Details
Get details of a specific event.

**Endpoint:** `GET /api/events/{id}`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`

---

### Update Event
Update event details.

**Endpoint:** `PUT /api/events/{id}`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "title": "Updated Title",
  "status": "expired"
}
```

**Response:** `200 OK`

---

### Delete Event
Delete an event (also deletes all media and guest records).

**Endpoint:** `DELETE /api/events/{id}`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "message": "Event deleted successfully"
}
```

---

### Get QR Code
Get QR code for event.

**Endpoint:** `GET /api/events/{id}/qr`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "qr_code_data": "uuid-string",
  "scan_url": "http://localhost:8000/scan/uuid-string",
  "qr_code_base64": "data:image/png;base64,...",
  "qr_code_svg": "<svg>...</svg>"
}
```

---

### Get Event Media
Get all media uploaded to the event.

**Endpoint:** `GET /api/events/{id}/media`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK` (Paginated)

---

### Get Event Guests
Get all guests who joined the event.

**Endpoint:** `GET /api/events/{id}/guests`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK` (Paginated)

---

### Download Event Media
Get URLs for bulk downloading all event media.

**Endpoint:** `POST /api/events/{id}/download`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "message": "Media list retrieved successfully",
  "media": [
    {
      "id": 1,
      "url": "https://cloudinary.com/...",
      "filename": "photo.jpg",
      "type": "photo"
    }
  ],
  "total": 45
}
```

---

## Guest Endpoints

### Scan QR Code
Scan event QR code to get event details.

**Endpoint:** `POST /api/scan`

**Request Body:**
```json
{
  "qr_code_data": "uuid-from-qr-code"
}
```

**Response:** `200 OK`
```json
{
  "event": {
    "id": 1,
    "title": "Wedding Celebration",
    "description": "Join us for our special day",
    "event_date": "2025-12-01T18:00:00Z",
    "location": "Grand Hotel",
    "creator_name": "John Doe"
  }
}
```

---

### Join Event
Register as a guest for an event.

**Endpoint:** `POST /api/events/{id}/join`

**Request Body:**
```json
{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "phone": "+1234567890"
}
```

**Response:** `200 OK`
```json
{
  "message": "Successfully joined event",
  "user": {
    "id": 5,
    "name": "Jane Smith",
    "email": "jane@example.com",
    "role": "guest"
  },
  "event": {...},
  "token": "3|ghi456..."
}
```

---

### Upload Media
Upload a photo or video to the event.

**Endpoint:** `POST /api/events/{id}/media`

**Headers:**
- `Authorization: Bearer {token}`
- `Content-Type: multipart/form-data`

**Form Data:**
- `file`: Image or video file (max 100MB)
- `caption`: Optional caption text

**Response:** `201 Created`
```json
{
  "message": "Media uploaded successfully",
  "media": {
    "id": 10,
    "event_id": 1,
    "uploader_id": 5,
    "file_path": "https://cloudinary.com/...",
    "file_type": "photo",
    "file_size": 2048000,
    "thumbnail_path": null,
    "caption": "Great moment!",
    "status": "approved",
    "created_at": "2025-11-26T10:30:00Z"
  }
}
```

---

### Get My Uploads
Get all media uploaded by the authenticated guest.

**Endpoint:** `GET /api/events/{id}/my-media`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK` (Paginated)

---

### Delete Own Upload
Delete a media file uploaded by you.

**Endpoint:** `DELETE /api/media/{id}`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`
```json
{
  "message": "Media deleted successfully"
}
```

---

## Media Management Endpoints

### Get Media Details
Get details of a specific media file.

**Endpoint:** `GET /api/media/{id}`

**Headers:** `Authorization: Bearer {token}`

**Response:** `200 OK`

---

### Moderate Media (Creator Only)
Approve or reject uploaded media.

**Endpoint:** `PUT /api/media/{id}/moderate`

**Headers:** `Authorization: Bearer {token}`

**Request Body:**
```json
{
  "status": "approved"
}
```

**Possible statuses:** `approved`, `rejected`, `pending`

**Response:** `200 OK`
```json
{
  "message": "Media status updated successfully",
  "media": {...}
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "message": "Validation failed",
  "errors": {
    "email": ["The email field is required."]
  }
}
```

### 401 Unauthorized
```json
{
  "message": "Unauthenticated."
}
```

### 403 Forbidden
```json
{
  "message": "You must join this event before uploading media"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 500 Server Error
```json
{
  "message": "Server error occurred"
}
```

---

## File Upload Specifications

### Supported Image Formats
- JPG/JPEG
- PNG
- GIF

### Supported Video Formats
- MP4
- MOV
- AVI

### File Size Limits
- Maximum: 100MB per file

---

## Rate Limiting
API requests are rate-limited to prevent abuse. Default limits:
- 60 requests per minute for authenticated users
- 10 requests per minute for unauthenticated endpoints

---

## Cloud Storage Configuration

The API supports two storage drivers:

### Cloudinary (Default)
Set in `.env`:
```env
STORAGE_DRIVER=cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
CLOUDINARY_FOLDER=memories
```

### DigitalOcean Spaces
Set in `.env`:
```env
STORAGE_DRIVER=digitalocean
DO_SPACES_KEY=your_spaces_key
DO_SPACES_SECRET=your_spaces_secret
DO_SPACES_ENDPOINT=https://nyc3.digitaloceanspaces.com
DO_SPACES_REGION=nyc3
DO_SPACES_BUCKET=your_bucket_name
```

---

## Database Setup

1. Create MySQL database:
```sql
CREATE DATABASE memories;
```

2. Configure `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=memories
DB_USERNAME=root
DB_PASSWORD=your_password
```

3. Run migrations:
```bash
php artisan migrate
```

---

## Testing with Postman/Insomnia

Import the following base configuration:
- Base URL: `http://localhost:8000/api`
- Add Authorization header for protected endpoints
- Use form-data for file uploads

---

## Support & Contact

For issues and questions, please open an issue on the GitHub repository.
