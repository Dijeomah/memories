import 'subscription_plan.dart';
import 'user_subscription.dart';

class SubscriptionTransaction {
  final int id;
  final int userId;
  final int? subscriptionId;
  final int planId;
  final String reference;
  final double amount;
  final String status; // pending, success, failed, refunded
  final String type; // subscription, renewal, upgrade, downgrade
  final Map<String, dynamic>? paystackResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relationships
  final SubscriptionPlan? plan;
  final UserSubscription? subscription;

  SubscriptionTransaction({
    required this.id,
    required this.userId,
    this.subscriptionId,
    required this.planId,
    required this.reference,
    required this.amount,
    required this.status,
    required this.type,
    this.paystackResponse,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
    this.subscription,
  });

  factory SubscriptionTransaction.fromJson(Map<String, dynamic> json) {
    return SubscriptionTransaction(
      id: json['id'],
      userId: json['user_id'],
      subscriptionId: json['subscription_id'],
      planId: json['plan_id'],
      reference: json['reference'],
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      type: json['type'],
      paystackResponse: json['paystack_response'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      plan: json['plan'] != null
          ? SubscriptionPlan.fromJson(json['plan'])
          : null,
      subscription: json['subscription'] != null
          ? UserSubscription.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_id': subscriptionId,
      'plan_id': planId,
      'reference': reference,
      'amount': amount,
      'status': status,
      'type': type,
      'paystack_response': paystackResponse,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';

  String get amountDisplay => '₦${amount.toStringAsFixed(2)}';

  String get statusDisplay {
    switch (status) {
      case 'success':
        return 'Successful';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  String get typeDisplay {
    switch (type) {
      case 'subscription':
        return 'New Subscription';
      case 'renewal':
        return 'Renewal';
      case 'upgrade':
        return 'Upgrade';
      case 'downgrade':
        return 'Downgrade';
      default:
        return type;
    }
  }
}
