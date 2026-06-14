import 'package:flutter/material.dart';
import 'package:frontend/features/profile/providers/reminder_provider.dart';
import 'package:provider/provider.dart';
import 'profile_palette.dart';

class ProfileReminderSection extends StatelessWidget {
  const ProfileReminderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reminder = context.watch<ReminderProvider>();

    return Container(
      color: ProfilePalette.white,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reminder',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ProfilePalette.darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get reminders for payment, check-in, price drops on wishlist, and more',
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w400,
              color: ProfilePalette.mutedText,
            ),
          ),
          const SizedBox(height: 8),
          _ReminderSwitchRow(
            title: 'Email',
            value: reminder.emailEnabled,
            onChanged: (val) => context.read<ReminderProvider>().setEmail(val),
          ),
          Container(
            height: 1,
            color: ProfilePalette.divider,
          ),
          _ReminderSwitchRow(
            title: 'Notification',
            value: reminder.notificationEnabled,
            onChanged: (val) =>
                context.read<ReminderProvider>().setNotification(val),
          ),
        ],
      ),
    );
  }
}

class _ReminderSwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ProfilePalette.darkText,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: ProfilePalette.primaryBlue,
            inactiveThumbColor: ProfilePalette.white,
            inactiveTrackColor: ProfilePalette.inactiveSwitch,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
