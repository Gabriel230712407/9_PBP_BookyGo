import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Your Stay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              border: Border.all(color:  AppColors.blueSoft),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 28,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destination',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Bandung, Indonesia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: const [
              Expanded(
                child: _InfoBox(
                  icon: Icons.calendar_month_outlined,
                  title: 'Check-in',
                  value: '16 Mar 2026',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoBox(
                  icon: Icons.calendar_month_outlined,
                  title: 'Check-out',
                  value: '17 Mar 2026',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: const [
              Expanded(
                child: _InfoBox(
                  icon: Icons.bed_outlined,
                  title: 'Room(s)',
                  value: '1 Room',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoBox(
                  icon: Icons.person_outline_rounded,
                  title: 'Guest(s)',
                  value: '2 Guests',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primaryEnd, // #3F7BEA
                    AppColors.blueDark,   // #3466C9
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Search Hotel',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
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

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blueSoft),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bgVeryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.mutedBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                    height: 1.2,
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