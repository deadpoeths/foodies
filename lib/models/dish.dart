class Dish {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final String? dietaryInfo;
  final String? allergyWarnings;
  final int chefId; // Foreign key linking to User.id who is a chef
  final String category; // New field

  Dish({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.dietaryInfo,
    this.allergyWarnings,
    required this.chefId,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'dietaryInfo': dietaryInfo,
      'allergyWarnings': allergyWarnings,
      'chefId': chefId,
      'category': category, // Added
    };
  }

  static Dish fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imagePath: map['imagePath'],
      dietaryInfo: map['dietaryInfo'],
      allergyWarnings: map['allergyWarnings'],
      chefId: map['chefId'],
      category: map['category'] ?? '', // Added with null safety fallback
    );
  }
}
