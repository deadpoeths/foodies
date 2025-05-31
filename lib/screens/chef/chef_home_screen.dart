import 'package:flutter/material.dart';
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
    final orders = await db.getOrderByChefId(widget.userId);
    setState(() => _orders = orders as List<Order>);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      appBar: AppBar(
        title: const Text('Welcome, Chef!', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
      ),
      body: _orders.isEmpty
          ? const Center(
          child: Text('No orders yet',
              style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text('Order #${order.id}'),
              subtitle: Text('Dish ID: ${order.dishId}\nQuantity: ${order.quantity}'),
              trailing: Text('Customer ID: ${order.customerId}'),
            ),
          );
        },
      ),
    );
  }
}
