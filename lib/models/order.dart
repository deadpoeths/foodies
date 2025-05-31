class Order {
  final int? id;
  final int customerId;
  final int dishId;
  final int quantity;
  final String status;

  Order({
    this.id,
    required this.customerId,
    required this.dishId,
    required this.quantity,
    required this.status,
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
      id: map['id'],
      customerId: map['customerId'],
      dishId: map['dishId'],
      quantity: map['quantity'],
      status: map['status'],
    );
  }
}
