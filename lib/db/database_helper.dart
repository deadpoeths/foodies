import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/dish.dart';
import '../models/order.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5, // Bumped to 5
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT UNIQUE,
      phone TEXT,
      password TEXT,
      role TEXT,
      profileImage TEXT,
      address TEXT  -- Added address
    )
  ''');

    await db.execute('''
    CREATE TABLE dishes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      chefId INTEGER,
      name TEXT,
      description TEXT,
      price REAL,
      imagePath TEXT,
      dietaryInfo TEXT,
      allergyWarnings TEXT,
      category TEXT,
      FOREIGN KEY (chefId) REFERENCES users(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerId INTEGER,
      dishId INTEGER,
      quantity INTEGER,
      status TEXT,
      FOREIGN KEY (customerId) REFERENCES users(id),
      FOREIGN KEY (dishId) REFERENCES dishes(id)
    )
  ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN profileImage TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE dishes ADD COLUMN category TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE users ADD COLUMN address TEXT');
    }
  }

  // ---------------- USER QUERIES ----------------
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<List<User>> getAllChefs() async {
    final db = await database;
    final result = await db.query('users', where: 'role = ?', whereArgs: ['chef']);
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<List<User>> getAllCustomers() async {
    final db = await database;
    final result = await db.query('users', where: 'role = ?', whereArgs: ['customer']);
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateProfileImage(int userId, String imagePath) async {
    final db = await database;
    await db.update(
      'users',
      {'profileImage': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ---------------- DISH QUERIES ----------------
  Future<int> insertDish(Dish dish) async {
    final db = await database;
    return await db.insert('dishes', dish.toMap());
  }

  Future<Dish?> getDishById(int id) async {
    final db = await database;
    final result = await db.query('dishes', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Dish.fromMap(result.first) : null;
  }

  Future<List<Dish>> getDishesByChefId(int chefId) async {
    final db = await database;
    final result = await db.query('dishes', where: 'chefId = ?', whereArgs: [chefId]);
    return result.map((map) => Dish.fromMap(map)).toList();
  }

  Future<List<Dish>> getAllDishes() async {
    final db = await database;
    final result = await db.query('dishes');
    return result.map((map) => Dish.fromMap(map)).toList();
  }

  Future<int> updateDish(Dish dish) async {
    final db = await database;
    return await db.update('dishes', dish.toMap(), where: 'id = ?', whereArgs: [dish.id]);
  }

  Future<int> deleteDish(int id) async {
    final db = await database;
    return await db.delete('dishes', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- ORDER QUERIES ----------------
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<Order?> getOrderByChefId(int id) async {
    final db = await database;
    final result = await db.query('orders', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Order.fromMap(result.first) : null;
  }

  Future<List<Order>> getOrdersByChefId(int chefId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT o.*, d.name AS dishName, u.name AS customerName, u.address AS customerAddress
    FROM orders o
    JOIN dishes d ON o.dishId = d.id
    JOIN users u ON o.customerId = u.id
    WHERE d.chefId = ?
  ''', [chefId]);

    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<Order>> getOrdersByDishId(int dishId) async {
    final db = await database;
    final result = await db.query('orders', where: 'dishId = ?', whereArgs: [dishId]);
    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final result = await db.query('orders');
    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }
}
