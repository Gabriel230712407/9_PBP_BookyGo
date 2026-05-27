import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'payment_success_page.dart';
import 'virtual_account_page.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({
    super.key,
    required this.initialBooking,
  });

  final BookingModel initialBooking;

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final BookingService _bookingService = BookingService();
  late BookingModel _booking;
  late String _selectedMethod;
  late final DateTime _deadline;
  Timer? _timer;
  Duration _remaining = const Duration(minutes: 8, seconds: 40);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking;
    _selectedMethod = _booking.paymentMethod.isNotEmpty ? _booking.paymentMethod : '';
    _deadline = (_booking.createdAt ?? DateTime.now()).add(
      const Duration(minutes: 8, seconds: 40),
    );
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final difference = _deadline.difference(DateTime.now());
    if (!mounted) {
      return;
    }

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

    final confirmed = await _showPaymentConfirmation();
    if (confirmed != true) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final backendPaymentMethod = _toBackendPaymentMethod(_selectedMethod);
      final backendStatus = _selectedMethod == 'bri_va' ? 'pending' : 'confirmed';

      final updatedBooking = await _bookingService.updateBooking(
        bookingId: _booking.id,
        paymentMethod: backendPaymentMethod,
        status: backendStatus,
      );

      if (!mounted) return;

      if (_selectedMethod == 'bri_va') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VirtualAccountPage(booking: updatedBooking),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(booking: updatedBooking),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Confirm Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            _selectedMethod == 'bri_va'
                ? 'Continue to BRI Virtual Account payment details?'
                : 'Confirm this payment and continue to the success page?',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7E88AF),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF7E88AF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryEnd,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Continue Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Order ID : ${_booking.bookingCode}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9AA3C7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Complete Before',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Spacer(),
                              _TimerBadge(remaining: _remaining),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _BookingSummaryTile(booking: _booking),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PaymentMethodOption(
                            icon: Icons.credit_card,
                            title: 'Use Credit/DebitCard',
                            value: 'card',
                            groupValue: _selectedMethod,
                            onChanged: (value) {
                              setState(() => _selectedMethod = value);
                            },
                          ),
                          const SizedBox(height: 10),
                          _PaymentMethodOption(
                            icon: Icons.account_balance,
                            title: 'BRI Virtual Account',
                            value: 'bri_va',
                            groupValue: _selectedMethod,
                            onChanged: (value) {
                              setState(() => _selectedMethod = value);
                            },
                          ),
                          const SizedBox(height: 10),
                          _PaymentMethodOption(
                            icon: Icons.qr_code_2,
                            title: 'QRIS',
                            value: 'qris',
                            groupValue: _selectedMethod,
                            onChanged: (value) {
                              setState(() => _selectedMethod = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE6EBFA))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _booking.formattedTotalPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
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
                  SizedBox(
                    width: 160,
                    height: 46,
                    child: ElevatedButton(
                      onPressed:
                          _selectedMethod.isEmpty ||
                                  _isSubmitting ||
                                  _remaining == Duration.zero
                              ? null
                              : _payNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryEnd,
                        disabledBackgroundColor: const Color(0xFFD3D7E3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Pay Now',
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
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDE4F2)),
      ),
      child: child,
    );
  }
}

class _BookingSummaryTile extends StatelessWidget {
  const _BookingSummaryTile({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E5F4)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              booking.imagePath,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.hotelName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.roomCountLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${booking.formattedShortDateRange} • ${booking.stayLabel}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF8D97BA),
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
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      children: [
        _SingleBadge(label: hours),
        const SizedBox(width: 4),
        _SingleBadge(label: minutes),
        const SizedBox(width: 4),
        _SingleBadge(label: seconds),
      ],
    );
  }
}

class _SingleBadge extends StatelessWidget {
  const _SingleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE96F70),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E5F4)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, size: 15, color: AppColors.primaryEnd),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryEnd
                      : const Color(0xFFB7BECD),
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryEnd,
                          shape: BoxShape.circle,
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
