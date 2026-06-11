import 'package:flutter/material.dart';

import '../../../core/widgets/app_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../navigation/utils/main_nav_launcher.dart';
import '../../navigation/widgets/app_bottom_nav_bar.dart';
import '../models/hotel_model.dart';
import '../services/hotel_service.dart';
import '../../whistlist/services/whistlist_service.dart';
import 'hotel_detail.dart';
import '../../../core/auth/services/auth_storage.dart';

class HotelListPage extends StatefulWidget {
  final String destination;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomCount;
  final int guestCount;

  const HotelListPage({
    super.key,
    required this.destination,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomCount,
    required this.guestCount,
  });

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  late Future<List<HotelModel>> _futureHotels;
  late final TextEditingController _searchController;
  String _hotelNameQuery = '';

  // ── Wishlist state ──────────────────────────────────────
  Set<int> _wishlistedIds = {};
  String _token = '';
  // ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _futureHotels = HotelService().searchHotels(
      destination: widget.destination,
      rooms: widget.roomCount,
      guests: widget.guestCount,
    );
    _loadToken(); // load token lalu fetch wishlist
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Token & wishlist loader ──────────────────────────────

  Future<void> _loadToken() async {
    final session = await AuthStorage.getSession();
    if (session != null) {
      _token = session.token;
    }
    await _loadWishlists();
  }

  Future<void> _loadWishlists() async {
    if (_token.isEmpty) return;
    try {
      final ids = await WishlistService().getWishlistedHotelIds(_token);
      if (mounted) setState(() => _wishlistedIds = ids);
    } catch (_) {
      // Gagal load wishlist tidak perlu crash
    }
  }

  Future<void> _toggleWishlist(int hotelId) async {
    // Optimistic update — UI langsung berubah dulu
    setState(() {
      if (_wishlistedIds.contains(hotelId)) {
        _wishlistedIds.remove(hotelId);
      } else {
        _wishlistedIds.add(hotelId);
      }
    });

    try {
      final isAdded = await WishlistService().toggleWishlist(_token, hotelId);
      // Sinkronisasi hasil dari server
      if (mounted) {
        setState(() {
          if (isAdded) {
            _wishlistedIds.add(hotelId);
          } else {
            _wishlistedIds.remove(hotelId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAdded ? '❤️ Ditambahkan ke wishlist' : 'Dihapus dari wishlist',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      // Revert kalau gagal
      if (mounted) {
        setState(() {
          if (_wishlistedIds.contains(hotelId)) {
            _wishlistedIds.remove(hotelId);
          } else {
            _wishlistedIds.add(hotelId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal update wishlist, coba lagi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Helpers ─────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  // ── Hotel card ──────────────────────────────────────────

  Widget _buildHotelCard(HotelModel hotel) {
    final bool isWishlisted = _wishlistedIds.contains(hotel.id);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailPage(
              hotelId: hotel.id,
              checkInDate: widget.checkInDate,
              checkOutDate: widget.checkOutDate,
              roomCount: widget.roomCount,
              guestCount: widget.guestCount,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HotelImageCarousel(images: hotel.images),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff26346B),
                          ),
                        ),
                      ),
                      // ── Heart / Wishlist button ──────────────
                      GestureDetector(
                        onTap: () => _toggleWishlist(hotel.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isWishlisted
                                  ? Colors.red.shade200
                                  : const Color(0xffDCE4FF),
                            ),
                            color: isWishlisted
                                ? Colors.red.shade50
                                : Colors.transparent,
                          ),
                          child: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted
                                ? Colors.red
                                : const Color(0xff5E7CEB),
                            size: 20,
                          ),
                        ),
                      ),
                      // ─────────────────────────────────────────
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          hotel.location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const Icon(
                        Icons.star_half,
                        size: 14,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${hotel.rating} (${hotel.review})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 7),
                  Text(
                    hotel.facilities,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff26346B),
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

  // ── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FF),
      body: Column(
        children: [
          // Header biru
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            color: AppColors.primaryEnd,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.destination.isEmpty
                                ? 'All Hotels'
                                : widget.destination,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_formatDate(widget.checkInDate)} - ${_formatDate(widget.checkOutDate)}'
                            '  |  ${widget.roomCount} room  |  ${widget.guestCount} guests',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Search bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xff9E9E9E),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _hotelNameQuery = value.trim().toLowerCase();
                            });
                          },
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xff26346B),
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          cursorColor: const Color(0xff5E7CEB),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            hintText: 'Search hotel name',
                            hintStyle: TextStyle(
                              color: Color(0xffB0A9A3),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _searchController.clear();
                            setState(() => _hotelNameQuery = '');
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Color(0xff9E9E9E),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),

          // Hotel list
          Expanded(
            child: FutureBuilder<List<HotelModel>>(
              future: _futureHotels,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final hotels = snapshot.data ?? [];
                final filteredHotels = hotels.where((hotel) {
                  if (_hotelNameQuery.isEmpty) return true;
                  return hotel.name.toLowerCase().contains(_hotelNameQuery);
                }).toList();

                if (filteredHotels.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hotels found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: filteredHotels.length,
                  itemBuilder: (context, index) {
                    return _buildHotelCard(filteredHotels[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        onTap: (index) => openMainNavTab(context, index),
      ),
    );
  }
}

// ── Image Carousel ───────────────────────────────────────────

class _HotelImageCarousel extends StatefulWidget {
  final List<String> images;

  const _HotelImageCarousel({required this.images});

  @override
  State<_HotelImageCarousel> createState() => _HotelImageCarouselState();
}

class _HotelImageCarouselState extends State<_HotelImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 165,
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          color: Color(0xffD7DCEB),
        ),
        child: const Icon(Icons.hotel, size: 50, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      child: Stack(
        children: [
          SizedBox(
            height: 165,
            child: PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return AppImage(
                  imagePath: widget.images[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xffD7DCEB),
                      child: const Icon(
                        Icons.hotel,
                        size: 50,
                        color: Colors.white,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
