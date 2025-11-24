import 'package:flutter/material.dart';
import 'package:grocery_delivary_app/model/cart_model.dart';
import 'package:grocery_delivary_app/model/product_model.dart';
import 'package:grocery_delivary_app/widget/cart_bottom_sheet.dart';
import 'package:grocery_delivary_app/widget/category_chip.dart';
import 'package:grocery_delivary_app/widget/floating_cart.dart';
import 'package:grocery_delivary_app/widget/prodect_card.dart';
import 'package:grocery_delivary_app/widget/wavy_app_bar.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

class GroceryHomeScreen extends StatefulWidget {
  const GroceryHomeScreen({Key? key}) : super(key: key);

  @override
  State<GroceryHomeScreen> createState() => _GroceryHomeScreenState();
}

class _GroceryHomeScreenState extends State<GroceryHomeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<CartItem> _cartItems = [];
  final List<FlyingItemAnimation> _flyingAnimations = [];
  final Map<int, GlobalKey> _productKeys = {};
  String _selectedCategory = 'Fresh Fruits';
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // إنشاء GlobalKeys لكل منتج مسبقاً
    _initializeProductKeys();
  }

  void _initializeProductKeys() {
    for (var product in Product.sampleProducts) {
      _productKeys[product.id] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var anim in _flyingAnimations) {
      anim.controller.dispose();
    }
    super.dispose();
  }

  void _addToCart(Product product) {
    final productKey = _productKeys[product.id];
    if (productKey != null) {
      final RenderBox? box = productKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final position = box.localToGlobal(Offset.zero);

        setState(() {
          final existingIndex = _cartItems.indexWhere(
                (item) => item.product.id == product.id,
          );
          if (existingIndex != -1) {
            _cartItems[existingIndex].quantity++;
          } else {
            _cartItems.add(CartItem(product: product, quantity: 1));
          }
        });

        final controller = AnimationController(
          duration: const Duration(milliseconds: 800),
          vsync: this,
        );

        final animation = FlyingItemAnimation(
          controller: controller,
          startPosition: position,
          endPosition: const Offset(350, 50),
          icon: product.icon,
        );

        setState(() {
          _flyingAnimations.add(animation);
        });

        controller.forward().then((_) {
          setState(() {
            _flyingAnimations.remove(animation);
          });
          controller.dispose();
        });
      }
    }
  }

  void _updateQuantity(Product product, int change) {
    if (change > 0) {
      // إذا كانت زيادة في الكمية، استخدم الـanimation
      _addToCart(product);
    } else {
      // إذا كانت نقص في الكمية، لا حاجة للـanimation
      setState(() {
        final existingIndex = _cartItems.indexWhere(
              (item) => item.product.id == product.id,
        );
        if (existingIndex != -1) {
          _cartItems[existingIndex].quantity += change;
          if (_cartItems[existingIndex].quantity <= 0) {
            _cartItems.removeAt(existingIndex);
          }
        }
      });
    }
  }

  int get _totalCartItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get _totalCartPrice {
    return _cartItems.fold(
      0.0,
          (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search fresh groceries...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
          suffixIcon: const Icon(Icons.tune, color: AppColors.primaryGreen),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Wavy App Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: WavyAppBarDelegate(
                  minHeight: 120,
                  maxHeight: 200,
                  scrollOffset: _scrollOffset,
                  totalCartItems: _totalCartItems,
                  onCartTap: () => _showCartBottomSheet(context),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildSearchBar(),
                ),
              ),

              // Categories
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: Product.categories.length,
                    itemBuilder: (context, index) {
                      final category = Product.categories[index];
                      return CategoryChip(
                        category: category,
                        isSelected: category == _selectedCategory,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Products Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final filteredProducts = Product.sampleProducts
                          .where((p) => p.category == _selectedCategory)
                          .toList();
                      if (index >= filteredProducts.length) return null;

                      final product = filteredProducts[index];
                      final cartItem = _cartItems.firstWhere(
                            (item) => item.product.id == product.id,
                        orElse: () => CartItem(product: product, quantity: 0),
                      );

                      return ProductCard(
                        key: _productKeys[product.id], // استخدام GlobalKey
                        product: product,
                        itemCount: cartItem.quantity,
                        onAddToCart: () => _addToCart(product),
                        onIncrement: () => _addToCart(product),
                        onDecrement: () => _updateQuantity(product, -1),
                      );
                    },
                    childCount: Product.sampleProducts
                        .where((p) => p.category == _selectedCategory)
                        .length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Flying animations overlay
          ...(_flyingAnimations.map(
                (anim) => AnimatedBuilder(
              animation: anim.controller,
              builder: (context, child) {
                final curve = Curves.easeInOut.transform(anim.controller.value);
                final currentX = anim.startPosition.dx +
                    (anim.endPosition.dx - anim.startPosition.dx) * curve;
                final startOffsetY = anim.startPosition.dy + 50;
                final endOffsetY = anim.endPosition.dy;

                final currentY = startOffsetY +
                    (endOffsetY - startOffsetY) * curve -
                    150 * math.sin(curve * math.pi);

                return Positioned(
                  left: currentX,
                  top: currentY,
                  child: Opacity(
                    opacity: 1,
                    child: Transform.scale(
                      scale: 1 - curve * 0.5,
                      child: Text(
                        anim.icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
          )),

          // Floating Cart Button
          if (_totalCartItems > 0)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: FloatingCartButton(
                itemCount: _totalCartItems,
                totalPrice: _totalCartPrice,
                onTap: () => _showCartBottomSheet(context),
              ),
            ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CartBottomSheet(
        cartItems: _cartItems,
        onUpdateQuantity: _updateQuantity,
      ),
    );
  }
}