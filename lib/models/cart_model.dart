// models/cart_model.dart
import 'dish.dart';

class CartItem {
  final Dish dish;
  int quantity;

  CartItem({required this.dish, this.quantity = 1});
}

class CartModel {
  static final CartModel _instance = CartModel._internal();
  factory CartModel() => _instance;
  CartModel._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(Dish dish) {
    final index = _items.indexWhere((item) => item.dish.id == dish.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(dish: dish));
    }
  }

  void removeFromCart(Dish dish) {
    _items.removeWhere((item) => item.dish.id == dish.id);
  }

  void increaseQuantity(Dish dish) {
    final index = _items.indexWhere((item) => item.dish.id == dish.id);
    if (index != -1) _items[index].quantity++;
  }

  void decreaseQuantity(Dish dish) {
    final index = _items.indexWhere((item) => item.dish.id == dish.id);
    if (index != -1 && _items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      removeFromCart(dish);
    }
  }

  void clear() => _items.clear();
}
