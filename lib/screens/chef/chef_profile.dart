import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../../models/user.dart';
import '../../db/database_helper.dart';

class ChefProfilePage extends StatefulWidget {
  final int userId;

  const ChefProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChefProfilePageState createState() => _ChefProfilePageState();
}

class _ChefProfilePageState extends State<ChefProfilePage> {
  User? _chef;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadChefData();
  }

  Future<void> _loadChefData() async {
    final chef = await DatabaseHelper.instance.getUserById(widget.userId);
    setState(() {
      _chef = chef;
      if (chef?.profileImage != null && chef!.profileImage!.isNotEmpty) {
        _imageFile = File(chef.profileImage!);
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final name = basename(pickedFile.path);
    final savedImage = await File(pickedFile.path).copy('${directory.path}/$name');

    setState(() {
      _imageFile = savedImage;
    });
  }

  Future<void> _saveProfileImage(BuildContext context) async {
    if (_imageFile == null || _chef == null || _chef!.id == null) return;

    await DatabaseHelper.instance.updateProfileImage(_chef!.id!, _imageFile!.path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image saved!')),
    );

    await _loadChefData(); // Reload updated image
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
    if (_chef == null) {
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
                'Chef Profile',
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
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage:
                          _imageFile != null ? FileImage(_imageFile!) : null,
                          child: _imageFile == null
                              ? const Icon(Icons.camera_alt, size: 40, color: Colors.deepOrange)
                              : null,
                        ),
                      ),
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
                              _chef!.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _chef!.email,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _chef!.phone ?? '',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _saveProfileImage(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                              icon: const Icon(Icons.save),
                              label: const Text(
                                "Save Profile",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
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
