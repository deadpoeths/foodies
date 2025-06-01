class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String? profileImage;
  final String? address; // Added address field

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.profileImage,
    this.address, // Added to constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'profileImage': profileImage,
      'address': address, // Added to map for database
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      profileImage: map['profileImage'] as String?,
      address: map['address'] as String?, // Added to parse from database
    );
  }

  // Factory constructor to instantiate a Customer from User
  factory User.asCustomer({
    int? id,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? profileImage,
    String? address, // Added address parameter
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: 'customer',
      profileImage: profileImage,
      address: address,
    );
  }

  // Factory constructor to instantiate a Chef from User
  factory User.asChef({
    int? id,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? profileImage,
    String? address, // Added address parameter
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: 'chef',
      profileImage: profileImage,
      address: address,
    );
  }

  // Type check helper
  bool get isCustomer => role == 'customer';
  bool get isChef => role == 'chef';
}