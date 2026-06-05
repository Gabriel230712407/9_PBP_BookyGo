import 'package:flutter/material.dart';
import 'profile_palette.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;

  const ProfileSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ProfilePalette.white,
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ProfilePalette.darkText,
        ),
      ),
    );
  }
}