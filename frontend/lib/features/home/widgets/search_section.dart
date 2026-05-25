import 'package:flutter/material.dart';
import 'package:frontend/features/hotel/pages/hotel_list_page.dart';

import '../../../core/theme/app_colors.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _destinationController =
      TextEditingController(text: 'Yogyakarta');

  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  int _rooms = 1;
  int _guests = 2;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _checkInDate = today;
    _checkOutDate = today.add(const Duration(days: 1));
  }

  String formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: _checkInDate,
        end: _checkOutDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  Widget _buildCounterBox({
    required String title,
    required int value,
    required IconData icon,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.blueSoft),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bgVeryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.mutedBlue, size: 22),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onRemove,
                  child: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                InkWell(
                  onTap: onAdd,
                  child: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 360;

        return Container(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 14 : 16,
            isCompact ? 16 : 18,
            isCompact ? 14 : 16,
            isCompact ? 16 : 18,
          ),
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
              Text(
                'Find Your Stay',
                style: TextStyle(
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlue,
                ),
              ),
              SizedBox(height: isCompact ? 14 : 18),
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                  ),
                  hintText: 'Destination',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isCompact ? 14 : 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.blueSoft),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.blueSoft),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 12 : 14),
              InkWell(
                onTap: _pickDateRange,
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoBox(
                        icon: Icons.event_available_outlined,
                        title: 'Check-in',
                        value: formatDate(_checkInDate),
                      ),
                    ),
                    SizedBox(width: isCompact ? 8 : 10),
                    Expanded(
                      child: _InfoBox(
                        icon: Icons.event_note_outlined,
                        title: 'Check-out',
                        value: formatDate(_checkOutDate),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isCompact ? 10 : 12),
              Row(
                children: [
                  _buildCounterBox(
                    title: 'Room(s)',
                    value: _rooms,
                    icon: Icons.bed_rounded,
                    onAdd: () => setState(() => _rooms++),
                    onRemove: () {
                      if (_rooms > 1) {
                        setState(() => _rooms--);
                      }
                    },
                  ),
                  SizedBox(width: isCompact ? 8 : 10),
                  _buildCounterBox(
                    title: 'Guest(s)',
                    value: _guests,
                    icon: Icons.person_rounded,
                    onAdd: () => setState(() => _guests++),
                    onRemove: () {
                      if (_guests > 1) {
                        setState(() => _guests--);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 14 : 18),
              SizedBox(
                width: double.infinity,
                height: isCompact ? 46 : 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primaryEnd,
                        AppColors.blueDark,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelListPage(
                            destination: _destinationController.text.trim(),
                            checkInDate: _checkInDate,
                            checkOutDate: _checkOutDate,
                            roomCount: _rooms,
                            guestCount: _guests,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Search Hotel',
                      style: TextStyle(
                        fontSize: isCompact ? 15 : 17,
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
      },
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
            child: Icon(icon, color: AppColors.mutedBlue, size: 24),
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
