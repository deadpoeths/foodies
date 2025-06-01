import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/order.dart';
import '../../models/user.dart';

class TrackOrderPage extends StatefulWidget {
  final int customerId;

  TrackOrderPage({required this.customerId});

  @override
  _TrackOrderPageState createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> {
  List<Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadAndTrackOrders();
  }

  Future<void> _loadAndTrackOrders() async {
    final db = DatabaseHelper.instance;
    final allOrders = await db.getAllOrders();
    final filtered = allOrders.where((o) => o.customerId == widget.customerId).toList();

    setState(() => _orders = filtered);

    for (Order order in filtered) {
      if (order.status == 'accepted') {
        _startTracking(order);
      }
    }
  }

  void _startTracking(Order order) async {
    final db = DatabaseHelper.instance;

    Future<void> updateStatus(String newStatus, int delayInSeconds) async {
      await Future.delayed(Duration(seconds: delayInSeconds));
      await db.updateOrderStatus(order.id!, newStatus);

      setState(() {
        final index = _orders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          _orders[index].status = newStatus;
        }
      });
    }

    await updateStatus('picked_up', 30);
    await updateStatus('on_the_way', 30);
    await updateStatus('delivered', 30);
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icon(Icons.restaurant, color: Colors.orange, size: 32);
      case 'picked_up':
        return Icon(Icons.delivery_dining, color: Colors.blue, size: 32);
      case 'on_the_way':
        return Icon(Icons.directions_bike, color: Colors.green, size: 32);
      case 'delivered':
        return Icon(Icons.check_circle, color: Colors.teal, size: 32);
      default:
        return Icon(Icons.pending, color: Colors.grey, size: 32);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Chef is preparing meal';
      case 'picked_up':
        return 'Rider picked up your order';
      case 'on_the_way':
        return 'Rider is on the way';
      case 'delivered':
        return 'Order delivered';
      default:
        return 'Pending...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _orders.isEmpty
          ? Center(child: Text('No orders found.'))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: _getStatusIcon(order.status),
              title: Text('Order #${order.id}'),
              subtitle: Text(_getStatusText(order.status)),
            ),
          );
        },
      ),
    );
  }
}
