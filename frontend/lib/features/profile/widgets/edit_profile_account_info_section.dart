import 'package:flutter/material.dart';
import 'edit_profile_field.dart';
import 'profile_palette.dart';

class EditProfileAccountInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedGender;
  final VoidCallback onNameEditTap;
  final ValueChanged<String?> onGenderChanged;

  const EditProfileAccountInfoSection({
    super.key,
    required this.nameController,
    required this.selectedGender,
    required this.onNameEditTap,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ProfilePalette.white,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Owner Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ProfilePalette.darkText,
            ),
          ),
          const SizedBox(height: 18),
          EditProfileTextField(
            label: 'Full Name',
            controller: nameController,
            readOnly: true,
            suffixIcon: Icons.edit,
            onSuffixTap: onNameEditTap,
          ),
          const SizedBox(height: 28),
          EditProfileDropdownField(
            label: 'Gender',
            value: selectedGender,
            items: const ['Male', 'Female'],
            onChanged: onGenderChanged,
          ),
        ],
      ),
    );
  }
}
