import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  static const double _barHeight = 68;
  static const double _indicatorWidth = 48;
  static const double _indicatorHeight = 11;
  static const double _horizontalPadding = 12;

  final int? selectedIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNavBar({
    super.key,
    this.selectedIndex,
    this.onTap,
  });

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.article_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: _barHeight,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double contentWidth =
                constraints.maxWidth - (_horizontalPadding * 2);
            final double itemWidth = contentWidth / _icons.length;
            final double indicatorLeft = selectedIndex == null
                ? 0
                : _horizontalPadding +
                    (itemWidth * selectedIndex!) +
                    ((itemWidth - _indicatorWidth) / 2);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: _barHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryEnd,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                ),
                if (selectedIndex != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    left: indicatorLeft,
                    top: 0,
                    child: ClipPath(
                      clipper: _ActiveIndicatorClipper(),
                      child: Container(
                        width: _indicatorWidth,
                        height: _indicatorHeight,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    5,
                    _horizontalPadding,
                    8,
                  ),
                  child: Row(
                    children: List.generate(_icons.length, (index) {
                      final bool isSelected = selectedIndex == index;
                      final bool isPassive = selectedIndex == null;

                      return Expanded(
                        child: InkWell(
                          onTap: onTap == null ? null : () => onTap!(index),
                          borderRadius: BorderRadius.circular(20),
                          child: Center(
                            child: Icon(
                              _icons[index],
                              size: 28,
                              color: isPassive
                                  ? AppColors.white
                                  : AppColors.white.withValues(
                                      alpha: isSelected ? 1 : 0.84,
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActiveIndicatorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.05,
        size.width * 0.76,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        size.width * 0.63,
        size.height * 0.96,
        size.width * 0.5,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.37,
        size.height * 0.96,
        size.width * 0.24,
        size.height * 0.46,
      )
      ..quadraticBezierTo(size.width * 0.1, size.height * 0.05, 0, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
