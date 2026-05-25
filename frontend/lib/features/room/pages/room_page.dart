import 'package:flutter/material.dart';

import '../../hotel/models/hotel_model.dart';
import '../../navigation/widgets/app_bottom_nav_bar.dart';
import '../models/room_model.dart';

class RoomPage extends StatelessWidget {
  final HotelModel hotel;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int roomCount;
  final int guestCount;

  const RoomPage({
    super.key,
    required this.hotel,
    required this.checkInDate,
    required this.checkOutDate,
    required this.roomCount,
    required this.guestCount,
  });

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

  @override
  Widget build(BuildContext context) {
    final rooms = hotel.rooms.where((room) => room.capacity >= guestCount).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FF),
      body: Column(
        children: [
          _RoomHeader(
            hotelName: hotel.name,
            subtitle:
                '${_formatDate(checkInDate)} - ${_formatDate(checkOutDate)}  |  $roomCount room  |  $guestCount guests',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                ...rooms.map((room) => _RoomCard(room: room)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  final String hotelName;
  final String subtitle;

  const _RoomHeader({
    required this.hotelName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 30, 14, 8),
      color: const Color(0xff6688F0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 28),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoomImageCarousel(images: room.images),
            const SizedBox(height: 12),
            Text(
              room.name,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xff26346B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.bed, size: 18, color: Color(0xff26346B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    room.bedType,
                    style: const TextStyle(
                      color: Color(0xff26346B),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  room.smokingPolicy == 'smoking' ? Icons.smoking_rooms : Icons.smoke_free,
                  size: 18,
                  color: const Color(0xff26346B),
                ),
                const SizedBox(width: 6),
                Text(
                  room.smokingLabel,
                  style: const TextStyle(color: Color(0xff26346B), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              room.facility,
              style: const TextStyle(color: Color(0xff26346B), fontSize: 14),
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('${room.capacity} adults', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.comment, size: 18, color: Color(0xff5E7CEB)),
                const SizedBox(width: 4),
                Text(
                  'See Reviews(${room.reviewCount})',
                  style: const TextStyle(
                    color: Color(0xff5E7CEB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: room.price,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' / Night',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5E7CEB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

class _RoomImageCarousel extends StatefulWidget {
  final List<String> images;

  const _RoomImageCarousel({required this.images});

  @override
  State<_RoomImageCarousel> createState() => _RoomImageCarouselState();
}

class _RoomImageCarouselState extends State<_RoomImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 165,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffD7DCEB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.home, size: 50, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
                return Image.asset(
                  widget.images[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xffD7DCEB),
                      child: const Icon(Icons.home, size: 50, color: Colors.white),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

