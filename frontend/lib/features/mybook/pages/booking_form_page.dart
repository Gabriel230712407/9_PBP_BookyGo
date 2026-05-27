import 'package:flutter/material.dart';

import '../../../core/auth/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../hotel/models/hotel_model.dart';
import '../../room/models/room_model.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import 'payment_method_page.dart';

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomCount,
    required this.guestCount,
  });

  final HotelModel hotel;
  final RoomModel room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomCount;
  final int guestCount;

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _guestNameController = TextEditingController();
  final BookingService _bookingService = BookingService();

  String _selectedTitle = 'Mr.';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    final session = await AuthService.currentSession();
    if (!mounted || session == null) {
      return;
    }

    setState(() {
      _nameController.text = session.user.name;
      _emailController.text = session.user.email;
      if ((session.user.phoneNumber ?? '').trim().isNotEmpty) {
        _phoneController.text = session.user.phoneNumber!.trim();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final booking = await _bookingService.createBooking(
        roomId: widget.room.id,
        checkInDate: widget.checkInDate,
        checkOutDate: widget.checkOutDate,
        contactName: '${_selectedTitle.trim()} ${_nameController.text.trim()}',
        contactEmail: _emailController.text.trim(),
        contactPhone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentMethodPage(initialBooking: booking),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalNights = widget.checkOutDate.difference(widget.checkInDate).inDays;

    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Your Booking',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  title: 'Contact Details',
                  subtitle:
                      'Complete the details with your data for e-ticket delivery and booking purposes',
                ),
                const SizedBox(height: 10),
                _CardShell(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _TitleOption(
                            label: 'Mr.',
                            value: 'Mr.',
                            groupValue: _selectedTitle,
                            onChanged: (value) {
                              setState(() => _selectedTitle = value);
                            },
                          ),
                          _TitleOption(
                            label: 'Mrs.',
                            value: 'Mrs.',
                            groupValue: _selectedTitle,
                            onChanged: (value) {
                              setState(() => _selectedTitle = value);
                            },
                          ),
                          _TitleOption(
                            label: 'Ms.',
                            value: 'Ms.',
                            groupValue: _selectedTitle,
                            onChanged: (value) {
                              setState(() => _selectedTitle = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _BookingField(
                        controller: _nameController,
                        hintText: 'Full Name',
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Full name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _BookingField(
                        controller: _phoneController,
                        hintText: 'Mobile Number',
                        keyboardType: TextInputType.phone,
                        prefix: const _PhonePrefix(),
                        validator: (value) {
                          if ((value ?? '').trim().length < 8) {
                            return 'Enter a valid phone number.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _BookingField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty || !text.contains('@')) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const _SectionTitle(title: 'Stay Details'),
                const SizedBox(height: 8),
                _CardShell(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              widget.hotel.image ?? 'assets/images/onboarding_bag.png',
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 54,
                                height: 54,
                                color: const Color(0xFFE8EEFF),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.hotel.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${BookingFormatters.dayMonthYear(widget.checkInDate)} - ${BookingFormatters.dayMonthYear(widget.checkOutDate)}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF7E88AF),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$totalNights Night${totalNights > 1 ? 's' : ''} • ${widget.roomCount} Room',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF7E88AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFE8ECF7)),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.room.name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF7E88AF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'Total payment (after tax)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7E88AF),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            BookingFormatters.currency(widget.room.rawPrice),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryEnd,
                            disabledBackgroundColor: const Color(0xFFB8C4F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Select Payment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _CardShell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.smoke_free_outlined,
                            size: 16,
                            color: AppColors.primaryEnd,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.room.smokingLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 22, color: Color(0xFFE8ECF7)),
                      const Text(
                        'Room 1',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7E88AF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _BookingField(
                        controller: _guestNameController,
                        hintText: 'Enter guest name here',
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Guest name is required.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 11,
              height: 1.35,
              color: Color(0xFF96A0C1),
            ),
          ),
        ],
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF7)),
      ),
      child: child,
    );
  }
}

class _TitleOption extends StatelessWidget {
  const _TitleOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: AppColors.primaryEnd,
              visualDensity: VisualDensity.compact,
              onChanged: (selected) {
                if (selected != null) {
                  onChanged(selected);
                }
              },
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6C7699),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingField extends StatelessWidget {
  const _BookingField({
    required this.controller,
    required this.hintText,
    required this.validator,
    this.keyboardType,
    this.prefix,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFAFB7D0)),
        prefixIcon: prefix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD6DDF3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD6DDF3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryEnd),
        ),
      ),
    );
  }
}

class _PhonePrefix extends StatelessWidget {
  const _PhonePrefix();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 18,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.red, Colors.white, Colors.white],
                stops: [0, 0.5, 0.5, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '+62',
            style: TextStyle(fontSize: 11, color: Color(0xFF6C7699)),
          ),
        ],
      ),
    );
  }
}
