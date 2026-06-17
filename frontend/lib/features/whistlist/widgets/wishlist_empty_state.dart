import 'package:flutter/material.dart';

import '../../auth/utils/guest_action_guard.dart';

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({super.key, this.isGuest = false});

  final bool isGuest;

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
            'assets/images/empty_mascot.png',
            width: isCompact ? 140 : 170,
            height: isCompact ? 140 : 170,
            fit: BoxFit.contain,
          ),
          SizedBox(height: isCompact ? 18 : 22),
          Text(
            isGuest ? 'Login untuk memakai wishlist' : 'Your wishlist is empty',
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
                ? 'Silakan login terlebih dahulu untuk menyimpan hotel favorit dan melihat wishlist kamu.'
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
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => GuestActionGuard.openSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5E7CEB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
