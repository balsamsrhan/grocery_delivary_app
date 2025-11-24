import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

class WavyAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final double scrollOffset;
  final int totalCartItems;
  final VoidCallback onCartTap;

  WavyAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.scrollOffset,
    required this.totalCartItems,
    required this.onCartTap,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    final progress = shrinkOffset / maxExtent;
    final waveHeight = 30 * (1 - progress);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(double.infinity, waveHeight + 30),
            painter: WavePainter(
              waveHeight: waveHeight,
              scrollOffset: scrollOffset,
            ),
          ),
        ),

        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fresh Groceries',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 - (progress * 8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (progress < 0.7)
                    Text(
                      'Delivered to your doorstep 🚚',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              GestureDetector(
                onTap: onCartTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (totalCartItems > 0)
                        Positioned(
                          left: -1,
                          top: -3,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.accentOrange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              totalCartItems > 9 ? '9+' : '$totalCartItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant WavyAppBarDelegate oldDelegate) {
    return scrollOffset != oldDelegate.scrollOffset ||
        totalCartItems != oldDelegate.totalCartItems;
  }
}

class WavePainter extends CustomPainter {
  final double waveHeight;
  final double scrollOffset;

  WavePainter({required this.waveHeight, required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveOffset = (scrollOffset * 0.5) % (size.width / 2);

    path.moveTo(0, waveHeight);

    for (double x = 0; x <= size.width; x += 1) {
      final y = waveHeight +
          waveHeight *
              math.sin((x / size.width * 4 * math.pi) - (waveOffset / 50));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return waveHeight != oldDelegate.waveHeight ||
        scrollOffset != oldDelegate.scrollOffset;
  }
}