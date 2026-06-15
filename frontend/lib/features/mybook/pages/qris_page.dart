import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'payment_success_page.dart';

class QrisPage extends StatefulWidget {
  const QrisPage({super.key, required this.booking, required this.deadline});

  final BookingModel booking;
  final DateTime deadline;

  @override
  State<QrisPage> createState() => _QrisPageState();
}

class _QrisPageState extends State<QrisPage> {
  final BookingService _bookingService = BookingService();

  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isChecking = false;

  String get _qrisData =>
      'BOOKING:${widget.booking.bookingCode}|TOTAL:${widget.booking.formattedTotalPrice}';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final diff = widget.deadline.difference(DateTime.now());
    if (!mounted) return;
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final updatedBooking = await _bookingService.updateBooking(
        bookingId: widget.booking.id,
        paymentMethod: 'ewallet',
        status: 'confirmed',
      );

      if (!mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(booking: updatedBooking),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryEnd,
        surfaceTintColor: AppColors.primaryEnd,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Order ID : ${widget.booking.bookingCode}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFDFE7FF)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            children: [
              // ── Info pemesanan ────────────────────────────
              _BookingInfoCard(booking: widget.booking),
              const SizedBox(height: 20),

              // ── QR code + countdown + tombol ──────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD8DEED)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'QRIS',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // QR code
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE3E8F4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _qrisData,
                        version: QrVersions.auto,
                        size: 210,
                        gapless: false,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Countdown
                    const Text(
                      'Countdown',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7E88AF),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _CountdownRow(remaining: _remaining),
                    const SizedBox(height: 28),

                    // Tombol Check Status
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _remaining == Duration.zero || _isChecking
                            ? null
                            : _checkStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryEnd,
                          disabledBackgroundColor: const Color(0xFFBDBDBD),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isChecking
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Check Status',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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

// ─────────────────────────────────────────────────────────
// Widget: info hotel ringkas di atas QR
// ─────────────────────────────────────────────────────────
class _BookingInfoCard extends StatelessWidget {
  const _BookingInfoCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DEED)),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Hotel', value: booking.hotelName),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Check-in',
            value: BookingFormatters.dayMonthYear(booking.checkInDate),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Check-out',
            value: BookingFormatters.dayMonthYear(booking.checkOutDate),
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Guest', value: booking.contactName),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE3E8F4), height: 1),
          ),
          _InfoRow(
            label: 'Amount',
            value: booking.formattedTotalPrice,
            valueStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryEnd,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7E88AF)),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          ':',
          style: TextStyle(fontSize: 13, color: Color(0xFF7E88AF)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style:
                valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Widget: countdown chips (HH : MM : SS)
// ─────────────────────────────────────────────────────────
class _CountdownRow extends StatelessWidget {
  const _CountdownRow({required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Chip(label: hours),
        const SizedBox(width: 4),
        _Sep(),
        const SizedBox(width: 4),
        _Chip(label: minutes),
        const SizedBox(width: 4),
        _Sep(),
        const SizedBox(width: 4),
        _Chip(label: seconds),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFC46E61),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      ':',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFFC46E61),
      ),
    );
  }
}
