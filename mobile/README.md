# Memories Mobile App (Flutter)

A QR-based event photo/video sharing platform built with Flutter.

## Features

- **Authentication**: Register, login with email/password
- **Event Management**: Create, edit, view events with QR codes
- **QR Code**: Scan QR to join events, generate QR for events
- **Media Upload**: Photo and video uploads with geolocation
- **Geofencing**: Location-based upload restrictions
- **Subscription**: Multi-tier plans (Free/Pro/Enterprise) with Paystack
- **Analytics**: QR scan tracking, event statistics
- **Offline Support**: Local storage with sync

## Project Structure

```
mobile/
├── lib/
│   ├── config/          # App configuration (API, theme, routes)
│   ├── models/          # Data models
│   ├── services/        # API and business logic services
│   ├── providers/       # State management (Provider pattern)
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable widgets
│   ├── utils/           # Utility functions and helpers
│   └── main.dart        # App entry point
├── assets/              # Images, fonts, icons
├── .env                 # Environment variables
└── pubspec.yaml         # Dependencies

## Setup

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / Xcode
- Physical device or emulator

### Installation

1. Install Flutter dependencies:
```bash
cd mobile
flutter pub get
```

2. Configure environment:
```bash
# Edit .env file
API_BASE_URL=http://your-backend-url/api
PAYSTACK_PUBLIC_KEY=pk_test_xxxxx
GOOGLE_MAPS_API_KEY=xxxxx
```

3. Run the app:
```bash
flutter run
```

## Dependencies

### Core
- **provider**: State management
- **http/dio**: API communication
- **shared_preferences**: Local storage
- **flutter_secure_storage**: Secure token storage

### Features
- **qr_code_scanner**: QR code scanning
- **qr_flutter**: QR code generation
- **image_picker**: Photo/video selection
- **video_player**: Video playback
- **cached_network_image**: Image caching
- **geolocator**: GPS location
- **google_maps_flutter**: Map integration
- **flutter_paystack**: Payment processing

### UI
- **shimmer**: Loading placeholders
- **pull_to_refresh**: Refresh functionality
- **photo_view**: Image viewer

## Architecture

### State Management
Using **Provider** pattern for app-wide state:
- `AuthProvider`: User authentication state
- `EventProvider`: Event data and operations
- `SubscriptionProvider`: Subscription and payment state

### API Layer
Services handle all API communication:
- `ApiService`: Base HTTP client
- `AuthService`: Authentication API calls
- `EventService`: Event management API
- `MediaService`: Media upload/download
- `SubscriptionService`: Payment and subscription

### Models
Dart classes representing API data:
- `User`, `Event`, `Media`, `Guest`
- `SubscriptionPlan`, `UserSubscription`, `Transaction`
- `QrScan`, `EventAnalytics`

## Key Screens

### Authentication
- **Splash Screen**: App initialization
- **Login Screen**: User login
- **Register Screen**: Creator registration

### Creator Flow
- **Home Screen**: Dashboard with events list
- **Create Event Screen**: Event creation form with geofence
- **Event Detail Screen**: Event info, QR code, media, guests
- **Event Analytics Screen**: QR scans, statistics, charts

### Guest Flow
- **Scan QR Screen**: Camera QR scanner
- **Join Event Screen**: Guest registration
- **Upload Media Screen**: Photo/video upload with location check
- **Gallery Screen**: View uploaded media

### Subscription
- **Subscription Screen**: Current plan and usage
- **Plans Screen**: Available plans with features
- **Payment Screen**: Paystack integration
- **Transactions Screen**: Payment history

### Profile
- **Profile Screen**: User info, settings
- **Settings Screen**: App preferences

## API Integration

### Base URL Configuration
```dart
// lib/config/api_config.dart
static final String baseUrl = dotenv.env['API_BASE_URL'];
```

### Authentication Header
```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

### Example API Call
```dart
final response = await http.post(
  Uri.parse('${ApiConfig.baseUrl}/auth/login'),
  headers: ApiConfig.headers(),
  body: jsonEncode({'email': email, 'password': password}),
);
```

## Geofencing Implementation

```dart
// Check if within geofence before upload
final position = await Geolocator.getCurrentPosition();
final distance = Geolocator.distanceBetween(
  position.latitude,
  position.longitude,
  event.geofenceLatitude,
  event.geofenceLongitude,
);

if (distance > event.geofenceRadius) {
  // Show error: Outside event location
}
```

## QR Code Features

### Generate QR Code
```dart
QrImage(
  data: event.qrCodeData,
  version: QrVersions.auto,
  size: 300.0,
)
```

### Scan QR Code
```dart
QRView(
  key: qrKey,
  onQRViewCreated: _onQRViewCreated,
  overlay: QrScannerOverlayShape(),
)
```

## Payment Integration

```dart
// Initialize Paystack payment
final charge = Charge()
  ..amount = plan.price * 100 // Convert to kobo
  ..reference = transaction.reference
  ..email = user.email;

final response = await PaystackPlugin.checkout(context, charge: charge);

if (response.status) {
  // Verify payment with backend
  await _subscriptionService.verifyPayment(response.reference);
}
```

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Deployment

### Android
1. Configure signing in `android/app/build.gradle`
2. Build release: `flutter build appbundle`
3. Upload to Google Play Console

### iOS
1. Configure signing in Xcode
2. Build release: `flutter build ios`
3. Upload to App Store Connect

## Environment Variables

Required in `.env`:
- `API_BASE_URL`: Backend API URL
- `PAYSTACK_PUBLIC_KEY`: Paystack public key
- `GOOGLE_MAPS_API_KEY`: Google Maps API key (optional)

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for QR code scanning and photo capture</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required to upload photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access is required for geofencing</string>
```

## Next Steps

To complete the mobile app, implement:

1. **Models** (`lib/models/`):
   - user.dart, event.dart, media.dart, subscription.dart

2. **Services** (`lib/services/`):
   - api_service.dart, auth_service.dart, event_service.dart
   - media_service.dart, subscription_service.dart

3. **Providers** (`lib/providers/`):
   - auth_provider.dart, event_provider.dart, subscription_provider.dart

4. **Screens** (`lib/screens/`):
   - All screens referenced in main.dart

5. **Widgets** (`lib/widgets/`):
   - Reusable components (buttons, cards, forms)

6. **Utils** (`lib/utils/`):
   - validators.dart, formatters.dart, constants.dart

## Support

For issues or questions, please refer to the main project documentation.

## License

Copyright © 2024 Memories App
