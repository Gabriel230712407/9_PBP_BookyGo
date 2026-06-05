import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class PromoBannerSection extends StatelessWidget {
  const PromoBannerSection({super.key});

  // ✅ Hardcode di sini — ganti isi list kalau mau tambah/ubah promo
  static const List<_PromoData> _promos = [
    _PromoData(
      tag: 'Special Offer',
      title: 'Weekend Escape\nUp to 20% Off',
      subtitle: 'Enjoy a staycation at your favorite hotel of choice.',
      buttonLabel: 'Book Now',
    ),
    _PromoData(
      tag: 'Limited Time',
      title: 'Early Bird Deal\nSave 15% Today',
      subtitle: 'Book 7 days in advance and enjoy exclusive savings.',
      buttonLabel: 'Grab Deal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.92),
        itemCount: _promos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: 8,
            ),
            child: _BannerCard(data: _promos[index]),
          );
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});
  final _PromoData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B7BF0), Color(0xFF7B9CF8)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles (background accent)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 100, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.tag,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // TODO: navigasi ke hotel list / promo page
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      data.buttonLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5B7BF0),
                      ),
                    ),
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

class _PromoData {
  final String tag;
  final String title;
  final String subtitle;
  final String buttonLabel;

  const _PromoData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });
}