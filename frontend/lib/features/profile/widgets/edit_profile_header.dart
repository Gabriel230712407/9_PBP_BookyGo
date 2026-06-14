import 'package:flutter/material.dart';
import 'profile_palette.dart';

class EditProfileHeader extends StatelessWidget {
  final VoidCallback onBackTap;

  const EditProfileHeader({
    super.key,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ProfilePalette.primaryBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: onBackTap,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: ProfilePalette.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: ProfilePalette.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
