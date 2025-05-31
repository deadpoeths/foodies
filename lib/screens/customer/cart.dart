import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../models/order.dart';
import '../../db/database_helper.dart';

class CartPage extends StatefulWidget {
  final int customerId;
  const CartPage({super.key, required this.customerId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartModel cart = CartModel();

  void _increase(CartItem item) {
    setState(() => cart.increaseQuantity(item.dish));
  }

  void _decrease(CartItem item) {
    setState(() => cart.decreaseQuantity(item.dish));
  }

  Future<void> _confirmOrder() async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    final db = DatabaseHelper.instance;

    for (final item in cart.items) {
      final order = Order(
        customerId: widget.customerId,
        dishId: item.dish.id!,
        quantity: item.quantity,
        status: 'Pending',
      );
      await db.insertOrder(order);
    }

    setState(() => cart.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order confirmed!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = cart.items;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: items.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(item.dish.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.dish.description),
                  const SizedBox(height: 4),
                  Text("PKR ${item.dish.price.toStringAsFixed(2)}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _decrease(item),
                  ),
                  Text(item.quantity.toString(), style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _increase(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ElevatedButton(
          onPressed: _confirmOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("Confirm Order", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
