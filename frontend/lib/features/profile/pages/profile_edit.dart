import 'package:flutter/material.dart';
import 'package:frontend/core/auth/services/auth_service.dart';

import '../../onboarding/pages/welcome_page.dart';
import '../widgets/edit_profile_account_info_section.dart';
import '../widgets/edit_profile_contact_section.dart';
import '../widgets/edit_profile_delete_account.dart';
import '../widgets/edit_profile_header.dart';
import '../widgets/profile_palette.dart';
import '../widgets/profile_section_divider.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _gender = 'Male';
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false; // ← BARU: kontrol mode edit

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final session = await AuthService.currentSession();

    if (!mounted) return;

    if (session == null) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Session tidak ditemukan. Silakan login ulang.');
      return;
    }

    final dynamic user = session.user;

    final name = _readDynamicValue(() => user.name) ?? 'BookyGo User';
    final email = _readDynamicValue(() => user.email) ?? '-';
    final gender = _readDynamicValue(() => user.gender) ?? 'Male';

    final phone = _readDynamicValue(() => user.phoneNumber) ??
        _readDynamicValue(() => user.noTelp) ??
        _readDynamicValue(() => user.no_telp) ??
        '';

    if (!mounted) return;

    setState(() {
      _nameController.text = name;
      _emailController.text = email;
      _phoneController.text = phone;
      _gender = _normalizeGender(gender);
      _isLoading = false;
    });
  }

  String? _readDynamicValue(Object? Function() getter) {
    try {
      final value = getter();
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text == 'null') return null;
      return text;
    } catch (_) {
      return null;
    }
  }

  String _normalizeGender(String value) {
    final lower = value.toLowerCase();
    if (lower == 'wanita' || lower == 'female' || lower == 'perempuan') {
      return 'Female';
    }
    return 'Male';
  }

  String _genderForBackend(String value) {
    return value == 'Female' ? 'Wanita' : 'Pria';
  }

  void _handleBack() {
    // Jika sedang edit mode, keluar edit mode dulu (cancel)
    if (_isEditMode) {
      setState(() {
        _isEditMode = false;
      });
      _loadProfileData(); // reset ke data semula
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) {
      ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
      Navigator.of(context).pop(true);
    }
  }

  // ← BARU: masuk ke mode edit (dipanggil saat pencil di-tap)
  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
    });
  }

  Future<void> _saveProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? gender,
  }) async {
    final currentName = (name ?? _nameController.text).trim();
    final currentEmail = (email ?? _emailController.text).trim();
    final currentPhone = (phoneNumber ?? _phoneController.text).trim();
    final currentGender = gender ?? _gender;

    if (currentName.isEmpty || currentName == '-') {
      _showMessage('Nama tidak boleh kosong.');
      return;
    }

    if (currentEmail.isEmpty || currentEmail == '-') {
      _showMessage('Email tidak boleh kosong.');
      return;
    }

    if (!_isValidEmail(currentEmail)) {
      _showMessage('Format email tidak valid.');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedSession = await AuthService.updateProfile(
        name: currentName,
        email: currentEmail,
        gender: _genderForBackend(currentGender),
        phoneNumber: currentPhone,
      );

      if (!mounted) return;

      final dynamic user = updatedSession.user;

      final updatedName = _readDynamicValue(() => user.name) ?? currentName;
      final updatedEmail = _readDynamicValue(() => user.email) ?? currentEmail;
      final updatedGender =
          _readDynamicValue(() => user.gender) ?? currentGender;
      final updatedPhone = _readDynamicValue(() => user.phoneNumber) ??
          _readDynamicValue(() => user.noTelp) ??
          _readDynamicValue(() => user.no_telp) ??
          currentPhone;

      setState(() {
        _nameController.text = updatedName;
        _emailController.text = updatedEmail;
        _phoneController.text = updatedPhone;
        _gender = _normalizeGender(updatedGender);
        _isSaving = false;
      });

      // ← BARU: tampilkan popup sukses lalu keluar edit mode
      await _showSuccessDialog();

      if (!mounted) return;
      setState(() {
        _isEditMode = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      _showMessage(e.toString());
    }
  }

  // ← BARU: popup sukses setelah simpan profil
  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon sukses
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ProfilePalette.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: ProfilePalette.primaryBlue,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Successful!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ProfilePalette.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Profil kamu berhasil diperbarui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: ProfilePalette.mutedText,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfilePalette.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  Future<String?> _openTextChangeDialog({
    required String title,
    required String label,
    required String initialValue,
    required TextInputType keyboardType,
  }) async {
    String input = initialValue == '-' ? '' : initialValue;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextFormField(
            initialValue: input,
            autofocus: true,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(labelText: label),
            onChanged: (value) {
              input = value;
            },
            onFieldSubmitted: (value) {
              FocusScope.of(dialogContext).unfocus();
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(input.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted) return null;
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return null;

    return result?.trim();
  }

  Future<void> _openEmailChangeDialog() async {
    final result = await _openTextChangeDialog(
      title: 'Change Email',
      label: 'Email',
      initialValue: _emailController.text,
      keyboardType: TextInputType.emailAddress,
    );
    if (result == null || result.isEmpty) return;
    await _saveProfile(email: result);
  }

  Future<void> _openPhoneChangeDialog() async {
    final result = await _openTextChangeDialog(
      title: 'Change Phone Number',
      label: 'Phone number',
      initialValue: _phoneController.text,
      keyboardType: TextInputType.phone,
    );
    if (result == null || result.isEmpty) return;
    await _saveProfile(phoneNumber: result);
  }

  Future<void> _openDeleteAccountInfo() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await AuthService.deleteAccount();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfilePalette.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditProfileHeader(
            onBackTap: _handleBack,
          ),

          if (_isSaving)
            const LinearProgressIndicator(
              minHeight: 2,
              color: ProfilePalette.primaryBlue,
              backgroundColor: ProfilePalette.divider,
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ← kirim isEditMode & onEnterEditMode ke section
                        EditProfileAccountInfoSection(
                          nameController: _nameController,
                          selectedGender: _gender,
                          isEditMode: _isEditMode,
                          onNameEditTap: _enterEditMode,
                          onGenderChanged: _isEditMode
                              ? (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _gender = value;
                                  });
                                }
                              : null, // disabled saat bukan edit mode
                        ),

                        const ProfileSectionDivider(),

                        EditProfileContactSection(
                          phoneNumber: _phoneController.text,
                          email: _emailController.text,
                          onPhoneChangeTap: _openPhoneChangeDialog,
                          onEmailChangeTap: _openEmailChangeDialog,
                        ),

                        const SizedBox(height: 24),

                        // ← BARU: tombol Edit Profile atau Delete Account
                        if (_isEditMode)
                          _buildEditProfileButton()
                        else
                          EditProfileDeleteAccount(
                            onTap: _openDeleteAccountInfo,
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ← BARU: widget tombol "Edit Profile"
  Widget _buildEditProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isSaving ? null : () => _saveProfile(),
          style: ElevatedButton.styleFrom(
            backgroundColor: ProfilePalette.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}