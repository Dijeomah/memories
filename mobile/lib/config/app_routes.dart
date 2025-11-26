class AppRoutes {
  static const String splash = '/';
  static const String guestWelcome = '/guest-welcome';
  static const String login = '/login';
  static const String register = '/register';

  // Main navigation (Creator)
  static const String home = '/home';
  static const String events = '/events';
  static const String createEvent = '/events/create';
  static const String editEvent = '/events/edit';
  static const String eventDetail = '/events/detail';
  static const String eventQR = '/events/qr';
  static const String eventGuests = '/events/guests';
  static const String eventMedia = '/events/media';
  static const String eventAnalytics = '/events/analytics';

  // Guest flow
  static const String scanQR = '/scan';
  static const String guestJoin = '/guest/join';
  static const String guestEvent = '/guest/event';

  // Media
  static const String mediaViewer = '/media/viewer';
  static const String mediaUpload = '/media/upload';
  static const String gallery = '/gallery';

  // Subscription
  static const String subscription = '/subscription';
  static const String plans = '/subscription/plans';
  static const String payment = '/subscription/payment';
  static const String transactions = '/subscription/transactions';

  // Profile
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Additional
  static const String notifications = '/notifications';
  static const String help = '/help';
}
