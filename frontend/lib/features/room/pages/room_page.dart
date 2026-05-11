import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../widget/room_widget.dart';

class RoomPage extends StatelessWidget {
  RoomPage({super.key});

  final List<RoomModel> rooms = [
    RoomModel(
      name: 'Malioboro Classic Room',
      type: 'Classic',
      image: null,
      facility: 'AC | Smart TV | Shower | Coffee / Tea Maker',
      price: 'IDR 4.480.000',
    ),
    RoomModel(
      name: 'Malioboro Deluxe Room',
      type: 'Deluxe',
      image: null,
      facility: 'AC | Smart TV | Shower | Coffee / Tea Maker',
      price: 'IDR 5.500.000',
    ),
    RoomModel(
      name: 'Malioboro Deluxe Room',
      type: 'Deluxe',
      image: null,
      facility: 'AC | Smart TV | Shower | Coffee / Tea Maker',
      price: 'IDR 5.500.000',
    ),
    RoomModel(
      name: 'Malioboro Deluxe Room',
      type: 'Deluxe',
      image: null,
      facility: 'AC | Smart TV | Shower | Coffee / Tea Maker',
      price: 'IDR 5.500.000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FF),

      body: Column(
        children: [
          _RoomHeader(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                ...rooms.map((room) => RoomCardWidget(room: room)),

                const SizedBox(height: 8),

                const _OtherAccommodationSection(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 26, 14, 8),
      color: const Color(0xff6688F0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(width: 12),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Malioboro Boutique Stay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '16 March - 18 March  • 1 room',
                style: TextStyle(color: Colors.white, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherAccommodationSection extends StatelessWidget {
  const _OtherAccommodationSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Check out other accommodations',
            style: TextStyle(
              color: Color(0xff26346B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _SmallHotelCard(
                  image: '',
                  name: 'Borobudur Heritage Inn',
                  location: 'Magelang, Jawa tengah',
                  rating: '4.9/5 (2,1k)',
                  price: 'IDR 1.140.000',
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _SmallHotelCard(
                  image: '',
                  name: 'Java Royal Retreat',
                  location: 'Kaliurang, Yogyakarta',
                  rating: '4.5/5 (2,1k)',
                  price: 'IDR 1.840.000',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallHotelCard extends StatelessWidget {
  final String image;
  final String name;
  final String location;
  final String rating;
  final String price;

  const _SmallHotelCard({
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: image.isNotEmpty
                ? Image.asset(
                    image,
                    height: 82,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 82,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff26346B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: const [
                    Icon(Icons.star, size: 10, color: Colors.amber),
                    Icon(Icons.star, size: 10, color: Colors.amber),
                    Icon(Icons.star, size: 10, color: Colors.amber),
                    Icon(Icons.star, size: 10, color: Colors.amber),
                    Icon(Icons.star_half, size: 10, color: Colors.amber),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),

                Text(
                  rating,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),

                const SizedBox(height: 36),

                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  'Excluding taxes',
                  style: TextStyle(color: Colors.grey, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xff5E7CEB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.article, color: Colors.white),
          Icon(Icons.favorite, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
      ),
    );
  }
}
