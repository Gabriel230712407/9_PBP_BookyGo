import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/auth/services/auth_storage.dart';
import '../../../core/constants/api_config.dart';
import 'profile_palette.dart';

class ProfileHeader extends StatefulWidget {
  final String userName;
  final String? userEmail;
  final VoidCallback onEditTap;
  final String? avatarAsset;

  const ProfileHeader({
    super.key,
    required this.userName,
    this.userEmail,
    required this.onEditTap,
    this.avatarAsset,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? _localImagePath;
  String? _serverFotoUrl;
  String? _email;
  String _token = '';
  bool _isUploading = false;
  final _picker = ImagePicker();
  static const _localPathKey = 'profile_image_path';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await AuthStorage.getSession();
    if (session == null) return;
    _token = session.token;
    _email = session.user.email;
    await Future.wait([
      _loadLocalImage(),
      _fetchServerFoto(),
    ]);
  }

  Future<void> _loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localPathKey);
    if (saved != null && File(saved).existsSync()) {
      if (mounted) setState(() => _localImagePath = saved);
    }
  }

  Future<void> _fetchServerFoto() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final foto = data['foto'];
        if (foto != null && foto.toString().isNotEmpty && mounted) {
          
          // Cek apakah foto sudah URL penuh (dari Google) atau path lokal
          final String fotoUrl;
          if (foto.toString().startsWith('http')) {
            fotoUrl = foto.toString(); // URL Google, pakai langsung
          } else {
            final base = ApiConfig.baseUrl.replaceAll('/api', '');
            fotoUrl = '$base/storage/$foto'; // path lokal, tambah base URL
          }
          
          setState(() => _serverFotoUrl = fotoUrl);
        }
      }
    } catch (_) {}
  }

  Future<void> _uploadFoto(String filePath) async {
    if (_token.isEmpty) return;
    setState(() => _isUploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/profile/foto'),
      );
      request.headers['Authorization'] = 'Bearer $_token';
      request.headers['Accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath('foto', filePath),
      );

      final streamed = await request.send();
      final body = jsonDecode(await streamed.stream.bytesToString());

      if (streamed.statusCode == 200 && mounted) {
        setState(() {
          _serverFotoUrl = body['data']['foto_url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload photo. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return;

      // Simpan path lokal
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localPathKey, picked.path);
      if (mounted) setState(() => _localImagePath = picked.path);

      // Upload ke server → masuk database
      await _uploadFoto(picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deletePhoto() async {
    // Hapus lokal
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localPathKey);
    if (mounted) setState(() {
      _localImagePath = null;
      _serverFotoUrl = null;
    });

    // Update server (set foto ke null)
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'foto': null}),
      );
    } catch (_) {}
  }

  void _showPickerSheet() {
    final hasPhoto = _localImagePath != null || _serverFotoUrl != null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: ProfilePalette.darkText,
                ),
              ),
              const SizedBox(height: 16),
              _PickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                color: const Color(0xff5E7CEB),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _PickerOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                color: const Color(0xff5E7CEB),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 10),
                _PickerOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _deletePhoto();
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    // Prioritas: file lokal → URL server → null (icon default)
    if (_localImagePath != null && File(_localImagePath!).existsSync()) {
      return FileImage(File(_localImagePath!));
    }
    if (_serverFotoUrl != null && _serverFotoUrl!.isNotEmpty) {
      return NetworkImage(_serverFotoUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();

    return Container(
      color: ProfilePalette.white,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        children: [
          // Avatar + kamera icon
          GestureDetector(
            onTap: _showPickerSheet,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: ProfilePalette.background,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.person, size: 34,
                          color: ProfilePalette.iconGrey)
                      : null,
                ),
                // Loading indicator saat upload
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Ikon kamera
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: ProfilePalette.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ProfilePalette.background, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 13,
                        color: ProfilePalette.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: ProfilePalette.darkText,
                  ),
                ),
                if ((widget.userEmail ?? _email ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    (widget.userEmail ?? _email ?? '').trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ProfilePalette.mutedText,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                InkWell(
                  onTap: widget.onEditTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Edit Profile Detail',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: ProfilePalette.darkText,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 16,
                          color: ProfilePalette.darkText),
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

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(label,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
