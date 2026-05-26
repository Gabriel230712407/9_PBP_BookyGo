import 'package:flutter/material.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/notifications/services/notification_service.dart';
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 6,
                  child: Image.asset(
                    'assets/images/vector_permission.png',
                    width: 164,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 104),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(22, 76, 22, 18),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: AppColors.darkBlue,
                              size: 28,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Allow BookyGo to access your device location?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7C839F),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.borderLight),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                        child: Row(
                          children: const [
                            Expanded(
                              child: _LocationOption(
                                icon: Icons.gps_fixed_rounded,
                                title: 'Precise',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _LocationOption(
                                icon: Icons.pin_drop_outlined,
                                title: 'Approximate',
                              ),
                            ),
                          ],
                        ),
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _finish(BuildContext context) async {
    await AuthService.completePermissionFlow(session);
    await NotificationService.maybeLogLocationPreference(session);
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
          height: 112,
          decoration: BoxDecoration(
            color: AppColors.bgVeryLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.blueSoft),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 42,
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
        padding: const EdgeInsets.symmetric(vertical: 18),
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
