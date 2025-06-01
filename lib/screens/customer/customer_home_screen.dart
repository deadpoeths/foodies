import 'dart:io';
import 'package:flutter/material.dart';
import 'customer_orderlist.dart';
import 'track.dart';
import 'cart.dart';
import 'customer_profile.dart';
import '../../models/user.dart';
import '../../models/dish.dart';
import '../../models/cart_model.dart';
import '../../db/database_helper.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int userId;

  const CustomerHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  String? _selectedCategory;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomerProfilePage(userId: widget.userId)),
    );
  }

  void _toggleCategoryFilter(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
    });
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(userId: widget.userId, selectedCategory: _selectedCategory),
      CartPage(customerId: widget.userId),
      CustomerOrderListPage(),
      TrackOrderPage(customerId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Ensure HomeContent gets rebuilt with updated category
    _screens[0] = HomeContent(userId: widget.userId, selectedCategory: _selectedCategory);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFBC02D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(width: 10),
                              Icon(Icons.search, color: Colors.deepOrange),
                              SizedBox(width: 8),
                              Text("Search", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.person_outline, color: Colors.deepOrange),
                        onPressed: _navigateToProfile,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _CategoryIcon(label: "Snacks", icon: Icons.fastfood),
                      _CategoryIcon(
                        label: "Meal",
                        icon: Icons.restaurant,
                        selected: _selectedCategory == "Meal",
                        onTap: () => _toggleCategoryFilter("Meal"),
                      ),
                      const _CategoryIcon(label: "Vegan", icon: Icons.eco),
                      _CategoryIcon(
                        label: "Dessert",
                        icon: Icons.cake,
                        selected: _selectedCategory == "Dessert",
                        onTap: () => _toggleCategoryFilter("Dessert"),
                      ),
                      const _CategoryIcon(label: "Drinks", icon: Icons.local_drink),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _screens[_selectedIndex]),
          ],
        ),
      ),
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
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Track'),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryIcon({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: selected ? Colors.white : Colors.white70,
            child: Icon(icon, color: selected ? Colors.deepOrange : Colors.orange),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final int userId;
  final String? selectedCategory;

  const HomeContent({Key? key, required this.userId, this.selectedCategory}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Map<String, dynamic>> _chefDishData = [];

  @override
  void initState() {
    super.initState();
    _fetchChefAndDishData();
  }

  Future<void> _fetchChefAndDishData() async {
    final db = DatabaseHelper.instance;
    List<User> chefs = await db.getAllChefs();
    List<Dish> dishes = await db.getAllDishes();

    if (widget.selectedCategory != null) {
      dishes = dishes.where((dish) => dish.category == widget.selectedCategory).toList();
    }

    List<Map<String, dynamic>> combined = [];

    for (var dish in dishes) {
      User chef = chefs.firstWhere(
            (c) => c.id == dish.chefId,
        orElse: () => User(
          id: 0,
          name: "Unknown",
          email: "unknown@example.com",
          password: "unknown",
          phone: "0000000000",
          role: "chef",
          profileImage: null,
        ),
      );
      combined.add({'chef': chef, 'dish': dish});
    }

    setState(() => _chefDishData = combined);
  }

  @override
  void didUpdateWidget(HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _fetchChefAndDishData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _chefDishData.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chefDishData.length,
      itemBuilder: (context, index) {
        final chef = _chefDishData[index]['chef'] as User;
        final dish = _chefDishData[index]['dish'] as Dish;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dish.imagePath != null && File(dish.imagePath!).existsSync())
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.file(
                    File(dish.imagePath!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: (chef.profileImage != null && File(chef.profileImage!).existsSync())
                          ? FileImage(File(chef.profileImage!))
                          : null,
                      child: (chef.profileImage == null || !File(chef.profileImage!).existsSync())
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                      backgroundColor: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chef.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text("Pre Order", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const Text("5.0"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dish.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(dish.description, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("PKR${dish.price.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (dish.dietaryInfo != null && dish.dietaryInfo!.isNotEmpty)
                      Text("Dietary: ${dish.dietaryInfo!}",
                          style: const TextStyle(color: Colors.green)),
                    if (dish.allergyWarnings != null && dish.allergyWarnings!.isNotEmpty)
                      Text("Allergy: ${dish.allergyWarnings!}",
                          style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        CartModel().addToCart(dish);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Add to Cart", style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
