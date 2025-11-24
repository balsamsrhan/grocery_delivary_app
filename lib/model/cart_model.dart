import 'package:flutter/animation.dart';

import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class FlyingItemAnimation {
  final AnimationController controller;
  final Offset startPosition;
  final Offset endPosition;
  final String icon;

  FlyingItemAnimation({
    required this.controller,
    required this.startPosition,
    required this.endPosition,
    required this.icon,
  });
}