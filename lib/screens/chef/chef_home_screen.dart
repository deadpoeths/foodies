import 'package:flutter/material.dart';
import '../customer/track.dart';
import 'chef_profile.dart';
import 'chef_dishlist.dart';
import '../../db/database_helper.dart';
import '../../models/order.dart';

class ChefHomeScreen extends StatefulWidget {
  final int userId;

  const ChefHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChefHomeScreenState createState() => _ChefHomeScreenState();
}

class _ChefHomeScreenState extends State<ChefHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ChefDashboard(userId: widget.userId),
      ChefDishListPage(userId: widget.userId),
      ChefProfilePage(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFFFF8F1),
          unselectedItemColor: const Color(0xFFFFF8F1).withOpacity(0.6),
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Dishes'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class ChefDashboard extends StatefulWidget {
  final int userId;

  const ChefDashboard({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChefDashboard> createState() => _ChefDashboardState();
}

class _ChefDashboardState extends State<ChefDashboard> {
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final db = DatabaseHelper.instance;
    final orders = await db.getOrdersByChefId(widget.userId);
    setState(() => _orders = orders);
  }

  Future<void> _acceptOrder(Order order) async {
    await DatabaseHelper.instance.updateOrderStatus(order.id!, 'accepted');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order Accepted')),
    );
    await _loadOrders();
  }

  Future<void> _declineOrder(Order order) async {
    await DatabaseHelper.instance.updateOrderStatus(order.id!, 'declined');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order Declined')),
    );
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
          ),
          padding: const EdgeInsets.only(top: 24),
          child: const Center(
            child: Text(
              'Welcome, Chef!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: _orders.isEmpty
          ? const Center(
          child: Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Dish ID: ${order.dishId}'),
                  Text('Quantity: ${order.quantity}'),
                  Text('Customer ID: ${order.customerId}'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _acceptOrder(order),
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _declineOrder(order),
                        child: const Text('Decline'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
