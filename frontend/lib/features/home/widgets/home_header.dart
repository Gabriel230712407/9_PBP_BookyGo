import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.notificationsEnabled,
    required this.unreadCount,
    required this.onNotificationTap,
  });

  final String userName;
  final bool notificationsEnabled;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Where do you want\nto stay today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(
                      alpha: notificationsEnabled ? 0.18 : 0.10,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    notificationsEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    color: AppColors.white,
                    size: 26,
                  ),
                ),
                if (notificationsEnabled && unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: 10,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: AppColors.primaryEnd,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
