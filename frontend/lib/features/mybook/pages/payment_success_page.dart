import 'package:flutter/material.dart';

import '../../../core/auth/services/auth_service.dart';
import '../../../core/notifications/services/notification_service.dart'; // ✅ tambah import
import '../../../core/theme/app_colors.dart';
import '../../navigation/pages/main_nav_page.dart';
import '../models/booking_model.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({
    super.key,
    required this.booking,
  });

  final BookingModel booking;

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {

  @override
  void initState() {
    super.initState();
    _sendReviewNotification();
  }
  Future<void> _sendReviewNotification() async {
    try {
      final session = await AuthService.currentSession();
      if (session == null) return;

      await NotificationService.maybeGenerateReviewNotification(
        session,
        pemesananId: widget.booking.id.toString(),
        hotelNama: widget.booking.hotelName,
        kodeBooking: widget.booking.bookingCode,
        tglCheckout: widget.booking.checkOutDate,
      );
    } catch (_) {}
  }

  Future<void> _openMyBooking(BuildContext context) async {
    final session = await AuthService.currentSession();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavPage(
          isGuest: session == null,
          userEmail: session?.user.email,
          userName: session?.user.name,
          initialIndex: 1,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset(
                'assets/images/vector_success.png',
                width: 128,
                height: 128,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              const Text(
                'Payment Successful',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your Booking has been confirmed',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9AA3C7),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8ECF7)),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            widget.booking.imagePath,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.booking.hotelName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'BOOKING ID : ${widget.booking.bookingCode}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF98A2C4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE8ECF7)),
                    const SizedBox(height: 14),
                    _SummaryRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Stay Dates',
                      value: widget.booking.formattedDateRange,
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      icon: Icons.home_outlined,
                      label: 'Accommodation',
                      value: '1 Rooms • ${widget.booking.stayLabel}',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _openMyBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEnd,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// _SummaryRow tidak diubah sama sekali
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9AA3C7)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF98A2C4),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}