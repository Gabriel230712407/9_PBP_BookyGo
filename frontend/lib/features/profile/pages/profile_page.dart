import 'package:flutter/material.dart';
import 'package:frontend/core/auth/services/auth_service.dart';

import '../../onboarding/pages/welcome_page.dart';
import 'profile_edit.dart';

import '../models/profile_stats_model.dart';
import '../services/profile_service.dart';

import '../widgets/profile_feature_section.dart';
import '../widgets/profile_guest_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_other_section.dart';
import '../widgets/profile_palette.dart';
import '../widgets/profile_reminder_section.dart';
import '../widgets/profile_section_divider.dart';
import '../widgets/profile_section_title.dart';

class ProfilePage extends StatefulWidget {
  final bool isGuest;
  final String? userName;
  final String? userEmail;

  const ProfilePage({
    super.key,
    this.isGuest = true,
    this.userName,
    this.userEmail,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _emailReminder = true;
  bool _notificationReminder = false;

  Future<ProfileStatsModel>? _profileStatsFuture;

  @override
  void initState() {
    super.initState();

    if (!widget.isGuest) {
      _loadProfileStats();
    }
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isGuest != widget.isGuest && !widget.isGuest) {
      _loadProfileStats();
    }
  }

  void _loadProfileStats() {
    _profileStatsFuture = ProfileService.getProfileStats();
  }

  Future<void> _refreshProfileStats() async {
    if (widget.isGuest) return;

    try {
      setState(() {
        _loadProfileStats();
      });

      await _profileStatsFuture;
    } catch (e) {
      debugPrint('Refresh profile stats error: $e');
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomePage(),
      ),
      (route) => false,
    );
  }

  Future<void> _goToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileEditPage(),
      ),
    );

    if (!mounted || widget.isGuest) return;

    setState(() {
      _loadProfileStats();
    });
  }

  Widget _buildProfileStatsSection() {
    final future = _profileStatsFuture;

    if (future == null) {
      return const ProfileFeatureSection(
        reviewCount: 0,
        bookedCount: 0,
        wishlistCount: 0,
      );
    }

    return FutureBuilder<ProfileStatsModel>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ProfileFeatureSection(
            reviewCount: 0,
            bookedCount: 0,
            wishlistCount: 0,
          );
        }

        if (snapshot.hasError) {
          debugPrint('Profile stats error: ${snapshot.error}');

          return const ProfileFeatureSection(
            reviewCount: 0,
            bookedCount: 0,
            wishlistCount: 0,
          );
        }

        if (!snapshot.hasData) {
          return const ProfileFeatureSection(
            reviewCount: 0,
            bookedCount: 0,
            wishlistCount: 0,
          );
        }

        final stats = snapshot.data!;

        return ProfileFeatureSection(
          reviewCount: stats.reviewCount,
          bookedCount: stats.bookedCount,
          wishlistCount: stats.wishlistCount,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfilePalette.background,
      body: SafeArea(
        bottom: false,
        child: widget.isGuest
            ? ProfileGuestCard(
                onSignInPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WelcomePage(),
                    ),
                    (route) => false,
                  );
                },
              )
            : RefreshIndicator(
                onRefresh: _refreshProfileStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileHeader(
                        userName: widget.userName ?? 'UserMantap',
                        onEditTap: _goToEditProfile,
                      ),

                      const ProfileSectionDivider(),

                      const ProfileSectionTitle(title: 'Account Features'),
                      _buildProfileStatsSection(),

                      const ProfileSectionDivider(),

                      ProfileReminderSection(
                        emailValue: _emailReminder,
                        notificationValue: _notificationReminder,
                        onEmailChanged: (value) {
                          setState(() {
                            _emailReminder = value;
                          });
                        },
                        onNotificationChanged: (value) {
                          setState(() {
                            _notificationReminder = value;
                          });
                        },
                      ),

                      const ProfileSectionDivider(),

                      ProfileOtherSection(
                        onLogoutTap: _handleLogout,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}