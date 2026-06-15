import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../services/booking_receipt_pdf_service.dart';

class BookingReceiptPreviewPage extends StatelessWidget {
  const BookingReceiptPreviewPage({
    super.key,
    required this.booking,
    required this.pdfBytes,
    required this.fileName,
  });

  final BookingModel booking;
  final Uint8List pdfBytes;
  final String fileName;

  Future<void> _sharePdf() {
    return Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  Future<void> _printPdf() {
    return Printing.layoutPdf(name: fileName, onLayout: (_) async => pdfBytes);
  }

  Future<void> _savePdf() {
    return Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
        ),
        title: const Text(
          'Preview PDF',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Detail',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID : ${booking.bookingCode}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _HotelHeading(booking: booking),
              const SizedBox(height: 24),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 20),
              _StayGrid(booking: booking),
              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 16),
              _GuestGrid(booking: booking),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 14),
              _PaymentRows(booking: booking),
              const SizedBox(height: 12),
              _PaymentMethod(booking: booking),
              const SizedBox(height: 18),
              _ReceiptQr(booking: booking),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'THANK YOU FOR YOUR BOOKING',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _PreviewActions(
                onShare: _sharePdf,
                onPrint: _printPdf,
                onSave: _savePdf,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotelHeading extends StatelessWidget {
  const _HotelHeading({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          booking.hotelName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          booking.roomName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          booking.hotelAddress,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _StayGrid extends StatelessWidget {
  const _StayGrid({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ReceiptInfoBlock(
                label: 'CHECK-IN',
                value: BookingFormatters.dayMonthYear(booking.checkInDate),
              ),
            ),
            Expanded(
              child: _ReceiptInfoBlock(
                label: 'DURATION',
                value: booking.stayLabel,
                alignRight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _ReceiptInfoBlock(
                label: 'CHECK-OUT',
                value: BookingFormatters.dayMonthYear(booking.checkOutDate),
              ),
            ),
            Expanded(
              child: _ReceiptInfoBlock(
                label: 'GUESTS',
                value: booking.guestCountLabel,
                alignRight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GuestGrid extends StatelessWidget {
  const _GuestGrid({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReceiptInfoBlock(
            label: 'GUEST NAME',
            value: booking.contactName,
          ),
        ),
        Expanded(
          child: _ReceiptInfoBlock(
            label: 'ROOM COUNT',
            value: booking.roomCountLabel,
            alignRight: true,
          ),
        ),
      ],
    );
  }
}

class _PaymentRows extends StatelessWidget {
  const _PaymentRows({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PriceRow(
          label: 'Subtotal',
          value: BookingFormatters.currency(booking.staySubtotal),
          shaded: true,
        ),
        _PriceRow(
          label: 'Tax',
          value: BookingFormatters.currency(booking.taxAmount),
        ),
        _PriceRow(
          label: 'Service Fee',
          value: BookingFormatters.currency(booking.addonsTotal),
          shaded: true,
        ),
        const SizedBox(height: 10),
        _PriceRow(
          label: 'Total Paid',
          value: booking.formattedTotalPrice,
          total: true,
        ),
      ],
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFFE0E5F4)),
            ),
            child: Text(
              booking.paymentMethod == 'ewallet' ? 'QR' : 'BRI',
              style: const TextStyle(
                color: AppColors.primaryEnd,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
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
                  BookingReceiptPdfService.paymentMethodName(booking),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF24C484),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'PAID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptQr extends StatelessWidget {
  const _ReceiptQr({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: QrImageView(
            data: BookingReceiptPdfService.receiptQrData(booking),
            version: QrVersions.auto,
            size: 108,
            gapless: false,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Scan QR for receipt data',
          style: TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ReceiptInfoBlock extends StatelessWidget {
  const _ReceiptInfoBlock({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF4B5578),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.isEmpty ? '-' : value,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.shaded = false,
    this.total = false,
  });

  final String label;
  final String value;
  final bool shaded;
  final bool total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: total ? 0 : 8,
        vertical: total ? 8 : 7,
      ),
      color: shaded ? const Color(0xFFF0F6FF) : Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: total ? 17 : 12,
                color: total ? AppColors.textDark : AppColors.textMuted,
                fontWeight: total ? FontWeight.w900 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: total ? 17 : 12,
              color: total ? AppColors.darkBlue : AppColors.darkBlue,
              fontWeight: total ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewActions extends StatelessWidget {
  const _PreviewActions({
    required this.onShare,
    required this.onPrint,
    required this.onSave,
  });

  final Future<void> Function() onShare;
  final Future<void> Function() onPrint;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(icon: Icons.share, label: 'SHARE', onTap: onShare),
        _ActionButton(icon: Icons.print, label: 'PRINT', onTap: onPrint),
        _ActionButton(
          icon: Icons.download_rounded,
          label: 'SAVE',
          onTap: onSave,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        try {
          await onTap();
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      },
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEDEFF5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textDark, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
