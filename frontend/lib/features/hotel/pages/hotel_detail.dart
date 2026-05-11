import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../../room/pages/room_page.dart';

class HotelDetailPage extends StatelessWidget {
  final HotelModel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FF),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 95),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderImage(hotel: hotel),
                  _HotelTitle(hotel: hotel),
                  _ReviewSection(),
                  _FacilitySection(),
                  _LocationSection(),
                  _PolicySection(),
                ],
              ),
            ),
          ),

          _BottomBookingBar(),
        ],
      ),

      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final HotelModel hotel;

  const _HeaderImage({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            //Image.asset(
            //  hotel.image,
            //  height: 230,
            //  width: double.infinity,
            //  fit: BoxFit.cover,
            //),
            Container(
              height: 230,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50, color: Colors.white),
            ),
            Row(
              // children: [
              //   Expanded(child: _SmallImage(image: hotel.image)),
              //   Expanded(child: _SmallImage(image: hotel.image)),
              //   Expanded(child: _SmallImage(image: hotel.image)),
              // ],
              children: const [
                Expanded(child: _SmallImage(image: '')),
                Expanded(child: _SmallImage(image: '')),
                Expanded(child: _SmallImage(image: '')),
              ],
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
}

class _SmallImage extends StatelessWidget {
  final String image;

  const _SmallImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(right: 2, top: 2),
      //child: Image.asset(image, fit: BoxFit.cover),
    );
  }
}

class _HotelTitle extends StatelessWidget {
  final HotelModel hotel;

  const _HotelTitle({required this.hotel});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                '4,4/5',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff5E7CEB),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '(4 review)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Text('•', style: TextStyle(color: Colors.grey)),
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
  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Review',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff26346B),
                ),
              ),
              Spacer(),
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff26346B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            '4,4/5',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xff5E7CEB),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

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
                  // child: Image.asset(
                  //   'assets/images/hotel1.jpg',
                  //   width: 90,
                  //   height: 98,
                  //   fit: BoxFit.cover,
                  // ),
                  child: Container(
                    width: 90,
                    height: 98,
                    color: Colors.grey[300],
                    child: const Icon(
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
                    children: const [
                      Text(
                        '5,0 /5',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff26346B),
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'AB',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'I stayed here for two nights during my trip to Yogyakarta.',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 4.3,
        children: const [
          _FacilityItem(icon: Icons.wifi, text: 'WiFi'),
          _FacilityItem(icon: Icons.ac_unit, text: 'AC'),
          _FacilityItem(icon: Icons.restaurant, text: 'Restaurant'),
          _FacilityItem(icon: Icons.airport_shuttle, text: 'Airport Shuttle'),
          _FacilityItem(icon: Icons.room_service, text: '24h Reception'),
          _FacilityItem(icon: Icons.balcony, text: 'Balcony'),
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
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
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
            // child: Image.asset(
            //   'assets/images/map.jpg',
            //   height: 120,
            //   width: double.infinity,
            //   fit: BoxFit.cover,
            // ),
            child: Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Icon(Icons.map, size: 50, color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Jl. Babarsari No.43, Janti, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SectionBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Accommodation Policies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),

          SizedBox(height: 18),

          Row(
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

          SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _PolicyText(
                  title: 'Check-in',
                  date: '16 Mar 2026',
                  time: 'From 13:00',
                ),
              ),
              Expanded(
                child: _PolicyText(
                  title: 'Check-out',
                  date: '18 Mar 2026',
                  time: 'before 12:00',
                ),
              ),
            ],
          ),

          SizedBox(height: 28),

          Text(
            'Children',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff26346B),
            ),
          ),

          SizedBox(height: 10),

          Text(
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

  const _SectionBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      color: Colors.white,
      child: child,
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Starts from',
                  style: TextStyle(color: Color(0xff5E7CEB), fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp 1.234.567',
                  style: TextStyle(
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RoomPage()),
                );
              },
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
