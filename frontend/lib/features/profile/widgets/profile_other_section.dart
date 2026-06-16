import 'package:flutter/material.dart';
import 'package:frontend/core/auth/services/auth_storage.dart';
import 'package:frontend/core/auth/services/fingerprint_service.dart';
import 'profile_menu_item.dart';
import 'profile_palette.dart';
import 'profile_section_title.dart';

class ProfileOtherSection extends StatefulWidget {
  final VoidCallback onLogoutTap;

  const ProfileOtherSection({
    super.key,
    required this.onLogoutTap,
  });

  @override
  State<ProfileOtherSection> createState() => _ProfileOtherSectionState();
}

class _ProfileOtherSectionState extends State<ProfileOtherSection> {
  bool _isFingerprintAvailable = false;
  bool _isFingerprintEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadFingerprintStatus();
  }

  Future<void> _loadFingerprintStatus() async {
    final isAvailable = await FingerprintService.isAvailable();
    final isEnabled = await AuthStorage.isFingerprintEnabled();
    if (mounted) {
      setState(() {
        _isFingerprintAvailable = isAvailable;
        _isFingerprintEnabled = isEnabled;
      });
    }
  }

  Future<void> _handleFingerprintToggle(bool value) async {
    if (value) {
      // Minta scan dulu sebelum aktifkan
      final authenticated = await FingerprintService.authenticate(
        reason: 'Scan your fingerprint to enable fingerprint login',
      );
      if (!authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fingerprint authentication failed.')),
          );
        }
        return;
      }
    }

    await AuthStorage.setFingerprintEnabled(value);
    if (mounted) {
      setState(() => _isFingerprintEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Fingerprint login enabled.'
                : 'Fingerprint login disabled.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileSectionTitle(title: 'Others'),
        if (_isFingerprintAvailable)
          ProfileMenuItem(
            icon: Icons.fingerprint,
            title: 'Fingerprint Login',
            iconColor: ProfilePalette.black,
            trailing: Switch(
              value: _isFingerprintEnabled,
              onChanged: _handleFingerprintToggle,
              activeColor: ProfilePalette.black,
            ),
            onTap: () => _handleFingerprintToggle(!_isFingerprintEnabled),
          ),
        ProfileMenuItem(
          icon: Icons.info,
          title: 'About BookyGoo.com',
          iconColor: ProfilePalette.black,
          onTap: () {},
        ),
        ProfileMenuItem(
          icon: Icons.logout,
          title: 'Log Out',
          iconColor: ProfilePalette.black,
          onTap: widget.onLogoutTap,
        ),
      ],
    );
  }
}