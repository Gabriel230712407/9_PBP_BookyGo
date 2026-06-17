import 'package:flutter/material.dart';
import '../../../features/hotel/services/hotel_service.dart';
import '../../../features/hotel/models/hotel_model.dart';
import '../../../features/hotel/pages/hotel_detail.dart';
import 'mybook_hotel_card.dart';

class MyBookRecommendationSection extends StatefulWidget {
  const MyBookRecommendationSection({
    super.key,
    required this.isGuest,
  });

  final bool isGuest;

  @override
  State<MyBookRecommendationSection> createState() =>
      _MyBookRecommendationSectionState();
}

class _MyBookRecommendationSectionState
    extends State<MyBookRecommendationSection> {
  final HotelService _hotelService = HotelService();

  static const _cities = ['Jakarta', 'Yogyakarta', 'Bali', 'Bandung'];
  String _selectedCity = 'Jakarta';
  late Future<List<HotelModel>> _futureHotels;
  late final DateTime _defaultCheckIn;
  late final DateTime _defaultCheckOut;

  @override
  void initState() {
    super.initState();
    _defaultCheckIn = DateTime.now();
    _defaultCheckOut = DateTime.now().add(const Duration(days: 1));
    _futureHotels = _fetchForCity(_selectedCity);
  }

  Future<List<HotelModel>> _fetchForCity(String city) {
    return _hotelService.searchHotels(destination: city, rooms: 1, guests: 1);
  }

  void _selectCity(String city) {
    if (city == _selectedCity) return;
    setState(() {
      _selectedCity = city;
      _futureHotels = _fetchForCity(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F2A44);
    final double width = MediaQuery.of(context).size.width;
    final bool isCompact = width < 360;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 4),
      padding: EdgeInsets.fromLTRB(
        isCompact ? 14 : 16,
        isCompact ? 16 : 18,
        isCompact ? 14 : 16,
        isCompact ? 18 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your dream vacation waiting you',
            style: TextStyle(
              fontSize: isCompact ? 16 : 17,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),
          SizedBox(height: isCompact ? 12 : 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _cities.map((city) {
                final isFirst = city == _cities.first;
                return Padding(
                  padding: EdgeInsets.only(left: isFirst ? 0 : 8),
                  child: _CityChip(
                    label: city,
                    isSelected: city == _selectedCity,
                    onTap: () => _selectCity(city),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: isCompact ? 14 : 18),
          FutureBuilder<List<HotelModel>>(
            future: _futureHotels,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: isCompact ? 248 : 265,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: isCompact ? 248 : 265,
                  child: Center(
                    child: Text(
                      'Failed to load hotels',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ),
                );
              }

              final hotels = snapshot.data ?? [];

              if (hotels.isEmpty) {
                return SizedBox(
                  height: isCompact ? 248 : 265,
                  child: Center(
                    child: Text(
                      'No hotels found in $_selectedCity',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int index = 0; index < hotels.length; index++) ...[
                        if (index > 0) const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelDetailPage(
                                hotelId: hotels[index].id,
                                checkInDate: _defaultCheckIn,
                                checkOutDate: _defaultCheckOut,
                                roomCount: 1,
                                guestCount: 1,
                                isGuest: widget.isGuest,
                              ),
                            ),
                          ),
                          child: MyBookHotelCard(
                            imageUrl: hotels[index].image ?? '',
                            title: hotels[index].name,
                            location: hotels[index].address,
                            ratingText:
                                '${hotels[index].rating} (${hotels[index].review})',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5B74E8);
    const borderColor = Color(0xFF8A96B8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: 1.4,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? primaryColor : const Color(0xFF4D597A),
          ),
        ),
      ),
    );
  }
}
