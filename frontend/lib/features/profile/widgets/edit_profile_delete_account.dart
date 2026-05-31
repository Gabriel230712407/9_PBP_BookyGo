import 'package:flutter/material.dart';

class EditProfileDeleteAccount extends StatelessWidget {
  final VoidCallback onTap;

  const EditProfileDeleteAccount({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: const Text(
          'Delete Account',
          style: TextStyle(
            color: Color(0xFFE0001B),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}