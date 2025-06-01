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
  final Set<int> _trackingOrders = {};

  @override
  void initState() {
    super.initState();
    _loadAndTrackOrders();
  }

  Future<void> _loadAndTrackOrders() async {
    final db = DatabaseHelper.instance;
    final allOrders = await db.getAllOrders();
    final filtered = allOrders.where((o) => o.customerId == widget.customerId).toList();

    if (mounted) {
      setState(() => _orders = filtered);
    }
    print('Loaded orders: ${filtered.map((o) => 'ID: ${o.id}, Status: ${o.status}').toList()}');

    for (Order order in filtered) {
      if (order.status == 'accepted' && !_trackingOrders.contains(order.id)) {
        print('Starting tracking for order ${order.id}');
        _trackingOrders.add(order.id!);
        _startTracking(order);
      }
    }

    Future.doWhile(() async {
      if (!mounted) return false;
      final updatedOrders = await db.getAllOrders();
      final newFiltered = updatedOrders.where((o) => o.customerId == widget.customerId).toList();

      for (Order order in newFiltered) {
        if (order.status == 'accepted' && !_trackingOrders.contains(order.id)) {
          print('Starting tracking for order ${order.id}');
          _trackingOrders.add(order.id!);
          _startTracking(order);
        } else if (order.status == 'declined' && !_trackingOrders.contains(order.id)) {
          print('Order ${order.id} declined by chef');
          _trackingOrders.add(order.id!); // Prevent further tracking
          if (mounted) {
            setState(() {
              final index = _orders.indexWhere((o) => o.id == order.id);
              if (index != -1) {
                _orders[index] = Order(
                  id: order.id,
                  customerId: order.customerId,
                  dishId: order.dishId,
                  quantity: order.quantity,
                  status: 'declined',
                );
              }
            });
          }
        }
      }
      if (mounted) {
        setState(() => _orders = newFiltered);
      }
      await Future.delayed(Duration(seconds: 5));
      return mounted;
    });
  }

  Future<void> _startTracking(Order order) async {
    final db = DatabaseHelper.instance;

    Future<bool> updateStatus(String newStatus, int delayInSeconds) async {
      await Future.delayed(Duration(seconds: delayInSeconds));
      if (!mounted) return false;
      print('Attempting to update order ${order.id} to $newStatus');
      try {
        int rowsAffected = await db.updateOrderStatus(order.id!, newStatus);
        if (rowsAffected > 0) {
          print('Updated order ${order.id} to $newStatus');
          if (mounted) {
            setState(() {
              final index = _orders.indexWhere((o) => o.id == order.id);
              if (index != -1) {
                _orders[index] = Order(
                  id: order.id,
                  customerId: order.customerId,
                  dishId: order.dishId,
                  quantity: order.quantity,
                  status: newStatus,
                );
              }
            });
          }
          return true;
        } else {
          print('No rows affected for order ${order.id} to $newStatus');
          return false;
        }
      } catch (e) {
        print('Error updating order ${order.id} to $newStatus: $e');
        return false;
      }
    }

    bool success = await updateStatus('picked_up', 5);
    if (!success || !mounted) {
      _trackingOrders.remove(order.id);
      return;
    }
    success = await updateStatus('on_the_way', 5);
    if (!success || !mounted) {
      _trackingOrders.remove(order.id);
      return;
    }
    success = await updateStatus('delivered', 5);
    if (success && mounted) {
      _trackingOrders.remove(order.id);
    }
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
      case 'declined':
        return Icon(Icons.cancel, color: Colors.red, size: 32);
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
      case 'declined':
        return 'Order declined by chef';
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

  @override
  void dispose() {
    _trackingOrders.clear();
    super.dispose();
  }
}