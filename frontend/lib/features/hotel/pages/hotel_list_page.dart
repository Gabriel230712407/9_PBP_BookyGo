import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../widgets/hotel_widget.dart';
import 'hotel_detail.dart';

class HotelListPage extends StatefulWidget {
  const HotelListPage({super.key});

  @override
  State<HotelListPage> createState() => _HotelListPageState();
}

class _HotelListPageState extends State<HotelListPage> {
  final List<HotelModel> hotels = [
    HotelModel(
      name: 'Malioboro Boutique Stay',
      location: 'Malioboro, Yogyakarta',
      rating: '5.0/5',
      review: '100',
      //image: 'assets/images/hotel1.jpg',
      facilities: 'Free Breakfast, Free Parking, Free WiFi',
      description:
          'Hotel nyaman dekat Malioboro dengan desain klasik dan fasilitas lengkap.',
    ),
    HotelModel(
      name: 'Borobudur Heritage Inn',
      location: 'Magelang, Jawa Tengah',
      rating: '4.9/5',
      review: '2,1k',
      //image: 'assets/images/hotel2.jpg',
      facilities: 'Free Breakfast, Free Parking, Free WiFi',
      description:
          'Penginapan elegan dengan nuansa heritage dan pemandangan indah.',
    ),
    HotelModel(
      name: 'Java Royal Retreat',
      location: 'Sleman, Yogyakarta',
      rating: '4.9/5',
      review: '2,1k',
      //image: 'assets/images/hotel3.jpg',
      facilities: 'Free Breakfast, Free Parking, Free WiFi',
      description:
          'Tempat menginap eksklusif dengan suasana tenang dan interior mewah.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FF),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 42, 16, 14),
            color: const Color(0xff6688F0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_back, color: Colors.white),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Yogyakarta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '16 March - 18 March  •  1 room • 1 guests',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Search hotel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];

                return HotelCard(
                  hotel: hotel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetailPage(hotel: hotel),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        height: 62,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        decoration: BoxDecoration(
          color: const Color(0xff5E7CEB),
          borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
