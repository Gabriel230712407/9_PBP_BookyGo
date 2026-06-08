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

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
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
        final stats = snapshot.data;
        return ProfileFeatureSection(
          reviewCount: stats?.reviewCount ?? 0,
          bookedCount: stats?.bookedCount ?? 0,
          wishlistCount: stats?.wishlistCount ?? 0,
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
                    MaterialPageRoute(builder: (_) => const WelcomePage()),
                    (route) => false,
                  );
                },
              )
            : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileHeader(
                    userName: widget.userName ?? 'User',
                    onEditTap: _goToEditProfile,
                  ),
                  const ProfileSectionDivider(),
                  const ProfileSectionTitle(title: 'Account Features'),
                  _buildProfileStatsSection(),
                  const ProfileSectionDivider(),
                  const ProfileReminderSection(),
                  const ProfileSectionDivider(),
                  ProfileOtherSection(
                    onLogoutTap: _handleLogout,
                  ),
                ],
              ),
            ),
      ),
    );
  }
}