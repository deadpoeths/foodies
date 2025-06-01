import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/order.dart';

class CustomerOrderListPage extends StatefulWidget {
  final int customerId;

  const CustomerOrderListPage({required this.customerId});

  @override
  _CustomerOrderListPageState createState() => _CustomerOrderListPageState();
}

class _CustomerOrderListPageState extends State<CustomerOrderListPage> {
  List<Order> _completedOrders = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedOrders();
  }

  Future<void> _loadCompletedOrders() async {
    final db = DatabaseHelper.instance;
    final allOrders = await db.getAllOrders();
    // Filter for completed or declined orders only
    final filtered = allOrders
        .where((o) =>
    o.customerId == widget.customerId &&
        (o.status == 'delivered' || o.status == 'declined'))
        .toList();

    if (mounted) {
      setState(() => _completedOrders = filtered);
    }
    print('Loaded completed/declined orders: ${filtered.map((o) => 'ID: ${o.id}, Status: ${o.status}').toList()}');

    // Periodically refresh the list
    Future.doWhile(() async {
      if (!mounted) return false;
      final updatedOrders = await db.getAllOrders();
      final newFiltered = updatedOrders
          .where((o) =>
      o.customerId == widget.customerId &&
          (o.status == 'delivered' || o.status == 'declined'))
          .toList();
      if (mounted) {
        setState(() => _completedOrders = newFiltered);
      }
      await Future.delayed(Duration(seconds: 5));
      return mounted;
    });
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'delivered':
        return Icon(Icons.check_circle, color: Colors.teal, size: 32);
      case 'declined':
        return Icon(Icons.cancel, color: Colors.red, size: 32);
      default:
        return Icon(Icons.help_outline, color: Colors.grey, size: 32);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'delivered':
        return 'Order delivered';
      case 'declined':
        return 'Order declined by chef';
      default:
        return 'Unknown status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: _completedOrders.isEmpty
          ? Center(child: Text('No completed or declined orders found.'))
          : ListView.builder(
        itemCount: _completedOrders.length,
        itemBuilder: (context, index) {
          final order = _completedOrders[index];
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