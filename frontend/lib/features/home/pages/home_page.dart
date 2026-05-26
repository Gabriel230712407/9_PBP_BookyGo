import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/search_section.dart';
import '../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final bool isGuest;
  final String? userEmail;
  final String? userName;

  const HomePage({
    super.key,
    this.isGuest = true,
    this.userEmail,
    this.userName,
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
    final String displayName = isGuest
        ? 'User'
        : (userName != null && userName!.trim().isNotEmpty
            ? userName!.trim()
            : extractNameFromEmail(userEmail));
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 360;
    final double horizontalPadding = isCompact ? 16 : 20;
    final double topSectionHeight = isCompact ? 530 : 565;
    final double heroHeight = isCompact ? 200 : 215;
    final double searchTop = isCompact ? 152 : 165;
    final double cardImageSize = isCompact ? 72 : 80;

    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: topSectionHeight,
                  width: double.infinity,
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: heroHeight,
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
                      child: HomeHeader(userName: displayName),
                    ),
                  ),

                Positioned(
                  left: isCompact ? 12 : 16,
                  right: isCompact ? 12 : 16,
                  top: searchTop,
                  child: const SearchSection(),
                ),
              ],
            ),

            const SizedBox(height: 1),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const Align(
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

            const SizedBox(height: 8),

            SizedBox(
              height: 42,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding - 2),
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

            const SizedBox(height: 12),

            Container(
              margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              padding: EdgeInsets.all(isCompact ? 10 : 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/onboarding_bag.png',
                      width: cardImageSize,
                      height: cardImageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: isCompact ? 8 : 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Badge(text: 'Best Seller'),
                            SizedBox(width: 6),
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFF6B545),
                            ),
                            SizedBox(width: 2),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Malioboro Boutique Stay',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Yogyakarta • 2 nights • Breakfast included',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'start from',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Rp 1.800.000',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryEnd,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isCompact ? 6 : 8),
                  Container(
                    width: isCompact ? 30 : 34,
                    height: isCompact ? 30 : 34,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.blueSoft),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: AppColors.primaryEnd,
                      size: isCompact ? 18 : 20,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: const Align(
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
