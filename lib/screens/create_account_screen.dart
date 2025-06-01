import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../utils/password_hasher.dart';
import '../models/user.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController addressController = TextEditingController(); // Added for address

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool receiveUpdates = true;
  String selectedRole = 'customer';

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    String hashedPassword = PasswordHasher.hash(passwordController.text.trim());

    User user = User(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: hashedPassword,
      role: selectedRole,
      address: addressController.text.trim(), // Added address to User
    );

    try {
      await DatabaseHelper().insertUser(user);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8F1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 60, bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFFFBC02D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Center(
                child: Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Let’s Get Started", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Fill in the details to create your account.",
                        style: TextStyle(color: Colors.grey.shade700)),
                    SizedBox(height: 24),

                    _buildLabeledTextField("Full Name", nameController),
                    SizedBox(height: 16),
                    _buildLabeledTextField("Email Address", emailController),
                    SizedBox(height: 16),
                    _buildLabeledTextField("Phone Number", phoneController),
                    SizedBox(height: 16),
                    _buildLabeledTextField("Address", addressController), // Added address field
                    SizedBox(height: 16),
                    _buildLabeledTextField("Password", passwordController, obscure: obscurePassword, toggleObscure: () {
                      setState(() => obscurePassword = !obscurePassword);
                    }),
                    SizedBox(height: 16),
                    _buildLabeledTextField("Confirm Password", confirmPasswordController,
                        obscure: obscureConfirmPassword, toggleObscure: () {
                          setState(() => obscureConfirmPassword = !obscureConfirmPassword);
                        }),

                    SizedBox(height: 16),
                    Text("Register as:", style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xFFFFF3C4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          items: ['customer', 'chef'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role[0].toUpperCase() + role.substring(1)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedRole = value ?? 'customer');
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: receiveUpdates,
                          activeColor: Colors.deepOrange,
                          onChanged: (value) {
                            setState(() => receiveUpdates = value ?? true);
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Yes, I want to receive discounts, loyalty offers, and other updates.',
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        "Create Account",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Log In",
                                style: TextStyle(color: Colors.pinkAccent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(
      String label, TextEditingController controller,
      {bool obscure = false, VoidCallback? toggleObscure}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Color(0xFFFFF3C4),
            suffixIcon: toggleObscure != null
                ? IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.orange,
              ),
              onPressed: toggleObscure,
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}