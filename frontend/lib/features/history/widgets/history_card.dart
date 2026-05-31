import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mybook/models/booking_model.dart';
import 'delete_history_dialog.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.booking,
    required this.onDelete,
  });

  final BookingModel booking;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 205),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  booking.imagePath,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 82,
                    height: 82,
                    color: const Color(0xFFE7ECFB),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
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
                        color: AppColors.darkBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.hotelAddress,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID : ${booking.bookingCode}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking.isExpired
                      ? AppColors.bgLight // expired → pink/soft (ganti sesuai style kamu)
                      : booking.isPaid
                          ? AppColors.bgLight // completed → hijau tipis (buat sesuai palet hijau)
                          : booking.canContinuePayment
                              ? AppColors.bgVeryLight // waiting payment → biru soft
                              : AppColors.bgLight, // confirmed
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.isExpired
                      ? 'Expired'
                      : booking.isPaid
                          ? 'Completed'
                          : booking.canContinuePayment
                              ? 'Waiting Payment'
                              : 'Confirmed',
                  style: TextStyle(
                    color: booking.isExpired
                        ? Colors.red // expired text
                        : booking.isPaid
                            ? Colors.green // completed
                            : AppColors.primaryEnd, // waiting/confirmed
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATES',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.formattedDateRange,
                      style: const TextStyle(
                        color: AppColors.darkBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.stayLabel,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.formattedTotalPrice,
                      style: const TextStyle(
                        color: AppColors.primaryEnd,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _HistoryActionButton(
                    text: 'Details',
                    backgroundColor: AppColors.primaryEnd,
                    textColor: AppColors.white,
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => _BookingDetailSheet(booking: booking),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _HistoryActionButton(
                    text: 'Delete',
                    backgroundColor: AppColors.white,
                    textColor: AppColors.primaryEnd,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => const DeleteHistoryDialog(),
                      );

                      if (confirmed == true) {
                        await onDelete();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingDetailSheet extends StatelessWidget {
  const _BookingDetailSheet({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Booking code', value: booking.bookingCode),
          _InfoRow(label: 'Guest', value: booking.contactName),
          _InfoRow(label: 'Room', value: booking.roomName),
          _InfoRow(label: 'Payment', value: booking.paymentMethodLabel),
          _InfoRow(label: 'Stay', value: booking.formattedDateRange),
          _InfoRow(label: 'Phone', value: booking.contactPhone),
          _InfoRow(label: 'Email', value: booking.contactEmail),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryActionButton extends StatelessWidget {
  const _HistoryActionButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: textColor,
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
