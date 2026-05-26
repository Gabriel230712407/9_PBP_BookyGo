import 'package:flutter/material.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/notifications/services/notification_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/pages/location_permission_page.dart';

class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({
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
                  padding: const EdgeInsets.fromLTRB(22, 76, 22, 18),
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
                      const Icon(
                        Icons.notifications_rounded,
                        color: AppColors.darkBlue,
                        size: 28,
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7C839F),
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(text: 'Allow '),
                            TextSpan(
                              text: 'BookyGo',
                              style: TextStyle(
                                color: AppColors.primaryEnd,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: ' to send\nyou notifications?'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Turn on notifications so you never miss booking updates and promotions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => _goNext(context, enableNotifications: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryEnd,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Enable Notifications',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _goNext(context, enableNotifications: false),
                        child: const Text(
                          'Not Now',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryEnd,
                          ),
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
  }

  Future<void> _goNext(
    BuildContext context, {
    required bool enableNotifications,
  }) async {
    await NotificationService.setEnabled(session, enableNotifications);
    if (enableNotifications) {
      await NotificationService.seedAfterNotificationEnabled(session);
    }
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPermissionPage(session: session),
      ),
    );
  }
}
