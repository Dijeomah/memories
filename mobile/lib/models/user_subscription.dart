import 'subscription_plan.dart';

class UserSubscription {
  final int id;
  final int userId;
  final int planId;
  final String status; // active, cancelled, expired, trial
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? trialEndsAt;
  final DateTime? cancelledAt;
  final String? paystackSubscriptionCode;
  final String? paystackCustomerCode;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relationships
  final SubscriptionPlan? plan;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    this.startsAt,
    this.endsAt,
    this.trialEndsAt,
    this.cancelledAt,
    this.paystackSubscriptionCode,
    this.paystackCustomerCode,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      status: json['status'],
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'])
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'])
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      paystackSubscriptionCode: json['paystack_subscription_code'],
      paystackCustomerCode: json['paystack_customer_code'],
      autoRenew: json['auto_renew'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      plan: json['plan'] != null
          ? SubscriptionPlan.fromJson(json['plan'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'status': status,
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'paystack_subscription_code': paystackSubscriptionCode,
      'paystack_customer_code': paystackCustomerCode,
      'auto_renew': autoRenew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => status == 'expired';
  bool get isTrial => status == 'trial';

  bool get isExpiringSoon {
    if (endsAt == null) return false;
    final daysUntilExpiry = endsAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
  }

  int get daysUntilExpiry {
    if (endsAt == null) return -1;
    return endsAt!.difference(DateTime.now()).inDays;
  }
}
