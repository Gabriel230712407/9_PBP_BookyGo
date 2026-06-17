import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
import '../models/booking_model.dart';
import '../services/booking_receipt_pdf_service.dart';
import 'booking_receipt_preview_page.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key, required this.booking});

  final BookingModel booking;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool _isGeneratingPdf = false;

  Future<void> _downloadPdf() async {
    if (_isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes = await BookingReceiptPdfService.build(widget.booking);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingReceiptPreviewPage(
            booking: widget.booking,
            pdfBytes: pdfBytes,
            fileName: BookingReceiptPdfService.fileName(widget.booking),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create PDF: $error')));
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primaryEnd,
        surfaceTintColor: AppColors.primaryEnd,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Booking Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    child: Column(
                      children: [
                        _HotelCard(booking: booking),
                        const SizedBox(height: 10),
                        _StayInfoCard(booking: booking),
                        const SizedBox(height: 10),
                        _GuestInfoCard(booking: booking),
                        const SizedBox(height: 10),
                        _PaymentSummaryCard(booking: booking),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPdf ? null : _downloadPdf,
                      icon: const Icon(
                        Icons.download_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Download PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEnd,
                        disabledBackgroundColor: AppColors.blueMedium,
                        elevation: 3,
                        shadowColor: Colors.black.withValues(alpha: 0.18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isGeneratingPdf)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFE9EEF6).withValues(alpha: 0.78),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            color: Color(0xFF9A9A9A),
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Preparing your PDF...',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppImage(
              imagePath: booking.imagePath,
              width: 96,
              height: 86,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 96,
                height: 86,
                color: const Color(0xFFE9EEFF),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.hotelName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    booking.roomName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryEnd,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.hotelAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StayInfoCard extends StatelessWidget {
  const _StayInfoCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateColumn(
                  label: 'Check-in',
                  value: BookingFormatters.dayMonthYear(booking.checkInDate),
                ),
              ),
              Expanded(
                child: _DateColumn(
                  label: 'Check-out',
                  value: BookingFormatters.dayMonthYear(booking.checkOutDate),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _IconInfoRow(
            icon: Icons.schedule_outlined,
            label: 'Duration',
            value: booking.stayLabel,
          ),
          const SizedBox(height: 11),
          _IconInfoRow(
            icon: Icons.person,
            label: 'Guests',
            value: '${booking.guestCountLabel}, ${booking.roomCountLabel}',
          ),
        ],
      ),
    );
  }
}

class _GuestInfoCard extends StatelessWidget {
  const _GuestInfoCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guest Information',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(label: 'Name', value: booking.contactName),
          const SizedBox(height: 10),
          _DetailRow(label: 'Room', value: booking.roomCountLabel),
        ],
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        children: [
          _DetailRow(
            label: 'Subtotal',
            value: BookingFormatters.currency(booking.staySubtotal),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Tax',
            value: BookingFormatters.currency(booking.taxAmount),
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Service Fee',
            value: BookingFormatters.currency(booking.addonsTotal),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _DetailRow(
            label: 'Total Paid',
            value: booking.formattedTotalPrice,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryEnd,
            ),
            valueStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryEnd,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5FC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _PaymentLogo(method: booking.paymentMethod),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paid Via',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _paymentMethodName(booking),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF36C78A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'PAID',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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

  String _paymentMethodName(BookingModel booking) {
    if (booking.paymentMethod == 'ewallet') {
      return 'QRIS';
    }

    if (booking.paymentMethod == 'transfer') {
      return 'BRI Virtual Account';
    }

    return booking.paymentMethodLabel;
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8ECF7)),
      ),
      child: child,
    );
  }
}

class _DateColumn extends StatelessWidget {
  const _DateColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  const _IconInfoRow({
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
      children: [
        Icon(icon, size: 17, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                labelStyle ??
                const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style:
                valueStyle ??
                const TextStyle(
                  fontSize: 11,
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  const _PaymentLogo({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final label = switch (method) {
      'ewallet' => 'QR',
      'transfer' => 'BRI',
      'cash' => 'CARD',
      _ => 'PAY',
    };

    return Container(
      width: label.length > 3 ? 44 : 36,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E5F4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.primaryEnd,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
