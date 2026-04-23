import 'package:flutter/material.dart';
import 'mybook_hotel_card.dart';

class MyBookRecommendationSection extends StatelessWidget {
  const MyBookRecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F2A44);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
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
          const Text(
            'Your dream vacation waiting you',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 14),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CityChip(label: 'Jakarta', isSelected: true),
                SizedBox(width: 8),
                _CityChip(label: 'Yogyakarta'),
                SizedBox(width: 8),
                _CityChip(label: 'Bali'),
                SizedBox(width: 8),
                _CityChip(label: 'Bandung'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 265,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                MyBookHotelCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1200&auto=format&fit=crop',
                  title: 'Skyline Central\nHotel',
                  location: 'Sudirman, Central Jakarta',
                  ratingText: '4,5/5 (4 reviews)',
                ),
                SizedBox(width: 12),
                MyBookHotelCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?q=80&w=1200&auto=format&fit=crop',
                  title: 'Metra Grand Hotel',
                  location: 'Kuningan, South Jakarta',
                  ratingText: '4,6/5 (4 reviews)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CityChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5B74E8);
    const borderColor = Color(0xFF8A96B8);

    return Container(
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
    );
  }
}
