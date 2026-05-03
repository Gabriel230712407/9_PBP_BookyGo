import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/pages/home_page.dart';
import '../../mybook/pages/mybook_page.dart';
import '../../whistlist/pages/wishlist_page.dart';
import '../../profile/pages/profile_page.dart';

class MainNavPage extends StatefulWidget {
  final bool isGuest;
  final String? userEmail;

  const MainNavPage({
    super.key,
    this.isGuest = true,
    this.userEmail,
  });

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Positioned(
                top: 8,
                child: Container(
                  width: 26,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            Center(
              child: Icon(
                icon,
                size: isSelected ? 30 : 28,
                color: isSelected
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        isGuest: widget.isGuest,
        userEmail: widget.userEmail,
      ),
      MyBookPage(
        onBookNowTap: () {
          _onItemTapped(0);
        },
      ),
      const WishlistPage(),
      ProfilePage(isGuest: widget.isGuest),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 74,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryEnd,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long_rounded,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.favorite_rounded,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}