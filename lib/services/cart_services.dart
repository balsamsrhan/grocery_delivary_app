import 'package:grocery_delivary_app/model/cart_model.dart';
import 'package:grocery_delivary_app/model/product_model.dart';

class CartService {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
  }

  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
  }

  void updateQuantity(Product product, int change) {
    final item = _cartItems.firstWhere(
          (i) => i.product.id == product.id,
    );
    item.quantity += change;
    if (item.quantity <= 0) {
      _cartItems.remove(item);
    }
  }

  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _cartItems.fold(
      0.0,
          (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  void clearCart() {
    _cartItems.clear();
  }
}