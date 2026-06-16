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
      width: (width - 120).clamp(204.0, 224.0).toDouble(),
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryEnd,
          foregroundColor: AppColors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.white,
            fontSize: width < 360 ? 15 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
