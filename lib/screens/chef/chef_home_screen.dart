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

  // Helper function to format status text
  String _formatStatus(String status) {
    // Split the status by underscore, capitalize each word, and join with a space
    return status
        .trim()
        .toLowerCase()
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
      body: _orders.isEmpty
          ? const Center(
        child: Text(
          'No orders yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final isPending = order.status.trim().toLowerCase() == 'pending';

          Color statusColor;
          switch (order.status.trim().toLowerCase()) {
            case 'pending':
              statusColor = Colors.orange;
              break;
            case 'accepted':
              statusColor = Colors.green;
              break;
            case 'declined':
              statusColor = Colors.red;
              break;
            case 'picked_up':
              statusColor = Colors.blue;
              break;
            case 'on_the_way':
              statusColor = Colors.purple;
              break;
            case 'delivered':
              statusColor = Colors.teal;
              break;
            default:
              statusColor = Colors.grey;
          }

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          border: Border.all(color: statusColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatStatus(order.status),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _orderDetailRow(Icons.fastfood, 'Dish:',
                      order.dishName ?? 'Unknown Dish'),
                  _orderDetailRow(Icons.format_list_numbered, 'Quantity:',
                      '${order.quantity}'),
                  _orderDetailRow(Icons.person, 'Customer:',
                      order.customerName ?? 'Unknown'),
                  _orderDetailRow(Icons.location_on, 'Address:',
                      order.customerAddress ?? 'No address provided'),
                  const SizedBox(height: 16),
                  if (isPending)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _acceptOrder(order),
                          icon: const Icon(Icons.check),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _declineOrder(order),
                          icon: const Icon(Icons.close),
                          label: const Text('Decline'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _orderDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}