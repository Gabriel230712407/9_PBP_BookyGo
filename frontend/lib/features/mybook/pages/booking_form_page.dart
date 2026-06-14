import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/auth/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_image.dart';
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
  final BookingService _bookingService = BookingService();

  String _selectedTitle = 'Mr.';
  bool _isSaving = false;
  bool _isLoadingAddons = true;
  List<Addon> _addons = [];

  @override
  void initState() {
    super.initState();
    _prefillUserData();
    _loadAddons();
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

  Future<void> _loadAddons() async {
    try {
      final addons = await _bookingService.fetchAddons();
      if (!mounted) {
        return;
      }

      setState(() {
        _addons = addons;
        _isLoadingAddons = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _addons = [];
        _isLoadingAddons = false;
      });
    }
  }

  int get _nightCount {
    return math.max(
      1,
      widget.checkOutDate.difference(widget.checkInDate).inDays,
    );
  }

  double get _roomSubtotal {
    return widget.room.rawPrice * _nightCount * widget.roomCount;
  }

  double get _addonsTotal {
    return _addons.fold<double>(
      0,
      (sum, addon) => sum + (addon.selected ? addon.price : 0),
    );
  }

  double get _tax => _roomSubtotal * BookingModel.taxRate;

  double get _grandTotal => _roomSubtotal + _tax + _addonsTotal;

  List<int> get _selectedAddonIds {
    return _addons
        .where((addon) => addon.selected)
        .map((addon) => addon.id)
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
        roomCount: widget.roomCount,
        guestCount: widget.guestCount,
        contactName: '${_selectedTitle.trim()} ${_nameController.text.trim()}',
        contactEmail: _emailController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        addonIds: _selectedAddonIds,
      );

      if (!mounted) {
        return;
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentMethodPage(initialBooking: booking),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleAddon(Addon addon, bool value) {
    setState(() {
      addon.selected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: AppColors.primaryEnd,
        surfaceTintColor: AppColors.primaryEnd,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Your Booking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Contact Details'),
                const SizedBox(height: 16),
                _WhiteCard(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  subtitle:
                      'Complete your data for e-ticket delivery and booking purposes',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _SalutationOption(
                            label: 'Mr.',
                            value: 'Mr.',
                            groupValue: _selectedTitle,
                            onChanged: (value) {
                              setState(() => _selectedTitle = value);
                            },
                          ),
                          const SizedBox(width: 12),
                          _SalutationOption(
                            label: 'Mrs.',
                            value: 'Mrs.',
                            groupValue: _selectedTitle,
                            onChanged: (value) {
                              setState(() => _selectedTitle = value);
                            },
                          ),
                          const SizedBox(width: 12),
                          _SalutationOption(
                            label: 'Ms.',
                            value: 'Ms.',
                            groupValue: _selectedTitle,
                            onChanged: (value) {
                              setState(() => _selectedTitle = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      _BookingField(
                        controller: _emailController,
                        hintText: 'Email Adress',
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
                const SizedBox(height: 20),
                const _SectionHeader(title: 'Stay Details'),
                const SizedBox(height: 10),
                _WhiteCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: _StaySummary(
                          hotel: widget.hotel,
                          room: widget.room,
                          checkInDate: widget.checkInDate,
                          checkOutDate: widget.checkOutDate,
                          nightCount: _nightCount,
                          roomCount: widget.roomCount,
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE3E8F4)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.room.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _RoomInfoRow(
                              icon: Icons.bed_rounded,
                              text: widget.room.bedType.isEmpty
                                  ? widget.room.type
                                  : widget.room.bedType,
                            ),
                            const SizedBox(height: 14),
                            _RoomInfoRow(
                              icon: Icons.smoke_free_rounded,
                              text: widget.room.smokingLabel,
                            ),
                            const SizedBox(height: 18),
                            const Divider(height: 1, color: Color(0xFFE3E8F4)),
                            const SizedBox(height: 18),
                            const Text(
                              'Add on',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (_isLoadingAddons)
                              const Center(child: CircularProgressIndicator())
                            else if (_addons.isEmpty)
                              const Text(
                                'No add-ons available right now.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                              )
                            else
                              ..._addons.map(
                                (addon) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _AddonTile(
                                    addon: addon,
                                    onChanged: (value) =>
                                        _toggleAddon(addon, value),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BookingBottomBar(
        totalPrice: BookingFormatters.currency(_grandTotal),
        isSaving: _isSaving,
        onPressed: _submit,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

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
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF7781A7),
            ),
          ),
        ],
      ],
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.subtitle,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF7781A7),
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class _SalutationOption extends StatelessWidget {
  const _SalutationOption({
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
    final isSelected = value == groupValue;

    return Expanded(
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(30),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryEnd
                      : const Color(0xFFB8BED4),
                  width: 1.6,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryEnd,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF687394),
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
      style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF7D86A7)),
        prefixIcon: prefix,
        prefixIconConstraints: prefix == null
            ? null
            : const BoxConstraints(minWidth: 90, minHeight: 64),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB9C0D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFB9C0D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryEnd, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      ),
    );
  }
}

class _PhonePrefix extends StatelessWidget {
  const _PhonePrefix();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 16),
        Container(
          width: 30,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFD74C3C),
                Color(0xFFD74C3C),
                Colors.white,
                Colors.white,
              ],
              stops: [0, 0.5, 0.5, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 30, color: const Color(0xFFE1E6F2)),
        const SizedBox(width: 10),
        const Text(
          '+62',
          style: TextStyle(fontSize: 12, height: 1.2, color: Color(0xFF5F6B93)),
        ),
      ],
    );
  }
}

class _StaySummary extends StatelessWidget {
  const _StaySummary({
    required this.hotel,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nightCount,
    required this.roomCount,
  });

  final HotelModel hotel;
  final RoomModel room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nightCount;
  final int roomCount;

  @override
  Widget build(BuildContext context) {
    final fallbackImage = hotel.image ?? 'assets/images/onboarding_bag.png';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AppImage(
            imagePath: fallbackImage,
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 92,
              height: 92,
              color: const Color(0xFFE8EEFF),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.primaryEnd,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hotel.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                room.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6E7692),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${BookingFormatters.dayMonthYear(checkInDate)} - ${BookingFormatters.dayMonthYear(checkOutDate)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6E7692)),
              ),
              const SizedBox(height: 8),
              Text(
                '$nightCount Night${nightCount > 1 ? 's' : ''} | $roomCount Room',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6E7692),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomInfoRow extends StatelessWidget {
  const _RoomInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF66719B)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
          ),
        ),
      ],
    );
  }
}

class _AddonTile extends StatelessWidget {
  const _AddonTile({required this.addon, required this.onChanged});

  final Addon addon;
  final ValueChanged<bool> onChanged;

  IconData get _icon {
    final value = addon.name.toLowerCase();
    if (value.contains('breakfast')) {
      return Icons.restaurant_rounded;
    }
    if (value.contains('laundry')) {
      return Icons.local_laundry_service_rounded;
    }
    return Icons.add_box_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(_icon, size: 26, color: const Color(0xFF6F6F6F)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            addon.name,
            style: const TextStyle(fontSize: 16, color: Color(0xFF5E6480)),
          ),
        ),
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: addon.selected,
            side: const BorderSide(color: Color(0xFF7F7F7F), width: 1.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
            activeColor: AppColors.primaryEnd,
            onChanged: (value) => onChanged(value ?? false),
          ),
        ),
        Text(
          BookingFormatters.currency(addon.price),
          style: const TextStyle(fontSize: 15, color: Color(0xFF697089)),
        ),
      ],
    );
  }
}

class _BookingBottomBar extends StatelessWidget {
  const _BookingBottomBar({
    required this.totalPrice,
    required this.isSaving,
    required this.onPressed,
  });

  final String totalPrice;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F5))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total payment (after tax)',
                    style: TextStyle(fontSize: 15, color: AppColors.darkBlue),
                  ),
                ),
                Text(
                  totalPrice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isSaving ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEnd,
                  disabledBackgroundColor: const Color(0xFFB8C4F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Select Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
