import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VigilanterBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const VigilanterBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<VigilanterBottomNav> createState() => _VigilanterBottomNavState();
}

class _VigilanterBottomNavState extends State<VigilanterBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(VigilanterBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final int itemCount = 3;
    final double navHeight = (screenHeight * 0.55).clamp(54.0, 70.0);
    final double circleDiameter = (screenWidth * 0.14).clamp(58.0, 92.0);
    final double circleRadius = circleDiameter / 2;
    final double itemWidth = screenWidth / itemCount;

    final double oldCenter = itemWidth * (_previousIndex + 0.5);
    final double newCenter = itemWidth * (widget.currentIndex + 0.5);
    final double animatedCenter = oldCenter +
        (newCenter - oldCenter) *
            Curves.easeOutCubic.transform(_controller.value);

    final items = [
      _NavItemData(Icons.history_rounded, "Riwayat"),
      _NavItemData(Icons.star_rounded, "Beranda"),
      _NavItemData(Icons.map_rounded, "Peta"),
    ];

    return SizedBox(
      height: circleRadius + navHeight * 0.2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background navbar dengan cekungan bulat
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(screenWidth, navHeight),
              painter: _NavBarPainter(
                centerX: animatedCenter,
                circleRadius: circleRadius,
                navHeight: navHeight,
              ),
            ),
          ),

          // Lingkaran kuning aktif (lebih tenggelam ke navbar)
          Positioned(
            bottom: navHeight - (circleRadius * 1), // ↓ lebih ke bawah lagi
            left: animatedCenter - circleRadius,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final scale =
                    1.0 + 0.1 * math.sin(_controller.value * math.pi);
                final offsetY = -4 * math.sin(_controller.value * math.pi);
                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: circleDiameter,
                      height: circleDiameter,
                      decoration: BoxDecoration(
                        color: AppColors.kuningVigilanter,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        items[widget.currentIndex].icon,
                        size: circleDiameter * 0.65, // sedikit lebih besar
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Label & ikon nonaktif
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: navHeight,
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final bool isSelected = widget.currentIndex == index;
                  final double iconSize =
                      (circleDiameter * 0.52).clamp(22.0, 34.0);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSelected ? 0.0 : 1.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: iconSize,
                              color: AppColors.abuMuda.withOpacity(0.55),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.abuMuda.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter untuk bentuk cekungan melingkar lebih lebar dan halus
class _NavBarPainter extends CustomPainter {
  final double centerX;
  final double circleRadius;
  final double navHeight;

  _NavBarPainter({
    required this.centerX,
    required this.circleRadius,
    required this.navHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.biruGelap
      ..style = PaintingStyle.fill;

    final Path path = Path();

    // Kendali kedalaman & lebar
    final double depthFactor = 2.8; // semakin besar → semakin dalam
    final double widthFactor = 1.8; // semakin besar → semakin lebar
    final double radius = circleRadius * depthFactor;

    final double left = centerX - circleRadius * widthFactor;
    final double right = centerX + circleRadius * widthFactor;

    // Path utama
    path.moveTo(0, 0);
    path.lineTo(left, 0);

    // Bentuk lengkungan halus ke bawah (lebih rounded)
    path.quadraticBezierTo(
      centerX, 
      radius, // kedalaman melengkung ke bawah
      right, 
      0,
    );

    // Tutup sisi kanan & bawah
    path.lineTo(size.width, 0);
    path.lineTo(size.width, navHeight);
    path.lineTo(0, navHeight);
    path.close();

    // Shadow & fill
    canvas.drawShadow(path, Colors.black.withOpacity(0.35), 8, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) =>
      oldDelegate.centerX != centerX ||
      oldDelegate.circleRadius != circleRadius ||
      oldDelegate.navHeight != navHeight;
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}
