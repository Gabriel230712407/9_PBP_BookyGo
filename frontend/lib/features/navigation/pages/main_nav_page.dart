import 'package:flutter/material.dart';
import '../../home/pages/home_page.dart';
import '../../mybook/pages/mybook_page.dart';
import '../../whistlist/pages/wishlist_page.dart';
import '../../profile/pages/profile_page.dart';
import '../widgets/app_bottom_nav_bar.dart';

class MainNavPage extends StatefulWidget {
  final bool isGuest;
  final String? userEmail;
  final String? userName;
  final int initialIndex;

  const MainNavPage({
    super.key,
    this.isGuest = true,
    this.userEmail,
    this.userName,
    this.initialIndex = 0,
  });

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  late int _selectedIndex;
  int _homeRefreshToken = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _homeRefreshToken++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        isGuest: widget.isGuest,
        userEmail: widget.userEmail,
        userName: widget.userName,
        refreshToken: _homeRefreshToken,
      ),
      MyBookPage(
        isGuest: widget.isGuest,
        onBookNowTap: () {
          _onItemTapped(0);
        },
      ),
      WishlistPage(isGuest: widget.isGuest),
      ProfilePage(
        isGuest: widget.isGuest,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
