import 'package:flutter/material.dart';
import 'package:frontend/core/auth/services/auth_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import '../../onboarding/pages/welcome_page.dart';
import 'profile_edit.dart';
import '../widgets/profile_guest_card.dart';
import '../widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: Column(
        children: [
          const ProfileHeader(),
          Expanded(
            child: isGuest
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
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName ?? 'BookyGo User',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                userEmail ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProfileEditPage(),
                                      ),
                                    );
                                  },
                                  child: const Text('Edit Profile'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await AuthService.logout();
                              if (!context.mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WelcomePage(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryEnd,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size.fromHeight(52),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
