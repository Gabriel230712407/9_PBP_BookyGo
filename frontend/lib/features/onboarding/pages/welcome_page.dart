import 'package:flutter/material.dart';
import '../widgets/benefit_item.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5B74E8);
    const darkBlue = Color(0xFF344A99);
    const backgroundColor = Color(0xFFF5F7FF);
    const textGrey = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/onboarding_bag.png',
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Get more from our app.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: darkBlue,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 34),

              const BenefitItem(
                icon: Icons.search_rounded,
                title: 'Smart hotel search.',
                subtitle: 'Find hotels by name or location.',
              ),

              const SizedBox(height: 26),

              const BenefitItem(
                icon: Icons.meeting_room_outlined,
                title: 'Easy room booking.',
                subtitle: 'Choose dates, rooms, and add-ons instantly.',
              ),

              const SizedBox(height: 26),

              const BenefitItem(
                icon: Icons.receipt_long_outlined,
                title: 'Digital receipt & QR.',
                subtitle: 'Get your booking confirmation with QR code.',
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/Google_G_Logo.png',
                          width: 25,
                          height: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(
                      color: primaryColor,
                      width: 1.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {},
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail_outline_rounded, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Continue with email',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Have an account? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: textGrey,
                    ),
                  ),
                  Text(
                    'Sign in here',
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text.rich(
                TextSpan(
                  text: 'By signing up you accept our ',
                  style: TextStyle(
                    fontSize: 14,
                    color: textGrey,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}