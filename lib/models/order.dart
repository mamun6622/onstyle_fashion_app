import 'cart_item.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double totalAmount;
  final String shippingAddress;
  final String phoneNumber;
  final String? customerEmail;
  final String paymentMethod;
  final DateTime createdAt;
  final String status; // 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'

  OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.totalAmount,
    required this.shippingAddress,
    required this.phoneNumber,
    this.customerEmail,
    required this.paymentMethod,
    DateTime? createdAt,
    this.status = 'Processing',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_count': items.length,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'phone_number': phoneNumber,
      'customer_email': customerEmail ?? '',
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      items: const [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      shipping: (map['shipping'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: map['shipping_address']?.toString() ?? 'N/A',
      phoneNumber: map['phone_number']?.toString() ?? '',
      customerEmail: map['customer_email']?.toString(),
      paymentMethod: map['payment_method']?.toString() ?? 'Credit Card',
      status: map['status']?.toString() ?? 'Processing',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? totalAmount,
    String? shippingAddress,
    String? phoneNumber,
    String? customerEmail,
    String? paymentMethod,
    DateTime? createdAt,
    String? status,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      customerEmail: customerEmail ?? this.customerEmail,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
