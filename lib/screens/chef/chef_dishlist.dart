import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../../models/dish.dart';
import '../../db/database_helper.dart';

class ChefDishListPage extends StatefulWidget {
  final int userId;

  const ChefDishListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChefDishListPageState createState() => _ChefDishListPageState();
}

class _ChefDishListPageState extends State<ChefDishListPage> {
  List<Dish> _dishes = [];

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    final dishes = await DatabaseHelper.instance.getDishesByChefId(widget.userId);
    if (mounted) {
      setState(() {
        _dishes = dishes;
      });
    }
  }

  void _showAddDishBottomSheet(BuildContext bottomSheetContext) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final dietaryController = TextEditingController();
    final allergyController = TextEditingController();
    String selectedCategory = "Meal";
    File? selectedImage;

    showModalBottomSheet(
      context: bottomSheetContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          color: const Color(0xFFFBC02D),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setModalState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white10,
                        ),
                        child: selectedImage == null
                            ? const Center(
                          child: Text("Tap to upload image", style: TextStyle(color: Colors.white70)),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildWhiteTextField(nameController, "Dish Name"),
                    _buildWhiteTextField(descController, "Description"),
                    _buildWhiteTextField(priceController, "Price", isNumber: true),
                    _buildWhiteTextField(dietaryController, "Dietary Info"),
                    _buildWhiteTextField(allergyController, "Allergy Warnings"),

                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Category", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Meal', style: TextStyle(color: Colors.white)),
                            value: "Meal",
                            groupValue: selectedCategory,
                            onChanged: (value) {
                              setModalState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Dessert', style: TextStyle(color: Colors.white)),
                            value: "Dessert",
                            groupValue: selectedCategory,
                            onChanged: (value) {
                              setModalState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Add"),
                          onPressed: () async {
                            if (selectedImage == null || nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please provide an image and dish name.")),
                              );
                              return;
                            }

                            final directory = await getApplicationDocumentsDirectory();
                            final imageName = basename(selectedImage!.path);
                            final savedImage = await selectedImage!.copy('${directory.path}/$imageName');

                            final newDish = Dish(
                              chefId: widget.userId,
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              price: double.tryParse(priceController.text.trim()) ?? 0.0,
                              imagePath: savedImage.path,
                              dietaryInfo: dietaryController.text.trim(),
                              allergyWarnings: allergyController.text.trim(),
                              category: selectedCategory,
                            );

                            await DatabaseHelper.instance.insertDish(newDish);
                            Navigator.pop(context); // Close sheet
                            _loadDishes(); // Refresh list
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildWhiteTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext newContext) => Scaffold(
        backgroundColor: const Color(0xFFFFF8F1),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            title: const Text("Your Dishes", style: TextStyle(color: Colors.white, fontSize: 22)),
            backgroundColor: const Color(0xFFFBC02D),
            iconTheme: const IconThemeData(color: Colors.white),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddDishBottomSheet(newContext),
              ),
            ],
          ),
        ),
        body: _dishes.isEmpty
            ? const Center(
          child: Text(
            "No dishes yet. Tap + to add.",
            style: TextStyle(color: Colors.deepOrange, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
            : ListView.builder(
          itemCount: _dishes.length,
          itemBuilder: (context, index) {
            final dish = _dishes[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: dish.imagePath.isNotEmpty
                        ? Image.file(
                      File(dish.imagePath),
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.fastfood, size: 60)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dish.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          if (dish.description.isNotEmpty)
                            Text(dish.description, style: const TextStyle(color: Colors.white70)),
                          Text("Price: \$${dish.price.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white70)),
                          if (dish.dietaryInfo?.isNotEmpty == true)
                            Text("Dietary: ${dish.dietaryInfo}",
                                style: const TextStyle(color: Colors.white70)),
                          if (dish.allergyWarnings?.isNotEmpty == true)
                            Text("Allergies: ${dish.allergyWarnings}",
                                style: const TextStyle(color: Colors.white70)),
                          if (dish.category?.isNotEmpty == true)
                            Text("Category: ${dish.category}",
                                style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
