import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../utils/password_hasher.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    final user = await DatabaseHelper().getUserByEmail(email);

    if (user != null) {
      final hashedInput = PasswordHasher.hash(password);
      if (user.password == hashedInput) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );

        //  Correct navigation based on role
        if (user.role == 'customer') {
          Navigator.pushReplacementNamed(
            context,
            '/customer-home',
            arguments: user.id,
          );
        } else if (user.role == 'chef') {
          Navigator.pushReplacementNamed(
            context,
            '/chef-home',
            arguments: user.id, // ✅ Pass the userId here
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect password.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found.')),
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
            // Header yellow background with title
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
                  "Log In",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // White card container
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Delicious food awaits you! Enter your details to continue.",
                      style: TextStyle(color: Colors.brown),
                    ),
                    SizedBox(height: 24),

                    // Email input
                    Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.brown),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "example@example.com",
                        filled: true,
                        fillColor: Color(0xFFFFF3C4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Password input
                    Text(
                      "Password",
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.brown),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFFF3C4),
                        hintText: "*****",
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    // Forget Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forget Password",
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                    ),

                    // Login button
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        "Log In",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),

                    // OR with social
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/create-account'),
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(color: Colors.pinkAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(String assetPath) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Image.asset(assetPath, width: 24, height: 24),
    );
  }
}
