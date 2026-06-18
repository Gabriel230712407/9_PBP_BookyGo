import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class EmptyHistoryView extends StatelessWidget {
  const EmptyHistoryView({
    super.key,
    this.isGuest = false,
    this.onPrimaryTap,
  });

  final bool isGuest;
  final VoidCallback? onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 360;
    const guestBodyColor = Color(0xFF6B7280);
    final buttonWidth = isGuest
        ? (width - (isCompact ? 28 : 32)).clamp(240.0, 320.0).toDouble()
        : (width - (isCompact ? 80 : 120)).clamp(180.0, 220.0).toDouble();

    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isCompact ? 20 : 24,
          0,
          isCompact ? 20 : 24,
          80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isGuest
                  ? 'assets/images/onboarding_bag.png'
                  : 'assets/images/empty_mascot.png',
              width: isGuest
                  ? (isCompact ? 104 : 118)
                  : (isCompact ? 132 : 150),
              height: isGuest
                  ? (isCompact ? 104 : 118)
                  : (isCompact ? 132 : 150),
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              isGuest ? 'Oops! You\'re Not Signed In' : 'No Booked History Yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkBlue,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isGuest
                  ? 'Sign in first to check your booking history\nand manage your reservations.'
                  : 'There\'s no booking history at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isGuest ? guestBodyColor : AppColors.textMuted,
                fontSize: 12,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: buttonWidth,
              height: isGuest ? (isCompact ? 38 : 40) : (isCompact ? 42 : 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isGuest ? 7 : 8),
                boxShadow: isGuest
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: OutlinedButton(
                onPressed: onPrimaryTap ?? () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isGuest
                      ? AppColors.white.withValues(alpha: 0.35)
                      : AppColors.primaryEnd,
                  foregroundColor:
                      isGuest ? AppColors.primaryEnd : AppColors.white,
                  side: BorderSide(
                    color: AppColors.primaryEnd,
                    width: isGuest ? 1.2 : 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isGuest ? 7 : 8),
                  ),
                ),
                child: Text(
                  isGuest ? 'Sign In' : 'Book now',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
