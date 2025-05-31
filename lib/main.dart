import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/chef/chef_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   // Uncomment to reset DB during development
  /*final dbPath = await getDatabasesPath();
  await deleteDatabase(join(dbPath, 'app_users.db'));*/

  runApp(ChefApp());
}

class ChefApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChefApp',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFFF8F6F2),
        fontFamily: 'Helvetica',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/create-account': (context) => CreateAccountScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chef-home') {
          final userId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ChefHomeScreen(userId: userId),
          );
        } else if (settings.name == '/customer-home') {
          final userId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => CustomerHomeScreen(userId: userId),
          );
        }
        return null;
      },
    );
  }
}
