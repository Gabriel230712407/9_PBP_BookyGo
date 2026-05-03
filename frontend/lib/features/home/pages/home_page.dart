import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/search_section.dart';
import '../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final bool isGuest;
  final String? userEmail;

  const HomePage({
    super.key,
    this.isGuest = true,
    this.userEmail,
  });

  String extractNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Guest';

    final username = email.split('@').first;
    final cleaned = username.replaceAll(RegExp(r'[0-9._-]+'), ' ').trim();

    if (cleaned.isEmpty) return 'Guest';

    return cleaned
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final String userName =
        isGuest ? 'User' : extractNameFromEmail(userEmail);

    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(
                  height: 585,
                  width: double.infinity,
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 215,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryStart,
                          AppColors.primaryEnd,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: HomeHeader(userName: userName),
                  ),
                ),

                const Positioned(
                  left: 16,
                  right: 16,
                  top: 165,
                  child: SearchSection(),
                ),
              ],
            ),

            const SizedBox(height: 1),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
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

            const SizedBox(height: 16),

            SizedBox(
              height: 42,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                children: const [
                  _DestinationChip(
                    label: 'Yogyakarta',
                    isSelected: true,
                  ),
                  SizedBox(width: 10),
                  _DestinationChip(label: 'Bali'),
                  SizedBox(width: 10),
                  _DestinationChip(label: 'Jakarta'),
                  SizedBox(width: 10),
                  _DestinationChip(label: 'Surabaya'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/onboarding_bag.png',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Badge(text: 'Best Seller'),
                            SizedBox(width: 8),
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFF6B545),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Malioboro\nBoutique Stay',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Yogyakarta • 2 nights •\nBreakfast included',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'start from',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9AA3C7),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rp 1.800.000',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryEnd,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blueSoft),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.primaryEnd,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _DestinationChip({
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryEnd : AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.blueSoft),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.darkBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgVeryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryEnd,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}