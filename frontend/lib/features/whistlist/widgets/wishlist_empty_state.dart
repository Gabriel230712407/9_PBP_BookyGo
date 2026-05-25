import 'package:flutter/material.dart';

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F2A44);
    const textGrey = Color(0xFF5F6B85);
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/onboarding_bag.png',
            width: isCompact ? 140 : 170,
            height: isCompact ? 140 : 170,
            fit: BoxFit.contain,
          ),
          SizedBox(height: isCompact ? 18 : 22),
          Text(
            'Your wishlist is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 17 : 19,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),
          SizedBox(height: isCompact ? 8 : 10),
          Text(
            'Save hotels you like to your wishlist so you can',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 14 : 15,
              color: textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'find them easily later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 14 : 15,
              color: textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
