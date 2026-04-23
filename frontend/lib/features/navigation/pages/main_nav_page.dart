import 'package:flutter/material.dart';
import '../../home/pages/home_page.dart';
import '../../mybook/pages/mybook_page.dart';

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
        child: Center(
          child: Icon(
            icon,
            size: isSelected ? 32 : 30,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5B74E8);

    final List<Widget> pages = [
      HomePage(
        isGuest: widget.isGuest,
        userEmail: widget.userEmail,
      ),
      const MyBookPage(),
      const Center(child: Text('Wishlist Page')),
      const Center(child: Text('Profile Page')),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 82,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
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