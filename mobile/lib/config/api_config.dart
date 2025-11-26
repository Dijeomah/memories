import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.198:8000/api';
  static final String paystackPublicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';

  // API Endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';

  static const String events = '/events';
  static String eventDetail(int id) => '/events/$id';
  static String eventQr(int id) => '/events/$id/qr';
  static String eventMedia(int id) => '/events/$id/media';
  static String eventGuests(int id) => '/events/$id/guests';
  static String eventDownload(int id) => '/events/$id/download';
  static String eventScans(int id) => '/events/$id/scans';
  static String eventScanStats(int id) => '/events/$id/scans/stats';

  static const String scan = '/scan';
  static String joinEvent(int id) => '/events/$id/join';
  static String uploadMedia(int id) => '/events/$id/media';
  static String myMedia(int id) => '/events/$id/my-media';

  static const String subscriptionPlans = '/subscription/plans';
  static const String subscription = '/subscription';
  static const String subscribe = '/subscription/subscribe';
  static const String upgradeSubscription = '/subscription/upgrade';
  static const String cancelSubscription = '/subscription/cancel';
  static const String transactions = '/subscription/transactions';
  static String verifyPayment(String reference) => '/payment/verify/$reference';

  static const String webhookPaystack = '/webhook/paystack';

  static String mediaDetail(int id) => '/media/$id';
  static String moderateMedia(int id) => '/media/$id/moderate';
  static String deleteMedia(int id) => '/media/$id';

  // Request headers
  static Map<String, String> headers({String? token}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Map<String, String> multipartHeaders({String? token}) {
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
