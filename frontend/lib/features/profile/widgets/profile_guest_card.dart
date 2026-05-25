import 'package:flutter/material.dart';

class ProfileGuestCard extends StatelessWidget {
  final VoidCallback onSignInPressed;

  const ProfileGuestCard({
    super.key,
    required this.onSignInPressed,
  });

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF344A99);
    const textGrey = Color(0xFF6B7280);
    const primaryColor = Color(0xFF5B74E8);
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 20),
      child: Column(
        children: [
          SizedBox(height: isCompact ? 36 : 54),

          Flex(
            direction: isCompact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/onboarding_bag.png',
                width: isCompact ? 76 : 86,
                height: isCompact ? 76 : 86,
                fit: BoxFit.contain,
              ),
              SizedBox(width: isCompact ? 0 : 18, height: isCompact ? 18 : 0),
              if (isCompact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Want to book faster?',
                      style: TextStyle(
                        fontSize: isCompact ? 17 : 18,
                        fontWeight: FontWeight.w800,
                        color: darkBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 8 : 10),
                    Text(
                      'Save your favorite hotels and\nmanage your stays, just sign in.',
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 14,
                        height: 1.5,
                        color: textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Want to book faster?',
                        style: TextStyle(
                          fontSize: isCompact ? 17 : 18,
                          fontWeight: FontWeight.w800,
                          color: darkBlue,
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 10),
                      Text(
                        'Save your favorite hotels and\nmanage your stays, just sign in.',
                        style: TextStyle(
                          fontSize: isCompact ? 13 : 14,
                          height: 1.5,
                          color: textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: isCompact ? 28 : 42),

          SizedBox(
            width: double.infinity,
            height: isCompact ? 54 : 58,
            child: OutlinedButton(
              onPressed: onSignInPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: primaryColor,
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white.withValues(alpha: 0.35),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
