import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../mybook/models/booking_model.dart';
import '../../reviews/pages/review_form.dart';

class BookingDetailPage extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  late bool _hasReview;

  @override
  void initState() {
    super.initState();
    _hasReview = widget.booking.hasReview;
  }

  double get subtotal => widget.booking.staySubtotal;
  double get tax => widget.booking.taxAmount;
  double get addonsTotal => widget.booking.addonsTotal;
  double get totalPaid => widget.booking.grandTotal;

  @override
  Widget build(BuildContext context) {
    final isExpired = widget.booking.isExpired;

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
                  color: isExpired
                      ? const Color(0xFFFFEFF0)
                      : widget.booking.isPaid
                          ? const Color(0xFFEAF8F0)
                          : const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isExpired
                      ? 'Expired'
                      : widget.booking.isPaid
                          ? 'Completed'
                          : widget.booking.isPaymentPending
                              ? 'Waiting Payment'
                              : 'Active',
                  style: TextStyle(
                    color: isExpired
                        ? const Color(0xFFD85B64)
                        : widget.booking.isPaid
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
                isExpired
                    ? 'Payment expired'
                    : widget.booking.isPaid
                        ? 'Stay Completed'
                        : widget.booking.isPaymentPending
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
                    child: widget.booking.imagePath.startsWith('http')
                        ? Image.network(
                            widget.booking.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.booking.imagePath,
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
                          widget.booking.hotelName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.booking.roomName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.booking.hotelAddress,
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

            // Check-in / Check-out / Duration / Guests 2x2 grid
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SmallInfoCard(
                        title: 'CHECK-IN',
                        subtitle: BookingFormatters.dayMonthYear(widget.booking.checkInDate),
                        extra: 'From 14:00',
                        backgroundColor: const Color(0xFFE6F0FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallInfoCard(
                        title: 'CHECK-OUT',
                        subtitle: BookingFormatters.dayMonthYear(widget.booking.checkOutDate),
                        extra: 'From 12:00',
                        backgroundColor: const Color(0xFFE6F0FF),
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
                        subtitle: widget.booking.stayLabel,
                        icon: Icons.nightlight_round,
                        backgroundColor: const Color(0xFFE6F0FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SmallInfoCard(
                        title: 'GUESTS',
                        subtitle: widget.booking.guestCountLabel,
                        icon: Icons.person,
                        backgroundColor: const Color(0xFFE6F0FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Summary
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
                  _PaymentRow(
                      label: 'Subtotal',
                      value: BookingFormatters.currency(subtotal)),
                  _PaymentRow(label: 'Tax (10%)', value: BookingFormatters.currency(tax)),
                  _PaymentRow(label: 'Add-ons', value: BookingFormatters.currency(addonsTotal)),
                  const Divider(),
                  _PaymentRow(
                    label: 'TOTAL PAID',
                    value: BookingFormatters.currency(totalPaid),
                    valueColor: AppColors.primaryEnd,
                  ),
                  const SizedBox(height: 6),
                  if (!widget.booking.isExpired) // <-- hanya tampil jika tidak expired
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.blueSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.credit_card, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            widget.booking.paymentMethodLabel,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          if (widget.booking.isPaid)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

            // Tombol
            BookingActionButton(
              booking: widget.booking,
              hasReview: _hasReview,
              onReview: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewFormPage(
                      booking: widget.booking,
                      isEditing: _hasReview,
                    ),
                  ),
                );

                if (result == true) {
                  setState(() {
                    _hasReview = true;
                    widget.booking.hasReview = true;
                  });
                }

                if (result == 'deleted') {
                  setState(() {
                    _hasReview = false;
                    widget.booking.hasReview = false;
                    widget.booking.reviewId = null;
                    widget.booking.reviewRating = null;
                    widget.booking.reviewComment = null;
                    widget.booking.reviewPhotos = null;
                  });
                }
              },
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
        color: backgroundColor,
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

class BookingActionButton extends StatelessWidget {
  final BookingModel booking;
  final bool hasReview;
  final VoidCallback? onReview;

  const BookingActionButton({
    super.key,
    required this.booking,
    required this.hasReview,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = booking.isExpired;

    // Kalau mau pakai tanggal asli nanti pakenya inii:
    // final isAfterCheckout = DateTime.now().isAfter(booking.checkOutDate);

    final isAfterCheckout = true; // sementara untuk data dummy

    String buttonLabel;
    IconData iconData;
    bool isDisabled;

    if (isExpired) {
      buttonLabel = 'Payment Expired';
      iconData = Icons.block;
      isDisabled = true;
    } else if (!isAfterCheckout) {
      buttonLabel = 'Cannot review yet';
      iconData = Icons.block;
      isDisabled = true;
    } else {
      if (hasReview) {
        buttonLabel = 'Edit Review';
        iconData = Icons.edit;
        isDisabled = false;
      } else {
        buttonLabel = 'Write a Review';
        iconData = Icons.rate_review;
        isDisabled = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled ? Colors.grey : AppColors.primaryEnd,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isDisabled ? null : onReview,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  buttonLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (!isAfterCheckout && !isExpired) ...[
          const SizedBox(height: 4),
          const Text(
            '*Review will be opened after checkout period ends',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
