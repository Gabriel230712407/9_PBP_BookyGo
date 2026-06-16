import 'package:flutter/material.dart';
import 'dart:async';

import '../../../core/auth/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../history/pages/history_page.dart';
import '../models/booking_model.dart';
import 'booking_detail_page.dart';
import 'payment_method_page.dart';
import '../services/booking_service.dart';
import '../widgets/mybook_action_button.dart';
import '../widgets/mybook_header.dart';
import '../widgets/mybook_recommendation_section.dart';
import '../../../core/notifications/services/notification_service.dart';

class MyBookPage extends StatefulWidget {
  const MyBookPage({
    super.key,
    required this.onBookNowTap,
  });

  final VoidCallback onBookNowTap;

  @override
  State<MyBookPage> createState() => _MyBookPageState();
}

class _MyBookPageState extends State<MyBookPage> {
  final BookingService _bookingService = BookingService();
  late Future<List<BookingModel>> _futureBookings;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _futureBookings = _bookingService.fetchMyBookings();
    _futureBookings.then(_generateReviewNotifs);
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final bookings = _bookingService.fetchMyBookings();
    setState(() {
      _futureBookings = bookings;
    });
    await bookings;
    final result = await bookings;
    await _generateReviewNotifs(result);
  }

  Future<void> _generateReviewNotifs(List<BookingModel> bookings) async {
    final session = await AuthService.currentSession();
    if (session == null) return;

    for (final booking in bookings) {
      if (!booking.isPaid) continue;
      if (DateTime.now().isBefore(booking.checkOutDate)) continue;
      if (booking.hasReview) continue;

      await NotificationService.maybeGenerateReviewNotification(
        session,
        pemesananId: booking.id.toString(),
        hotelNama: booking.hotelName,
        kodeBooking: booking.bookingCode,
        tglCheckout: booking.checkOutDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 360;

    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: Column(
        children: [
          MyBookHeader(
            onHistoryTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<BookingModel>>(
              future: _futureBookings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _StateMessage(
                    title: 'Unable to load bookings',
                    message: snapshot.error.toString(),
                    actionLabel: 'Retry',
                    onTap: _refresh,
                  );
                }

                final bookings = snapshot.data ?? const [];
                final activeBookings =
                    bookings.where((booking) => booking.isActive).toList();

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (activeBookings.isEmpty)
                              _EmptyBookingState(
                                isCompact: isCompact,
                                onBookNowTap: widget.onBookNowTap,
                              )
                            else
                              _ActiveBookingState(
                                bookings: activeBookings,
                                onBookingUpdated: _refresh,
                              ),
                            SizedBox(height: isCompact ? 28 : 40),
                            const MyBookRecommendationSection(),
                            const SizedBox(height: 24),
                          ]),
                        ),
                      ),
                      // Ini bikin recommendation section mengisi sisa layar
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: SizedBox(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookingState extends StatelessWidget {
  const _EmptyBookingState({
    required this.isCompact,
    required this.onBookNowTap,
  });

  final bool isCompact;
  final VoidCallback onBookNowTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: isCompact ? 28 : 40),
        Image.asset(
          'assets/images/empty_mascot.png',
          width: isCompact ? 142 : 164,
          height: isCompact ? 142 : 164,
          fit: BoxFit.contain,
        ),
        SizedBox(height: isCompact ? 8 : 10),
        const Text(
          'No active orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isCompact ? 12 : 14),
        FutureBuilder(
          future: AuthService.currentSession(),
          builder: (context, snapshot) {
            if ((snapshot.data) == null) {
              return const Text(
                'Sign in first to save and track your bookings.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(height: isCompact ? 8 : 10),
        MyBookActionButton(
          text: 'Book now',
          onPressed: onBookNowTap,
        ),
      ],
    );
  }
}

class _ActiveBookingState extends StatelessWidget {
  const _ActiveBookingState({
    required this.bookings,
    required this.onBookingUpdated,
  });

  final List<BookingModel> bookings;
  final Future<void> Function() onBookingUpdated;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Active booking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...bookings.map(
          (booking) => _ActiveBookingCard(
            booking: booking,
            onBookingUpdated: onBookingUpdated,
          ),
        ),
      ],
    );
  }
}

class _ActiveBookingCard extends StatelessWidget {
  const _ActiveBookingCard({
    required this.booking,
    required this.onBookingUpdated,
  });

  final BookingModel booking;
  final Future<void> Function() onBookingUpdated;

  Future<void> _handleTap(BuildContext context) async {
    if (booking.isPaid) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailPage(booking: booking),
        ),
      );
      return;
    }

    if (!booking.canContinuePayment) {
      if (booking.isExpired) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This payment session has expired. Please create a new booking.',
            ),
          ),
        );
      }
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodPage(initialBooking: booking),
      ),
    );
    await onBookingUpdated();
  }

  @override
  Widget build(BuildContext context) {
    final canTap = booking.isPaid || booking.canContinuePayment;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? () => _handleTap(context) : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  booking.imagePath,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 68,
                    height: 68,
                    color: const Color(0xFFE9EEFF),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.hotelName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                booking.roomName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                booking.formattedDateRange,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          booking.formattedTotalPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryEnd,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _BookingPill(
                          icon: booking.isExpired
                              ? Icons.timer_off_outlined
                              : booking.isPaid
                                  ? Icons.verified_rounded
                                  : Icons.schedule,
                          text: booking.bookingStatusLabel,
                          tone: booking.isExpired
                              ? _BookingPillTone.danger
                              : booking.isPaid
                                  ? _BookingPillTone.success
                                  : _BookingPillTone.info,
                        ),
                        _BookingPill(
                          icon: booking.canContinuePayment
                              ? Icons.payments_outlined
                              : Icons.lock_clock_outlined,
                          text: booking.canContinuePayment
                              ? 'Continue Payment'
                              : booking.isExpired
                                  ? 'Payment closed'
                                  : booking.paymentMethodLabel,
                          tone: booking.canContinuePayment
                              ? _BookingPillTone.action
                              : _BookingPillTone.muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingPill extends StatelessWidget {
  const _BookingPill({
    required this.icon,
    required this.text,
    required this.tone,
  });

  final IconData icon;
  final String text;
  final _BookingPillTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      _BookingPillTone.info => (
          background: const Color(0xFFF1F5FF),
          foreground: AppColors.primaryEnd,
        ),
      _BookingPillTone.action => (
          background: const Color(0xFFEAF2FF),
          foreground: AppColors.primaryEnd,
        ),
      _BookingPillTone.success => (
          background: const Color(0xFFEAF8F0),
          foreground: const Color(0xFF1C9A5E),
        ),
      _BookingPillTone.danger => (
          background: const Color(0xFFFFEFF0),
          foreground: const Color(0xFFD85B64),
        ),
      _BookingPillTone.muted => (
          background: const Color(0xFFF3F4F8),
          foreground: const Color(0xFF8A92AE),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.foreground),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

enum _BookingPillTone { info, action, success, danger, muted }

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                onTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEnd,
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
