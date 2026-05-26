import 'package:flutter/material.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/notifications/models/app_notification.dart';
import 'package:frontend/core/notifications/services/notification_service.dart';
import 'package:frontend/core/theme/app_colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    required this.session,
  });

  final AuthSession session;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<AppNotification> _items = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await NotificationService.getNotifications(widget.session);
    if (!mounted) return;

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead(widget.session);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.bgVeryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const _EmptyNotificationState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _NotificationCard(item: item);
                  },
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
  });

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isRead ? AppColors.borderLight : AppColors.blueLight,
          width: item.isRead ? 1 : 1.4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _iconForType(item.type),
              color: AppColors.primaryEnd,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: AppColors.darkBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryEnd,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(item.createdAt),
                  style: const TextStyle(
                    color: AppColors.mutedBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'profile':
        return Icons.person_outline_rounded;
      case 'location':
        return Icons.location_on_outlined;
      case 'welcome':
        return Icons.hotel_rounded;
      case 'activity':
        return Icons.bolt_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/empty_mascot.png',
              width: 110,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                color: AppColors.darkBlue,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once your account activity starts, updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
