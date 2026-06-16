import 'package:flutter/material.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/pages/email_auth_page.dart';
import 'package:frontend/features/navigation/pages/main_nav_page.dart';

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
      final result = await AuthService.signInWithGoogle();
      if (!mounted) return;

      if (result.isRegistered) {
        final session = result.session!;
        final confirmed = await _showGoogleConfirmDialog(
          title: 'Continue with Google?',
          message:
              'Sign in as ${session.user.name} (${session.user.email})?',
          confirmLabel: 'Continue',
        );

        if (!mounted || confirmed != true) {
          return;
        }

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
        return;
      }

      final profile = result.profile!;
      final confirmed = await _showGoogleConfirmDialog(
        title: 'Complete registration first',
        message:
            'The Google account ${profile.email} is not registered yet. Continue to register with this account?',
        confirmLabel: 'Register',
      );

      if (!mounted || confirmed != true) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmailAuthPage(
            initialTabIndex: 1,
            googleProfile: profile,
          ),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSkip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavPage(),
      ),
      (route) => false,
    );
  }

  void _openEmailAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmailAuthPage(),
      ),
    );
  }

  Future<bool?> _showGoogleConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEnd,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final isSmall = width < 360 || height < 740;
            final isWide = width >= 600;
            final horizontalPadding = isWide ? 28.0 : (isSmall ? 16.0 : 18.0);
            final topPadding = isSmall ? 6.0 : 8.0;
            final contentMaxWidth = isWide ? 460.0 : double.infinity;
            final bagSize = isWide ? 94.0 : (isSmall ? 78.0 : 88.0);
            final titleSize = isWide ? 31.0 : (isSmall ? 24.0 : 28.0);
            final titleTopGap = isSmall ? 20.0 : 26.0;
            final sectionGap = isSmall ? 28.0 : 34.0;
            final itemGap = isSmall ? 18.0 : 22.0;
            final buttonHeight = isSmall ? 46.0 : 48.0;
            final footerGap = isSmall ? 14.0 : 18.0;
            final legalSize = isSmall ? 12.0 : 13.0;
            final actionTopGap = isWide ? 120.0 : (isSmall ? 44.0 : 72.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - topPadding - 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
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
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: const Color(0xFF4E89FF),
                                fontSize: isSmall ? 15 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 30 : 42),
                        Image.asset(
                          'assets/images/onboarding_bag.png',
                          width: bagSize,
                          height: bagSize,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: titleTopGap),
                        Text(
                          'Get more from our app.',
                          style: TextStyle(
                            color: const Color(0xFF29498F),
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: sectionGap),
                        _BenefitRow(
                          iconAsset: 'assets/images/new-icon-search.png',
                          title: 'Smart hotel search.',
                          subtitle: 'Find hotels by name or location.',
                          iconSize: isSmall ? 22 : 24,
                          titleSize: isSmall ? 15.0 : 16.0,
                          subtitleSize: isSmall ? 13.0 : 14.0,
                          gap: isSmall ? 14.0 : 16.0,
                        ),
                        SizedBox(height: itemGap),
                        _BenefitRow(
                          iconAsset: 'assets/images/new-icon-room.png',
                          title: 'Easy room booking.',
                          subtitle: 'Choose dates, rooms, and add-ons instantly.',
                          iconSize: isSmall ? 22 : 24,
                          titleSize: isSmall ? 15.0 : 16.0,
                          subtitleSize: isSmall ? 13.0 : 14.0,
                          gap: isSmall ? 14.0 : 16.0,
                        ),
                        SizedBox(height: itemGap),
                        _BenefitRow(
                          iconAsset: 'assets/images/new-icon-digital.png',
                          title: 'Digital receipt & QR.',
                          subtitle: 'Get your booking confirmation with QR code.',
                          iconSize: isSmall ? 22 : 24,
                          titleSize: isSmall ? 15.0 : 16.0,
                          subtitleSize: isSmall ? 13.0 : 14.0,
                          gap: isSmall ? 14.0 : 16.0,
                        ),
                        SizedBox(height: actionTopGap),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleGoogleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryEnd,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.blueLight,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/Google_G_Logo.png',
                                    width: isSmall ? 20 : 22,
                                    height: isSmall ? 20 : 22,
                                  ),
                                  SizedBox(width: isSmall ? 14 : 16),
                                  Text(
                                    _isLoading
                                        ? 'Please wait...'
                                        : 'Continue with Google',
                                    style: TextStyle(
                                      fontSize: isSmall ? 15 : 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 12 : 14),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: OutlinedButton(
                            onPressed: _openEmailAuth,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryEnd,
                              side: const BorderSide(
                                color: AppColors.primaryEnd,
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: const Color(0xFFF3F7FF),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mail_rounded,
                                    size: isSmall ? 18 : 20,
                                  ),
                                  SizedBox(width: isSmall ? 12 : 14),
                                  Text(
                                    'Continue with email',
                                    style: TextStyle(
                                      fontSize: isSmall ? 15 : 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: footerGap),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: const Color(0xFF7C8497),
                              fontSize: legalSize,
                              height: 1.45,
                            ),
                            children: const [
                              TextSpan(text: 'By signing up you accept our '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: Color(0xFF4E89FF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: TextStyle(
                                  color: Color(0xFF4E89FF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.iconSize,
    required this.titleSize,
    required this.subtitleSize,
    required this.gap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final double iconSize;
  final double titleSize;
  final double subtitleSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Image.asset(
            iconAsset,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF29498F),
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFF7C8497),
                  fontSize: subtitleSize,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
