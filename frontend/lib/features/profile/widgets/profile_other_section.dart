import 'package:flutter/material.dart';
import 'profile_menu_item.dart';
import 'profile_palette.dart';
import 'profile_section_title.dart';

class ProfileOtherSection extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const ProfileOtherSection({
    super.key,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileSectionTitle(title: 'Others'),
        ProfileMenuItem(
          icon: Icons.info,
          title: 'About BookyGoo.com',
          iconColor: ProfilePalette.black,
          onTap: () {},
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          title: 'Log Out',
          iconColor: ProfilePalette.black,
          onTap: onLogoutTap,
        ),
        const SizedBox(height: 54),
      ],
    );
  }
}