import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../db/database_helper.dart';

class CustomerProfilePage extends StatefulWidget {
  final int userId;

  const CustomerProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  User? _customer;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    final customer = await DatabaseHelper.instance.getUserById(widget.userId);
    setState(() {
      _customer = customer;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteUser(widget.userId);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_customer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: Column(
        children: [
          // Header
          Container(
            height: 75,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFBC02D),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: const Center(
              child: Text(
                'Customer Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          // Overlapping card with image and content
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _customer!.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _customer!.email,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _customer!.phone ?? '',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: () => _logout(context),
                              icon: const Icon(Icons.logout),
                              label: const Text("Logout"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.deepOrange,
                                side: const BorderSide(color: Colors.deepOrange),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _deleteAccount(context),
                              icon: const Icon(Icons.delete),
                              label: const Text("Delete Account"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
