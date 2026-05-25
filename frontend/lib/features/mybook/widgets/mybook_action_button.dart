import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MyBookActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MyBookActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: (width - 48).clamp(220.0, 260.0).toDouble(),
      height: width < 360 ? 56 : 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEnd,
          foregroundColor: AppColors.white,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.white,
            fontSize: width < 360 ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
