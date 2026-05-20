import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/benefit_item.dart';
import '../../navigation/pages/main_nav_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainNavPage(isGuest: true),
                      ),
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryEnd,
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
                  color: AppColors.darkBlue,
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
                    backgroundColor: AppColors.primaryEnd,
                    foregroundColor: AppColors.white,
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
                          color: AppColors.white,
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
                    foregroundColor: AppColors.primaryEnd,
                    side: const BorderSide(
                      color: AppColors.primaryEnd,
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

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Have an account? ',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'Sign in here',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryEnd,
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
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TextStyle(
                        color: AppColors.primaryEnd,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(
                        color: AppColors.primaryEnd,
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