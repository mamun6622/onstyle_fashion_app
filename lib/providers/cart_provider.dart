import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  double get tax => subtotal * 0.08; // 8% tax rate

  double get shipping => subtotal > 150.0 || subtotal == 0.0 ? 0.0 : 10.0;

  double get total => subtotal + tax + shipping;

  void addToCart(Product product, String size, String color, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          product: product,
          selectedSize: size,
          selectedColor: color,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _items.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      final newQty = _items[index].quantity + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
