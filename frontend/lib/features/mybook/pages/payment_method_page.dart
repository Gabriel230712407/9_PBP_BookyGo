import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../widgets/payment_confirmation_dialog.dart';
import 'payment_success_page.dart';
import 'qris_page.dart';
import 'virtual_account_page.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key, required this.initialBooking});

  final BookingModel initialBooking;

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  static const _paymentSessionDuration = Duration(minutes: 15);

  final BookingService _bookingService = BookingService();
  late BookingModel _booking;
  late String _selectedMethod;
  late final DateTime _deadline;
  Timer? _timer;
  Duration _remaining = _paymentSessionDuration;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking;
    _selectedMethod = _booking.paymentMethod.isNotEmpty
        ? _booking.paymentMethod
        : '';
    _deadline = (_booking.createdAt ?? DateTime.now()).add(
      _paymentSessionDuration,
    );
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final difference = _deadline.difference(DateTime.now());
    if (!mounted) return;
    setState(() {
      _remaining = difference.isNegative ? Duration.zero : difference;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _payNow() async {
    if (_selectedMethod.isEmpty || _remaining == Duration.zero) {
      if (_remaining == Duration.zero && mounted) {
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

    // QRIS shows the QR details first; payment is confirmed from that page.
    if (_selectedMethod == 'qris') {
      final confirmed = await _showPaymentConfirmation();
      if (confirmed != true) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QrisPage(
            booking: _booking,
            deadline: _deadline,
          ),
        ),
      );
      return;
    }

    // ── Metode lain: tampilkan dialog konfirmasi ───────────────
    final confirmed = await _showPaymentConfirmation();
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      final backendPaymentMethod = _toBackendPaymentMethod(_selectedMethod);
      final updatedBooking = await _bookingService.updateBooking(
        bookingId: _booking.id,
        paymentMethod: backendPaymentMethod,
        status: _selectedMethod == 'bri_va' ? 'pending' : 'confirmed',
      );

      if (!mounted) return;

      if (_selectedMethod == 'bri_va') {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VirtualAccountPage(booking: updatedBooking),
          ),
        );
      } else {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(booking: updatedBooking),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _toBackendPaymentMethod(String selectedMethod) {
    switch (selectedMethod) {
      case 'bri_va':
        return 'transfer';
      case 'qris':
        return 'ewallet';
      case 'card':
        return 'cash';
      default:
        return 'transfer';
    }
  }

  Future<bool?> _showPaymentConfirmation() {
    final message = switch (_selectedMethod) {
      'qris' =>
        'You are about to continue to QRIS payment for ${_booking.hotelName} for ${_booking.formattedTotalPrice}.',
      'card' =>
        'You are about to make a payment for ${_booking.hotelName} for ${_booking.formattedTotalPrice} using credit/debit card.',
      'bri_va' =>
        'You are about to make a payment for ${_booking.hotelName} for ${_booking.formattedTotalPrice} via BRI Virtual Account.',
      _ =>
        'You are about to make a payment for ${_booking.hotelName} for ${_booking.formattedTotalPrice}.',
    };

    return showDialog<bool>(
      context: context,
      builder: (_) => PaymentConfirmationDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: AppColors.primaryEnd,
        surfaceTintColor: AppColors.primaryEnd,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Continue Payment',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Order ID : ${_booking.bookingCode}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFDFE7FF)),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Complete Before',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              _TimerBadge(remaining: _remaining),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _BookingSummaryCard(booking: _booking),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _PaymentMethodTile(
                            icon: Icons.credit_card_rounded,
                            title: 'Use Credit/DebitCard',
                            value: 'card',
                            groupValue: _selectedMethod,
                            onChanged: (v) =>
                                setState(() => _selectedMethod = v),
                          ),
                          const SizedBox(height: 18),
                          _PaymentMethodTile(
                            useBriBadge: true,
                            title: 'BRI Virtual Account',
                            value: 'bri_va',
                            groupValue: _selectedMethod,
                            onChanged: (v) =>
                                setState(() => _selectedMethod = v),
                          ),
                          const SizedBox(height: 18),
                          _PaymentMethodTile(
                            icon: Icons.qr_code_2_rounded,
                            title: 'QRIS',
                            value: 'qris',
                            groupValue: _selectedMethod,
                            onChanged: (v) =>
                                setState(() => _selectedMethod = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _PaymentBottomBar(
              booking: _booking,
              isEnabled: _selectedMethod.isNotEmpty &&
                  !_isSubmitting &&
                  _remaining != Duration.zero,
              isSubmitting: _isSubmitting,
              onPressed: _payNow,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Widgets (tidak ada perubahan dari versi sebelumnya)
// ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DEED)),
      ),
      child: child,
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  const _BookingSummaryCard({required this.booking});
  final BookingModel booking;

  String get _nightLabel {
    final nights = booking.payableNightCount;
    return '$nights night${nights > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE2F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              size: 22,
              color: Color(0xFFD69B17),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        booking.roomCountLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${BookingFormatters.dayMonthYear(booking.checkInDate)}  |  $_nightLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF727C9B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.remaining});
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes =
        remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      children: [
        _TimerChip(label: hours),
        const SizedBox(width: 4),
        _TimerSeparator(),
        const SizedBox(width: 4),
        _TimerChip(label: minutes),
        const SizedBox(width: 4),
        _TimerSeparator(),
        const SizedBox(width: 4),
        _TimerChip(label: seconds),
      ],
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFC46E61),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TimerSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      ':',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Color(0xFFC46E61),
      ),
    );
  }
}

// ← DIUBAH: tidak ada lagi qrisData / virtualAccountNumber / inline expansion
class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    this.icon,
    this.useBriBadge = false,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final IconData? icon;
  final bool useBriBadge;
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEBF0FF)  // sedikit biru saat terpilih
              : const Color(0xFFF1F4FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryEnd        // border biru saat terpilih
                : const Color(0xFFD6DCEB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: useBriBadge
                  ? const Text(
                      'BRI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryEnd,
                      ),
                    )
                  : Icon(icon, size: 30, color: AppColors.primaryEnd),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            // Radio button
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryEnd
                      : const Color(0xFFB5B5B5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryEnd,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBottomBar extends StatelessWidget {
  const _PaymentBottomBar({
    required this.booking,
    required this.isEnabled,
    required this.isSubmitting,
    required this.onPressed,
  });

  final BookingModel booking;
  final bool isEnabled;
  final bool isSubmitting;
  final VoidCallback onPressed;

  void _showPriceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PriceDetailsSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE3E8F4))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showPriceDetails(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            booking.formattedTotalPrice,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 196,
              height: 60,
              child: ElevatedButton(
                onPressed: isEnabled ? onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEnd,
                  disabledBackgroundColor: const Color(0xFFBDBDBD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withValues(alpha: 0.16),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Pay Now',
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
    );
  }
}

class _PriceDetailsSheet extends StatelessWidget {
  const _PriceDetailsSheet({required this.booking});

  final BookingModel booking;

  String get _roomLine {
    final nights = booking.payableNightCount;
    final rooms = booking.roomCount;
    return '${booking.roomName} - $rooms room${rooms > 1 ? 's' : ''} - $nights night${nights > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(top: 64),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Price Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                booking.hotelName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _roomLine,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF727C9B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              _PriceInfoPanel(
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'Room price',
                      value: BookingFormatters.currency(booking.totalPrice),
                      helper: 'per night',
                    ),
                    _PriceRow(
                      label: 'Room subtotal',
                      value: BookingFormatters.currency(booking.staySubtotal),
                      helper:
                          '${booking.roomCountLabel} x ${booking.stayLabel}',
                    ),
                    if (booking.addons.isNotEmpty) ...[
                      const _PriceDivider(),
                      ...booking.addons.map(
                        (addon) => _PriceRow(
                          label: addon.name,
                          value: BookingFormatters.currency(addon.price),
                          helper: 'Add-on',
                        ),
                      ),
                    ] else ...[
                      const _PriceDivider(),
                      const _PriceRow(
                        label: 'Add-ons',
                        value: 'None',
                      ),
                    ],
                    const _PriceDivider(),
                    _PriceRow(
                      label: 'Tax',
                      value: BookingFormatters.currency(booking.taxAmount),
                      helper:
                          '${(BookingModel.taxRate * 100).toStringAsFixed(0)}% of room subtotal',
                    ),
                    const _PriceDivider(),
                    _PriceRow(
                      label: 'Total',
                      value: booking.formattedTotalPrice,
                      isTotal: true,
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

class _PriceInfoPanel extends StatelessWidget {
  const _PriceInfoPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE2F0)),
      ),
      child: child,
    );
  }
}

class _PriceDivider extends StatelessWidget {
  const _PriceDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 22, color: Color(0xFFE1E6F2));
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.helper,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final String? helper;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: isTotal ? 16 : 14,
      fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
      color: AppColors.textDark,
    );
    final valueStyle = TextStyle(
      fontSize: isTotal ? 16 : 14,
      fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
      color: AppColors.darkBlue,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                if (helper != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    helper!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7B849D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(value, textAlign: TextAlign.right, style: valueStyle),
        ],
      ),
    );
  }
}
