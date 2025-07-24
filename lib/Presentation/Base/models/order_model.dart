class OrderModel {
  final int id;
  final String customerName;
  final String status;
  final List<OrderItemModel> items;
  final int total;
  final String createdAt;
  final String? confirmedAt;
  final String? cancelReason;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? note;
  final String? paymentMethod;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
    this.confirmedAt,
    this.cancelReason,
    this.fullName,
    this.phone,
    this.address,
    this.note,
    this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerName: json['customer_name'],
      status: json['status'],
      total: json['total'],
      items: (json['items'] as List)
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      createdAt: json['created_at'],
      confirmedAt: json['confirmed_at'],
      cancelReason: json['cancel_reason'],
      fullName: json['full_name'],
      phone: json['phone'],
      address: json['address'],
      note: json['note'],
      paymentMethod: json['payment_method'],
    );
  }

  OrderModel copyWith({
    int? id,
    String? customerName,
    String? status,
    List<OrderItemModel>? items,
    int? total,
    String? createdAt,
    String? confirmedAt,
    String? cancelReason,
    String? fullName,
    String? phone,
    String? address,
    String? note,
    String? paymentMethod,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelReason: cancelReason ?? this.cancelReason,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class OrderItemModel {
  final String foodName;
  final int quantity;
  final int price;

  OrderItemModel({
    required this.foodName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      foodName: json['food_name'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
} 