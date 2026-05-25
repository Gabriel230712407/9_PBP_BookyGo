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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompactWidth = width < 360;
            final horizontalPadding = isCompactWidth ? 16.0 : 20.0;
            final titleSize = isCompactWidth ? 22.0 : 26.0;
            final buttonTextSize = isCompactWidth ? 16.0 : 17.0;
            final benefitTitleSize = isCompactWidth ? 15.0 : 17.0;
            final benefitSubtitleSize = isCompactWidth ? 13.0 : 14.0;
            final topSpacing = isCompactWidth ? 16.0 : 22.0;
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
                10,
                horizontalPadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 30,
                ),
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
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryEnd,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: topSpacing),
                    Image.asset(
                      'assets/images/onboarding_bag.png',
                      width: isCompactWidth ? 86 : 96,
                      height: isCompactWidth ? 86 : 96,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: isCompactWidth ? 18 : 22),
                    Text(
                      'Get more from our app.',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlue,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: isCompactWidth ? 26 : 30),
                    BenefitItem(
                      icon: Icons.search_rounded,
                      title: 'Smart hotel search.',
                      subtitle: 'Find hotels by name or location.',
                      iconSize: isCompactWidth ? 21 : 23,
                      titleSize: benefitTitleSize,
                      subtitleSize: benefitSubtitleSize,
                      gap: isCompactWidth ? 12 : 14,
                    ),
                    SizedBox(height: itemSpacing),
                    BenefitItem(
                      icon: Icons.meeting_room_outlined,
                      title: 'Easy room booking.',
                      subtitle: 'Choose dates, rooms, and add-ons instantly.',
                      iconSize: isCompactWidth ? 21 : 23,
                      titleSize: benefitTitleSize,
                      subtitleSize: benefitSubtitleSize,
                      gap: isCompactWidth ? 12 : 14,
                    ),
                    SizedBox(height: itemSpacing),
                    BenefitItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Digital receipt & QR.',
                      subtitle: 'Get your booking confirmation with QR code.',
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
                        onPressed: () {},
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
                        onPressed: () {},
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
                                'Continue with email',
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
