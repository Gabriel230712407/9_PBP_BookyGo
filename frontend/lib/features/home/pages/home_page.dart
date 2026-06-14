import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/core/auth/models/auth_session.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/notifications/services/notification_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/home/widgets/home_header.dart';
import 'package:frontend/features/home/widgets/search_section.dart';
import 'package:frontend/features/hotel/pages/hotel_list_page.dart';
import 'package:frontend/features/notifications/pages/notification_page.dart';
import 'package:frontend/features/profile/providers/reminder_provider.dart';
import 'package:frontend/features/hotel/models/hotel_model.dart';
import 'package:frontend/features/hotel/services/hotel_service.dart';
import 'package:frontend/features/hotel/pages/hotel_detail.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/mybook/services/booking_service.dart';
import 'package:frontend/features/home/widgets/promo_banner_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.isGuest = true,
    this.userEmail,
    this.userName,
    this.refreshToken = 0,
  });

  final bool isGuest;
  final String? userEmail;
  final String? userName;
  final int refreshToken;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthSession? _session;
  int _unreadCount = 0;

  static const List<String> _destinations = [
    'Yogyakarta',
    'Bali',
    'Jakarta',
    'Bandung',
  ];
  String _selectedDestination = 'Yogyakarta';

  final Map<String, List<HotelModel>> _hotelCache = {};
  bool _hotelsLoading = false;

  late final DateTime _defaultCheckIn;
  late final DateTime _defaultCheckOut;

  @override
  void initState() {
    super.initState();
    _defaultCheckIn = DateTime.now();
    _defaultCheckOut = DateTime.now().add(const Duration(days: 1));
    _loadNotificationState();
    _loadHotels(_selectedDestination);
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshToken != widget.refreshToken) {
      _hotelCache.remove(_selectedDestination);
      _loadHotels(_selectedDestination);
    }
  }

  Future<void> _loadHotels(String destination) async {
    if (_hotelCache.containsKey(destination)) return;
    if (!mounted) return;

    setState(() => _hotelsLoading = true);

    try {
      final all = await HotelService().searchHotels(
        destination: destination,
        rooms: 1,
        guests: 1,
      );

      final top3 = _popularHotelsForDestination(destination, all);

      if (!mounted) return;
      setState(() {
        _hotelCache[destination] = top3;
        _hotelsLoading = false;
      });
    } catch (e) {
      debugPrint('_loadHotels error [$destination]: $e');
      if (!mounted) return;
      setState(() {
        _hotelCache[destination] = []; 
        _hotelsLoading = false;
      });
    }
  }

  void _selectDestination(String destination) {
    if (_selectedDestination == destination) return;
    setState(() => _selectedDestination = destination);
    _loadHotels(destination);
  }

  List<HotelModel> get _currentHotels =>
      _hotelCache[_selectedDestination] ?? [];

  List<HotelModel> _popularHotelsForDestination(
    String destination,
    List<HotelModel> hotels,
  ) {
    final candidates = List<HotelModel>.from(hotels);
    final hasRatedHotel = candidates.any(
      (hotel) => hotel.rawRating > 0 || hotel.reviewCount > 0,
    );

    if (!hasRatedHotel) {
      candidates.shuffle(math.Random(destination.hashCode));
      return candidates.take(3).toList();
    }

    candidates.sort((a, b) {
      final ratingComparison = b.rawRating.compareTo(a.rawRating);
      if (ratingComparison != 0) return ratingComparison;

      final reviewComparison = b.reviewCount.compareTo(a.reviewCount);
      if (reviewComparison != 0) return reviewComparison;

      return a.name.compareTo(b.name);
    });

    return candidates.take(3).toList();
  }

  Future<void> _loadNotificationState() async {
    if (widget.isGuest) return;
    final session = await AuthService.currentSession();
    if (session == null || !mounted) return;
    await _generateReviewNotifsFromHistory(session);
    final unreadCount = await NotificationService.getUnreadCount(session);
    if (!mounted) return;
    setState(() {
      _session = session;
      _unreadCount = unreadCount;
    });
  }

  Future<void> _generateReviewNotifsFromHistory(AuthSession session) async {
    try {
      final bookings = await BookingService().fetchMyBookings();
      for (final booking in bookings) {
        if (!booking.isPaid) continue;
        if (DateTime.now().isBefore(booking.checkOutDate)) continue;
        if (booking.hasReview) continue;
        await NotificationService.maybeGenerateReviewNotification(
          session,
          pemesananId: booking.id.toString(),
          hotelNama: booking.hotelName,
          kodeBooking: booking.bookingCode,
          tglCheckout: booking.checkOutDate,
        );
      }
    } catch (e) {
      debugPrint('Generate review notif error: $e');
    }
  }

  String extractNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Guest';
    final username = email.split('@').first;
    final cleaned = username.replaceAll(RegExp(r'[0-9._-]+'), ' ').trim();
    if (cleaned.isEmpty) return 'Guest';
    return cleaned
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _openNotifications() async {
    final reminderEnabled =
        context.read<ReminderProvider>().notificationEnabled;
    if (_session == null || !reminderEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are turned off. Enable them to view live updates.',
          ),
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationPage(session: _session!)),
    );
    await _loadNotificationState();
  }

  void _goToHotelList(String destination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelListPage(
          destination: destination,
          checkInDate: _defaultCheckIn,
          checkOutDate: _defaultCheckOut,
          roomCount: 1,
          guestCount: 1,
        ),
      ),
    );
  }

  void _goToHotelDetail(HotelModel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelDetailPage(
          hotelId: hotel.id,
          checkInDate: _defaultCheckIn,
          checkOutDate: _defaultCheckOut,
          roomCount: 1,
          guestCount: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderEnabled =
        context.watch<ReminderProvider>().notificationEnabled;
    final String displayName = widget.isGuest
        ? 'User'
        : (widget.userName != null && widget.userName!.trim().isNotEmpty
            ? widget.userName!.trim()
            : extractNameFromEmail(widget.userEmail));

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 360;
    final double horizontalPadding = isCompact ? 16 : 20;
    final double topSectionHeight = isCompact ? 530 : 565;
    final double heroHeight = isCompact ? 200 : 215;
    final double searchTop = isCompact ? 152 : 165;

    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(height: topSectionHeight, width: double.infinity),
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: heroHeight,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryStart, AppColors.primaryEnd],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: HomeHeader(
                      userName: displayName,
                      notificationsEnabled: !widget.isGuest && reminderEnabled,
                      unreadCount: widget.isGuest ? 0 : _unreadCount,
                      onNotificationTap: _openNotifications,
                    ),
                  ),
                ),
                Positioned(
                  left: isCompact ? 12 : 16,
                  right: isCompact ? 12 : 16,
                  top: searchTop,
                  child: const SearchSection(),
                ),
              ],
            ),

            const SizedBox(height: 1),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Destinations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 42,
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding - 2),
                scrollDirection: Axis.horizontal,
                children: _destinations
                    .map((dest) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _DestinationChip(
                            label: dest,
                            isSelected: _selectedDestination == dest,
                            onTap: () => _selectDestination(dest),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            _buildHotelSection(
              horizontalPadding: horizontalPadding,
              isCompact: isCompact,
            ),

            const SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Special for You!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF344A99),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: const PromoBannerSection(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelSection({
    required double horizontalPadding,
    required bool isCompact,
  }) {
    if (_hotelsLoading && _currentHotels.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryEnd,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (!_hotelsLoading && _currentHotels.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: 24),
        child: const Center(
          child: Text(
            'No hotels found for this destination.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final double cardWidth = isCompact ? 220 : 240;
    final double cardImageHeight = isCompact ? 120 : 130;

    return SizedBox(
      height: isCompact ? 230 : 248,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
        ),
        itemCount: _currentHotels.length + 1,
        itemBuilder: (context, index) {
          if (index == _currentHotels.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _SeeAllCard(
                destination: _selectedDestination,
                onTap: () => _goToHotelList(_selectedDestination),
                width: isCompact ? 80 : 90,
                height: isCompact ? 230 : 248,
              ),
            );
          }

          final hotel = _currentHotels[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < _currentHotels.length - 1 ? 12 : 0,
            ),
            child: _HotelCard(
              hotel: hotel,
              width: cardWidth,
              imageHeight: cardImageHeight,
              onTap: () => _goToHotelDetail(hotel),
            ),
          );
        },
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  const _DestinationChip({
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEnd : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.blueSoft),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryEnd.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({
    required this.hotel,
    required this.width,
    required this.imageHeight,
    this.onTap,
  });

  final HotelModel hotel;
  final double width;
  final double imageHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: _buildImage(width, imageHeight),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 2),

                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hotel.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFF6B545)),
                      const SizedBox(width: 2),
                      Text(
                        hotel.rawRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${hotel.review})',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  Text(
                    hotel.facilities,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
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

  Widget _buildImage(double width, double height) {
    final String? firstImage =
        (hotel.images.isNotEmpty) ? hotel.images.first : null;

    if (firstImage == null) return _placeholder(width, height);

    final isNetwork = firstImage.startsWith('http');
    if (isNetwork) {
      return Image.network(
        firstImage,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(width, height),
      );
    }
    return Image.asset(
      firstImage,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(width, height),
    );
  }

  Widget _placeholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8EEF7),
      child: const Center(
        child: Icon(Icons.hotel_rounded, size: 36, color: Color(0xFFB0C0DC)),
      ),
    );
  }
}

class _SeeAllCard extends StatelessWidget {
  const _SeeAllCard({
    required this.destination,
    required this.onTap,
    required this.width,
    required this.height,
  });

  final String destination;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.blueSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryEnd.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryEnd,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'See\nAll',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryEnd,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
