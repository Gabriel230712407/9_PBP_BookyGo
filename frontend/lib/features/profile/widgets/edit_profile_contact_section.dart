import 'package:flutter/material.dart';
import 'edit_profile_change_title.dart';
import 'profile_palette.dart';

class EditProfileContactSection extends StatelessWidget {
  final String phoneNumber;
  final String email;
  final VoidCallback onPhoneChangeTap;
  final VoidCallback onEmailChangeTap;

  const EditProfileContactSection({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.onPhoneChangeTap,
    required this.onEmailChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ProfilePalette.white,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 16, 26, 20), // ← dikurangi
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phone number and Email',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ProfilePalette.darkText,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Phone number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ProfilePalette.darkText,
            ),
          ),
          const SizedBox(height: 8),
          EditProfileChangeTile(
            value: phoneNumber,
            onChangeTap: onPhoneChangeTap,
          ),
          const SizedBox(height: 14),
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ProfilePalette.darkText,
            ),
          ),
          const SizedBox(height: 8),
          EditProfileChangeTile(
            value: email,
            onChangeTap: onEmailChangeTap,
            backgroundColor: ProfilePalette.white,
          ),
        ],
      ),
    );
  }
}
