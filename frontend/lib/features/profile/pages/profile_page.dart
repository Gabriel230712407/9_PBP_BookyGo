import 'package:flutter/material.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/theme/app_colors.dart';

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
  String? _displayUserName;

  @override
  void initState() {
    super.initState();
    _displayUserName = _nonEmptyName(widget.userName);
    if (!widget.isGuest) {
      _loadProfileStats();
      _loadSessionName();
    }
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName) {
      final nextName = _nonEmptyName(widget.userName);
      if (nextName != null) {
        _displayUserName = nextName;
      }
    }
    if (oldWidget.isGuest != widget.isGuest && !widget.isGuest) {
      _loadProfileStats();
      _loadSessionName();
    }
  }

  void _loadProfileStats() {
    _profileStatsFuture = ProfileService.getProfileStats();
  }

  String? _nonEmptyName(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text == 'null') return null;
    return text;
  }

  Future<void> _loadSessionName() async {
    final session = await AuthService.currentSession();
    if (!mounted) return;
    final name = _nonEmptyName(session?.user.name);
    if (name == null) return;
    setState(() {
      _displayUserName = name;
    });
  }

  Future<void> _goToEditProfile() async {
    final updatedName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileEditPage(),
      ),
    );
    if (!mounted || widget.isGuest) return;
    setState(() {
      final name = _nonEmptyName(updatedName);
      if (name != null) {
        _displayUserName = name;
      }
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

  Widget _buildGuestHeader() {
    return Container(
      color: AppColors.primaryEnd,
      child: const SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfilePalette.background,
      body: widget.isGuest
          ? Column(
              children: [
                _buildGuestHeader(),
                Expanded(
                  child: ProfileGuestCard(
                    onSignInPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            )
          : SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProfileHeader(
                      userName:
                          _displayUserName ??
                          _nonEmptyName(widget.userName) ??
                          'User',
                      userEmail: widget.userEmail,
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
