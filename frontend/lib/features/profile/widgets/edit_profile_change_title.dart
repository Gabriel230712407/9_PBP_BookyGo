import 'package:flutter/material.dart';
import 'profile_palette.dart';

class EditProfileChangeTile extends StatelessWidget {
  final String value;
  final VoidCallback onChangeTap;
  final Color backgroundColor;

  const EditProfileChangeTile({
    super.key,
    required this.value,
    required this.onChangeTap,
    this.backgroundColor = const Color(0xFFF6F7FF),
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '-' : value;

    return Container(
      height: 66,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ProfilePalette.darkText,
              ),
            ),
          ),
          TextButton(
            onPressed: onChangeTap,
            style: TextButton.styleFrom(
              foregroundColor: ProfilePalette.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
