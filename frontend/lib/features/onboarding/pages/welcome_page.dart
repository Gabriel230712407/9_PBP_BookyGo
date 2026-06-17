import 'package:flutter/material.dart';
import 'package:frontend/features/auth/pages/email_auth_page.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/features/navigation/pages/main_nav_page.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/benefit_item.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final session = await AuthService.signInWithGoogle();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavPage(
            isGuest: false,
            userEmail: session.user.email,
            userName: session.user.name,
          ),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavPage(isGuest: true),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompactWidth = width < 360;
            final horizontalPadding = isCompactWidth ? 16.0 : 20.0;
            final titleSize = isCompactWidth ? 22.0 : 26.0;
            final buttonTextSize = isCompactWidth ? 16.0 : 17.0;
            final benefitTitleSize = isCompactWidth ? 15.0 : 17.0;
            final benefitSubtitleSize = isCompactWidth ? 13.0 : 14.0;
            final topSpacing = isCompactWidth ? 24.0 : 32.0;
            final itemSpacing = isCompactWidth ? 22.0 : 24.0;
            final buttonHeight = isCompactWidth ? 54.0 : 56.0;
            final contentTailSpacing = constraints.maxHeight < 720
                ? 28.0
                : constraints.maxHeight < 820
                ? 48.0
                : 72.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.primaryEnd,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: topSpacing),
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.9),
                            blurRadius: 24,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/images/onboarding_bag.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: isCompactWidth ? 22 : 26),
                    Text(
                      'One account for every BookyGo stay.',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlue,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in with email to keep your bookings, wishlist, and travel details organized in one place.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: isCompactWidth ? 26 : 30),
                    BenefitItem(
                      icon: Icons.search_rounded,
                      title: 'Find your stay quickly.',
                      subtitle:
                          'Search hotels and rooms faster from one account.',
                      iconSize: isCompactWidth ? 21 : 23,
                      titleSize: benefitTitleSize,
                      subtitleSize: benefitSubtitleSize,
                      gap: isCompactWidth ? 12 : 14,
                    ),
                    SizedBox(height: itemSpacing),
                    BenefitItem(
                      icon: Icons.meeting_room_outlined,
                      title: 'Keep booking history in sync.',
                      subtitle:
                          'View active reservations and booking history anytime.',
                      iconSize: isCompactWidth ? 21 : 23,
                      titleSize: benefitTitleSize,
                      subtitleSize: benefitSubtitleSize,
                      gap: isCompactWidth ? 12 : 14,
                    ),
                    SizedBox(height: itemSpacing),
                    BenefitItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Complete your profile later.',
                      subtitle:
                          'Gender, phone number, and profile photo can be added after sign-in.',
                      iconSize: isCompactWidth ? 21 : 23,
                      titleSize: benefitTitleSize,
                      subtitleSize: benefitSubtitleSize,
                      gap: isCompactWidth ? 12 : 14,
                    ),
                    SizedBox(height: contentTailSpacing),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryEnd,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompactWidth ? 14 : 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: isCompactWidth ? 28 : 32,
                                height: isCompactWidth ? 28 : 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/Google_G_Logo.png',
                                  width: isCompactWidth ? 20 : 22,
                                  height: isCompactWidth ? 20 : 22,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(width: isCompactWidth ? 10 : 12),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: buttonTextSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryEnd,
                          backgroundColor: AppColors.bgVeryLight,
                          side: const BorderSide(
                            color: AppColors.primaryEnd,
                            width: 1.4,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompactWidth ? 14 : 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EmailAuthPage(),
                            ),
                          );
                        },
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mail_outline_rounded,
                                size: isCompactWidth ? 20 : 22,
                              ),
                              SizedBox(width: isCompactWidth ? 10 : 12),
                              Text(
                                'Continue with Email',
                                style: TextStyle(
                                  fontSize: buttonTextSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isCompactWidth ? 14 : 16),
                    RichText(
                      text: TextSpan(
                        text: 'By signing up you accept our ',
                        style: TextStyle(
                          fontSize: isCompactWidth ? 12 : 13,
                          color: AppColors.textMuted,
                          height: 1.45,
                        ),
                        children: const [
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
