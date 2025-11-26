class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final String currency;
  final String billingPeriod;
  final int maxEvents;
  final int maxGuestsPerEvent;
  final int storageLimitMb;
  final int maxMediaPerEvent;
  final List<String> features;
  final bool isActive;
  final bool isFeatured;
  final String? paystackPlanCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.maxEvents,
    required this.maxGuestsPerEvent,
    required this.storageLimitMb,
    required this.maxMediaPerEvent,
    required this.features,
    required this.isActive,
    required this.isFeatured,
    this.paystackPlanCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      currency: json['currency'],
      billingPeriod: json['billing_period'],
      maxEvents: json['max_events'],
      maxGuestsPerEvent: json['max_guests_per_event'],
      storageLimitMb: json['storage_limit_mb'],
      maxMediaPerEvent: json['max_media_per_event'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : [],
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      paystackPlanCode: json['paystack_plan_code'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'currency': currency,
      'billing_period': billingPeriod,
      'max_events': maxEvents,
      'max_guests_per_event': maxGuestsPerEvent,
      'storage_limit_mb': storageLimitMb,
      'max_media_per_event': maxMediaPerEvent,
      'features': features,
      'is_active': isActive,
      'is_featured': isFeatured,
      'paystack_plan_code': paystackPlanCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isFree => price == 0 || slug == 'free';
  bool get hasUnlimitedEvents => maxEvents == -1;
  bool get hasUnlimitedMedia => maxMediaPerEvent == -1;
  bool get hasUnlimitedGuests => maxGuestsPerEvent == -1;

  String get storageLimitDisplay {
    if (storageLimitMb >= 1024) {
      return '${(storageLimitMb / 1024).toStringAsFixed(0)}GB';
    }
    return '${storageLimitMb}MB';
  }

  String get priceDisplay {
    if (isFree) return 'Free';
    return '₦${price.toStringAsFixed(0)}';
  }
}
