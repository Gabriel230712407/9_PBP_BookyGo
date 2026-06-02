import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../navigation/widgets/app_bottom_nav_bar.dart';
import '../../room/pages/room_page.dart';
import '../models/hotel_model.dart';
import '../services/hotel_service.dart';

import '../../reviews/pages/review_list.dart';
import '../../reviews/models/review_model.dart';
import '../../reviews/services/review_service.dart';

class HotelDetailPage extends StatefulWidget {
  final int hotelId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomCount;
  final int guestCount;

  const HotelDetailPage({
    super.key,
    required this.hotelId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomCount,
    required this.guestCount,
  });

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  late Future<HotelModel> _futureHotel;

  @override
  void initState() {
    super.initState();
    _futureHotel = HotelService().fetchHotelDetail(widget.hotelId);
  }

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatPrice(double value) {
    final number = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int counter = 0;

    for (int i = number.length - 1; i >= 0; i--) {
      buffer.write(number[i]);
      counter++;
      if (counter % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FF),
      body: FutureBuilder<HotelModel>(
        future: _futureHotel,
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

          final hotel = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 95),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderGallery(hotel: hotel),
                      FutureBuilder<ReviewResponse>(
                        future: ReviewService().getReviews(hotelId: hotel.id),
                        builder: (context, reviewSnapshot) {
                          final reviewResponse = reviewSnapshot.data;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HotelTitle(
                                hotel: hotel,
                                reviewSummary: reviewResponse?.summary,
                              ),
                              _ReviewSection(
                                hotel: hotel,
                                reviewResponse: reviewResponse,
                              ),
                            ],
                          );
                        },
                      ),
                      _FacilitySection(hotel: hotel),
                      _LocationSection(hotel: hotel),
                      _PolicySection(
                        checkInDate: widget.checkInDate,
                        checkOutDate: widget.checkOutDate,
                        formatDate: _formatDate,
                      ),
                    ],
                  ),
                ),
              ),
              _BottomBookingBar(
                priceText: _formatPrice(hotel.lowestPrice),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoomPage(
                        hotel: hotel,
                        checkInDate: widget.checkInDate,
                        checkOutDate: widget.checkOutDate,
                        roomCount: widget.roomCount,
                        guestCount: widget.guestCount,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _HeaderGallery extends StatelessWidget {
  final HotelModel hotel;

  const _HeaderGallery({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final images = hotel.images;

    return Stack(
      children: [
        Column(
          children: [
            _HeaderGridImage(
              image: images.isNotEmpty ? images[0] : null,
              height: 230,
              borderRadius: BorderRadius.zero,
              onTap: images.isNotEmpty
                  ? () => _openInfiniteGallery(context, images, 0)
                  : null,
            ),
            Row(
              children: List.generate(3, (index) {
                final imageIndex = index + 1;
                final image = imageIndex < images.length
                    ? images[imageIndex]
                    : null;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2, right: index == 2 ? 0 : 2),
                    child: _HeaderGridImage(
                      image: image,
                      height: 85,
                      borderRadius: BorderRadius.zero,
                      onTap: image != null
                          ? () => _openInfiniteGallery(
                              context,
                              images,
                              imageIndex,
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        Positioned(
          top: 38,
          left: 12,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Color(0xff26346B)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  void _openInfiniteGallery(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _InfiniteImageViewer(images: images, initialIndex: initialIndex),
      ),
    );
  }
}

class _HeaderGridImage extends StatelessWidget {
  final String? image;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const _HeaderGridImage({
    required this.image,
    required this.height,
    required this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        height: height,
        width: double.infinity,
        color: const Color(0xffD7DCEB),
        child: image != null && image!.isNotEmpty
            ? Image.asset(
                image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(Icons.image, size: 44, color: Colors.white);
                },
              )
            : const Icon(Icons.image, size: 44, color: Colors.white),
      ),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(onTap: onTap, child: child);
  }
}

class _InfiniteImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _InfiniteImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_InfiniteImageViewer> createState() => _InfiniteImageViewerState();
}

class _InfiniteImageViewerState extends State<_InfiniteImageViewer> {
  late final PageController _controller;
  late int _currentPage;

  static const int _loopMultiplier = 1000;

  @override
  void initState() {
    super.initState();
    final initialPage =
        widget.images.length * _loopMultiplier + widget.initialIndex;
    _currentPage = initialPage;
    _controller = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              final image = images[index % images.length];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 56,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 42,
            left: 14,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.18),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  '${(_currentPage % images.length) + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelTitle extends StatelessWidget {
  final HotelModel hotel;
  final ReviewSummary? reviewSummary;

  const _HotelTitle({
    required this.hotel,
    required this.reviewSummary,
  });

  @override
  Widget build(BuildContext context) {
    final averageRating = reviewSummary?.averageRating ?? 0.0;
    final totalReview = reviewSummary?.totalReview ?? 0;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hotel.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${averageRating.toStringAsFixed(1)}/5',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xff5E7CEB),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($totalReview review)',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Text('|', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.location_on, size: 13, color: Colors.grey),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  hotel.location,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final HotelModel hotel;
  final ReviewResponse? reviewResponse;

  const _ReviewSection({
    required this.hotel,
    required this.reviewResponse,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReviewResponse>(
      future: ReviewService().getReviews(hotelId: hotel.id),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        final summary = snapshot.data?.summary;
        final reviews = snapshot.data?.reviews ?? [];
        final firstReview = reviews.isNotEmpty ? reviews.first : null;

        final averageRating = summary?.averageRating ?? 0.0;
        final totalReview = summary?.totalReview ?? 0;

        return _SectionBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff26346B),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: totalReview == 0
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewListPage(
                                  hotelId: hotel.id,
                                  title: 'Reviews',
                                  hotelName: hotel.name,
                                  hotelLocation: hotel.location,
                                  hotelImage: hotel.images.isNotEmpty ? hotel.images.first : null,
                                ),
                              ),
                            );
                          },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        color: totalReview == 0
                            ? Colors.grey
                            : const Color(0xff26346B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                Text(
                  '($totalReview review)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                if (firstReview != null)
                  Container(
                    height: 118,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF3FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 90,
                            height: 98,
                            color: Colors.grey[300],
                            child: firstReview.photoUrls.isNotEmpty
                                ? Image.network(
                                    firstReview.photoUrls.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${firstReview.rating.toStringAsFixed(1)} /5',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff26346B),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                firstReview.userName ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                firstReview.komentar.isEmpty
                                    ? 'No comment'
                                    : firstReview.komentar,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    'No review yet',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FacilitySection extends StatelessWidget {
  final HotelModel hotel;

  const _FacilitySection({required this.hotel});

  IconData _mapIcon(String facility) {
    final value = facility.toLowerCase();

    if (value.contains('wifi')) return Icons.wifi;
    if (value.contains('restaurant')) return Icons.restaurant;
    if (value.contains('airport')) return Icons.airport_shuttle;
    if (value.contains('reception')) return Icons.room_service;
    if (value.contains('balcony')) return Icons.balcony;
    if (value.contains('parking')) return Icons.local_parking;
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Facilities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),
          const SizedBox(height: 2),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 5.9,
            children: hotel.facilityList
                .map(
                  (facility) =>
                      _FacilityItem(icon: _mapIcon(facility), text: facility),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FacilityItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FacilityItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final HotelModel hotel;

  const _LocationSection({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.map, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hotel.address,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String Function(DateTime) formatDate;

  const _PolicySection({
    required this.checkInDate,
    required this.checkOutDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accommodation Policies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black,
                child: Icon(Icons.access_time, color: Colors.white, size: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check-in & Check-out Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff26346B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PolicyText(
                  title: 'Check-in',
                  date: formatDate(checkInDate),
                  time: 'From 13:00',
                ),
              ),
              Expanded(
                child: _PolicyText(
                  title: 'Check-out',
                  date: formatDate(checkOutDate),
                  time: 'Before 12:00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Children',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Guests of all ages are welcome to stay here',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  final String title;
  final String date;
  final String time;

  const _PolicyText({
    required this.title,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(fontSize: 11, color: Color(0xff26346B)),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Color(0xff26346B)),
          ),
        ],
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionBox({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: padding,
      color: Colors.white,
      child: child,
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
  final String priceText;
  final VoidCallback onTap;

  const _BottomBookingBar({required this.priceText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffEEF0F6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Starts from',
                  style: TextStyle(color: Color(0xff5E7CEB), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    color: Color(0xff26346B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5E7CEB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onTap,
              child: const Text(
                'View rooms',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

