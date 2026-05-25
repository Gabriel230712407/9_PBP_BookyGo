import 'package:flutter/material.dart';

class BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double iconSize;
  final double titleSize;
  final double subtitleSize;
  final double gap;

  const BenefitItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconSize = 24,
    this.titleSize = 17,
    this.subtitleSize = 15,
    this.gap = 14,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF344A99);
    const textColor = Color(0xFF6B7280);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: iconSize,
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
