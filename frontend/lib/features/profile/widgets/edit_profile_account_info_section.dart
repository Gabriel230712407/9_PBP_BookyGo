import 'package:flutter/material.dart';
import 'edit_profile_field.dart';
import 'profile_palette.dart';
import 'profile_section_title.dart'; // sesuaikan import kamu

class EditProfileAccountInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedGender;
  final bool isEditMode; // ← BARU
  final VoidCallback? onNameEditTap;
  final ValueChanged<String?>? onGenderChanged;

  const EditProfileAccountInfoSection({
    super.key,
    required this.nameController,
    required this.selectedGender,
    this.isEditMode = false, // ← BARU, default false
    this.onNameEditTap,
    this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionTitle(title: 'Account Owner Info'),
          const SizedBox(height: 16),

          // ── Nama ──────────────────────────────────────────
          EditProfileTextField(
            label: 'Full Name',
            controller: nameController,
            // readOnly = true saat bukan edit mode
            readOnly: !isEditMode,
            // Tampilkan pencil HANYA saat bukan edit mode
            suffixIcon: isEditMode ? null : Icons.edit_outlined,
            onSuffixTap: isEditMode ? null : onNameEditTap,
          ),

          const SizedBox(height: 16),

          // ── Gender ────────────────────────────────────────
          // onChanged null saat bukan edit mode → dropdown dikunci
          EditProfileDropdownField(
            label: 'Gender',
            value: selectedGender,
            items: const ['Male', 'Female'],
            onChanged: isEditMode ? onGenderChanged : null,
          ),
        ],
      ),
    );
  }
}
