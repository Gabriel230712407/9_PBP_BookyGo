import 'package:flutter/material.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/notifications/models/app_notification.dart';
import 'package:frontend/core/notifications/services/notification_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/mybook/models/booking_model.dart';
import 'package:frontend/features/mybook/services/booking_service.dart';
import 'package:frontend/features/reviews/pages/review_form.dart';

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

  Future<void> _deleteNotification(AppNotification item) async {
    await NotificationService.deleteNotification(widget.session, item.id);
    if (!mounted) return;
    setState(() {
      _items = _items.where((n) => n.id != item.id).toList();
    });
  }

  Future<void> _handleNotifTap(AppNotification item) async {
  await NotificationService.markAsRead(widget.session, item.id);

  if (!mounted) return;

  if (item.type == 'review' && item.data != null) {
    final pemesananId = item.data!['pemesanan_id'] as String?;
    if (pemesananId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final booking = await BookingService().fetchBookingById(int.parse(pemesananId));
      if (!mounted) return;
      Navigator.pop(context);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewFormPage(booking: booking),
        ),
      );

      if (result == true) {
        await NotificationService.deleteNotification(widget.session, item.id);
        if (!mounted) return;
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        await _load();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load booking data')),
      );
    }
  }
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
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteNotification(item),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 4, 0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
                            SizedBox(height: 4),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => _handleNotifTap(item),
                        child: _NotificationCard(item: item),
                      ),
                    );
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
      case 'review':                         
        return Icons.rate_review_outlined;
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
