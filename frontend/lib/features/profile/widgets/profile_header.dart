import 'package:flutter/material.dart';
import 'profile_palette.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onEditTap;
  final String? avatarAsset;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.onEditTap,
    this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ProfilePalette.white,
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 18),
      child: Row(
        children: [
          Stack(
            children: [
              ClipOval(
                child: Image.asset(
                  avatarAsset ?? 'assets/images/profile_avatar.png',
                  width: 62,
                  height: 62,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ProfilePalette.background,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 34,
                        color: ProfilePalette.iconGrey,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ProfilePalette.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ProfilePalette.background,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: ProfilePalette.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: ProfilePalette.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit Profile Detail',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ProfilePalette.darkText,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: ProfilePalette.darkText,
                      ),
                    ],
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