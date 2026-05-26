import 'package:flutter/material.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/navigation/pages/main_nav_page.dart';

class LocationPermissionPage extends StatelessWidget {
  const LocationPermissionPage({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryEnd,
                    size: 38,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Allow BookyGo to access your device location?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(
                        child: _LocationOption(
                          icon: Icons.gps_fixed_rounded,
                          title: 'Precise',
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _LocationOption(
                          icon: Icons.pin_drop_outlined,
                          title: 'Approximate',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _ActionRow(
                    label: 'While Using the App',
                    onTap: () => _finish(context),
                  ),
                  _ActionRow(
                    label: 'Only this Time',
                    onTap: () => _finish(context),
                  ),
                  _ActionRow(
                    label: 'Don\'t Allow',
                    onTap: () => _finish(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish(BuildContext context) async {
    await AuthService.completePermissionFlow(session);
    if (!context.mounted) return;

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
  }
}

class _LocationOption extends StatelessWidget {
  const _LocationOption({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 124,
          decoration: BoxDecoration(
            color: AppColors.bgVeryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.blueSoft),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 48,
              color: AppColors.primaryEnd,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryEnd,
          ),
        ),
      ),
    );
  }
}
