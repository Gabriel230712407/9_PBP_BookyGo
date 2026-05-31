import 'package:flutter/material.dart';
import 'profile_menu_item.dart';

class ProfileFeatureSection extends StatelessWidget {
  final int reviewCount;
  final int bookedCount;
  final int wishlistCount;

  const ProfileFeatureSection({
    super.key,
    required this.reviewCount,
    required this.bookedCount,
    required this.wishlistCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.forum_rounded,
          title: 'Your Review',
          subtitle: '$reviewCount Review',
        ),
        ProfileMenuItem(
          icon: Icons.article_rounded,
          title: 'Booked History',
          subtitle: '$bookedCount Active Booked',
        ),
        ProfileMenuItem(
          icon: Icons.favorite_rounded,
          title: 'Wishlist',
          subtitle: '$wishlistCount Wishlist',
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}