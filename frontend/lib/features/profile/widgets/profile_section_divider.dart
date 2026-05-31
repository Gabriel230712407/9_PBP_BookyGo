import 'package:flutter/material.dart';
import 'profile_palette.dart';

class ProfileSectionDivider extends StatelessWidget {
  const ProfileSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 10,
      child: ColoredBox(
        color: ProfilePalette.divider,
      ),
    );
  }
}