class Order {
  final int? id;
  final int customerId;
  final int dishId;
  final int quantity;
  late final String status;
  final String? dishName;        // New field for dish name
  final String? customerName;    // New field for customer name
  final String? customerAddress; // New field for customer address

  Order({
    this.id,
    required this.customerId,
    required this.dishId,
    required this.quantity,
    required this.status,
    this.dishName,
    this.customerName,
    this.customerAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'dishId': dishId,
      'quantity': quantity,
      'status': status,
    };
  }

  static Order fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      customerId: map['customerId'] as int,
      dishId: map['dishId'] as int,
      quantity: map['quantity'] as int,
      status: map['status'] as String,
      dishName: map['dishName'] as String?,
      customerName: map['customerName'] as String?,
      customerAddress: map['customerAddress'] as String?,
    );
  }
}