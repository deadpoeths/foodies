class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;
  final String? profileImage;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    this.profileImage,
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
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      role: map['role'],
      profileImage: map['profileImage'],
    );
  }

  // ✅ Factory constructor to instantiate a Customer from User
  factory User.asCustomer({
    int? id,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: 'customer',
      profileImage: profileImage,
    );
  }

  // ✅ Factory constructor to instantiate a Chef from User
  factory User.asChef({
    int? id,
    required String name,
    required String email,
    required String phone,
    required String password,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: 'chef',
      profileImage: profileImage,
    );
  }

  // ✅ Type check helper
  bool get isCustomer => role == 'customer';
  bool get isChef => role == 'chef';
}