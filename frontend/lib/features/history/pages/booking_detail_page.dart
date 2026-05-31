import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../mybook/models/booking_model.dart';

class BookingDetailPage extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryEnd,
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        leading: BackButton(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: AppColors.bgVeryLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status pill
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: booking.isExpired
                      ? const Color(0xFFFFEFF0)
                      : booking.isPaid
                          ? const Color(0xFFEAF8F0)
                          : const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.isExpired
                      ? 'Expired'
                      : booking.isPaid
                          ? 'Completed'
                          : booking.isPaymentPending
                              ? 'Waiting Payment'
                              : 'Active',
                  style: TextStyle(
                    color: booking.isExpired
                        ? const Color(0xFFD85B64)
                        : booking.isPaid
                            ? const Color(0xFF1C9A5E)
                            : AppColors.primaryEnd,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                booking.isExpired
                    ? 'Payment expired'
                    : booking.isPaid
                        ? 'Stay Completed'
                        : booking.isPaymentPending
                            ? 'Waiting for Payment'
                            : 'Active Booking',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Card hotel + room
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: booking.imagePath.startsWith('http')
                        ? Image.network(
                            booking.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            booking.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.hotelName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.roomName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.hotelAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SmallInfoCard(
                        title: 'CHECK-IN',
                        subtitle: BookingFormatters.dayMonthYear(booking.checkInDate),
                        extra: 'From 14:00',
                        backgroundColor: Color(0xFFE6F0FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallInfoCard(
                        title: 'CHECK-OUT',
                        subtitle: BookingFormatters.dayMonthYear(booking.checkOutDate),
                        extra: 'From 12:00',
                        backgroundColor: Color(0xFFE6F0FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _SmallInfoCard(
                        title: 'DURATION',
                        subtitle: booking.stayLabel,
                        icon: Icons.nightlight_round,
                        backgroundColor: Color(0xFFE6F0FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallInfoCard(
                        title: 'GUESTS',
                        subtitle: '2 Adults',
                        icon: Icons.person,
                        backgroundColor: Color(0xFFE6F0FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Payment Summary',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlue),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _PaymentRow(label: 'Subtotal', value: 'IDR 1,000,000'),
                  _PaymentRow(label: 'Tax (10%)', value: 'IDR 102,050'),
                  _PaymentRow(label: 'Service Fee', value: 'IDR 75,000'),
                  const Divider(),
                  _PaymentRow(
                    label: 'TOTAL PAID',
                    value: 'IDR 1,177,050',
                    valueColor: AppColors.primaryEnd,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card, size: 14),
                        const SizedBox(width: 6),
                        const Text(
                          'BRI Virtual Account',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryEnd.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PAID',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryEnd),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Write a Review Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEnd,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.edit, size: 16, color: AppColors.white),
                    SizedBox(width: 6),
                    Text(
                      'Write a Review',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? extra;
  final IconData? icon;
  final Color backgroundColor;

  const _SmallInfoCard({
    required this.title,
    required this.subtitle,
    this.extra,
    this.icon,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor, // pakai color card biru muda
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 16, color: AppColors.primaryEnd),
              if (icon != null) const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkBlue),
              ),
            ],
          ),
          if (extra != null)
            Text(extra!,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PaymentRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,                  
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}