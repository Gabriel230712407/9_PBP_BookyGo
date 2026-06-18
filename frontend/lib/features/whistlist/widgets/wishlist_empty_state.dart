import 'package:flutter/material.dart';

import '../../auth/utils/guest_action_guard.dart';
import '../../../core/theme/app_colors.dart';

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({super.key, this.isGuest = false});

  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F2A44);
    const textGrey = Color(0xFF5F6B85);
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 360;
    final buttonWidth = isGuest
        ? (width - (isCompact ? 28 : 32)).clamp(240.0, 320.0).toDouble()
        : double.infinity;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_mascot.png',
            width: isCompact ? 140 : 170,
            height: isCompact ? 140 : 170,
            fit: BoxFit.contain,
          ),
          SizedBox(height: isCompact ? 18 : 22),
          Text(
            isGuest ? 'Oops! You\'re Not Signed In' : 'Your wishlist is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 17 : 19,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),
          SizedBox(height: isCompact ? 8 : 10),
          Text(
            isGuest
                ? 'Sign in first to save favorite hotels\nand view your wishlist.'
                : 'Save hotels you like to your wishlist so you can',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 14 : 15,
              color: textGrey,
              height: 1.5,
            ),
          ),
          if (!isGuest) ...[
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
          if (isGuest) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: buttonWidth,
              height: isCompact ? 38 : 40,
              child: OutlinedButton(
                onPressed: () => GuestActionGuard.openSignIn(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white.withValues(alpha: 0.35),
                  foregroundColor: AppColors.primaryEnd,
                  side: const BorderSide(
                    color: AppColors.primaryEnd,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
