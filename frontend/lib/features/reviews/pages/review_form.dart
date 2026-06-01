import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/api_config.dart';
import 'package:image_picker/image_picker.dart';

import '../../mybook/models/booking_model.dart';
import '../../../core/theme/app_colors.dart';
import '../services/review_service.dart';

class ReviewFormPage extends StatefulWidget {
  final BookingModel booking;
  final bool isEditing;

  const ReviewFormPage({super.key, required this.booking, this.isEditing = false});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  double _rating = 0; // default rating 
  final TextEditingController _commentController = TextEditingController();
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.booking.hasReview) {
      _rating = widget.booking.reviewRating ?? 5;
      _commentController.text = widget.booking.reviewComment ?? '';
      if (widget.booking.reviewPhotos != null) {
        _photos.addAll(widget.booking.reviewPhotos!);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _photos.add(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('ERROR PICK IMAGE: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
        ),
      );
    }
  }

  void _removePhoto(String path) {
    setState(() {
      _photos.remove(path);
    });
  }

  Future<void> _submitReview() async {
    
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rating first')),
      );
      return;
    }

    final data = {
      'pemesanan_id': widget.booking.id.toString(),
      'kamar_id': widget.booking.roomId.toString(),
      'user_id': widget.booking.userId.toString(),
      'hotel_id': widget.booking.hotelId.toString(),
      'rating': _rating.toString(),
      'komentar': _commentController.text.trim(),
    };

    try {
      Map<String, dynamic>? result;

      if (widget.isEditing) {
        if (widget.booking.reviewId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review ID tidak ditemukan')),
          );
          return;
        }

        result = await ReviewService().updateReview(
          widget.booking.reviewId!,
          data,
          _photos,
        );
      } else {
        result = await ReviewService().createReview(data, _photos);
      }

      if (result != null) {
        final reviewData = result['data'];
        final responsePhotos = reviewData?['photos'];

        setState(() {
          widget.booking.hasReview = true;
          widget.booking.reviewRating = _rating;
          widget.booking.reviewComment = _commentController.text.trim();

          if (reviewData != null && reviewData['id'] != null) {
            widget.booking.reviewId = int.tryParse(reviewData['id'].toString());
          }

          if (responsePhotos is List) {
            widget.booking.reviewPhotos =
                responsePhotos.map((e) => e.toString()).toList();
          } else {
            widget.booking.reviewPhotos = _photos;
          }
        });

        if (!mounted) return;

        await _showSuccessDialog();

        if (!mounted) return;

        Navigator.pop(context, true);
      }
    } catch (e) {
      print('ERROR SUBMIT REVIEW: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submit review: $e')),
      );
    }
  }

  Widget _buildPhotoItem(String path) {
    final cleanPath = path.replaceAll(r'\/', '/');

    final bool isNetworkImage = cleanPath.startsWith('http');
    final bool isLocalFile = cleanPath.startsWith('/');

    String imageUrl = cleanPath;

    if (!isNetworkImage && !isLocalFile) {
      final base = ApiConfig.baseUrl.replaceAll('/api', '');
      imageUrl = '$base/storage/$cleanPath';
    }

    debugPrint('REVIEW PHOTO PATH: $path');
    debugPrint('REVIEW PHOTO CLEAN PATH: $cleanPath');
    debugPrint('REVIEW PHOTO URL: $imageUrl');

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: isLocalFile
              ? Image.file(
                  File(cleanPath),
                  fit: BoxFit.cover,
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('ERROR LOAD REVIEW IMAGE: $error');

                    return Container(
                      color: const Color(0xFFE6F0FF),
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.textMuted,
                      ),
                    );
                  },
                ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _removePhoto(path),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 82),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            width: 210,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/vector_success.png',
                    width: 82,
                    height: 82,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Successful!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Thank you for your review!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: 122,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        shadowColor: AppColors.primaryEnd.withOpacity(0.25),
                        backgroundColor: AppColors.primaryEnd,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog() {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 82),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: SizedBox(
          width: 210,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/vector_permission.png',
                  width: 82,
                  height: 82,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Remove Review?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Are you sure want to delete this\nreview?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: 122,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shadowColor: const Color(0xFFD91E18).withOpacity(0.25),
                      backgroundColor: const Color(0xFFD91E18),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: 122,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.16),
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Future<void> _deleteReview() async {
    debugPrint('REVIEW ID DELETE: ${widget.booking.reviewId}');

    if (widget.booking.reviewId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review ID tidak ditemukan')),
      );
      return;
    }

    final confirm = await _showDeleteDialog();

    if (confirm != true) return;

    try {
      final success = await ReviewService().deleteReview(widget.booking.reviewId!);

      if (success) {
        setState(() {
          widget.booking.hasReview = false;
          widget.booking.reviewId = null;
          widget.booking.reviewRating = null;
          widget.booking.reviewComment = null;
          widget.booking.reviewPhotos = null;
        });

        if (!mounted) return;

        Navigator.pop(context, 'deleted');
      }
    } catch (e) {
      debugPrint('ERROR DELETE REVIEW: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Review' : 'Write a Review',
            style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primaryEnd,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE6F0FF), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.booking.imagePath.startsWith('http')
                        ? Image.network(widget.booking.imagePath, width: 80, height: 80, fit: BoxFit.cover)
                        : Image.asset(widget.booking.imagePath, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Stay Completed",
                            style: const TextStyle(fontSize: 12, color: AppColors.primaryEnd, fontWeight: FontWeight.w700)),
                        Text(widget.booking.hotelName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.darkBlue)),
                        Text(widget.booking.roomName,
                            style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                        Text(
                          "${BookingFormatters.dayMonthYear(widget.booking.checkInDate)} - ${BookingFormatters.dayMonthYear(widget.booking.checkOutDate)}",
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating
            Center(
              child: Text(widget.isEditing ? 'Edit your rating' : 'Rate your stay',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                    onPressed: () => setState(() => _rating = index + 1.0),
                  ),
                );
              }),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text('Tap to rate your experience', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const SizedBox(height: 24),

            // Comment
            const Text('Share your experience', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tell us about your stay, service, cleanliness, and overall experience...',
                hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                fillColor: const Color(0xFFF1F5FF),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),

            // Photos
            const Text('Add photos (optional)', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PhotoButton(icon: Icons.camera_alt, label: 'Take Photo', onTap: () => _pickImage(ImageSource.camera)),
                  const SizedBox(width: 8),
                  _PhotoButton(icon: Icons.image, label: 'Gallery', onTap: () => _pickImage(ImageSource.gallery)),
                  const SizedBox(width: 8),
                  ..._photos.map((path) => _buildPhotoItem(path)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEnd,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(widget.isEditing ? 'Update Review' : 'Submit Review',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white)),
              ),
            ),
            const SizedBox(height: 6),
            if (widget.isEditing) ...[
              Center(
                child: TextButton.icon(
                  onPressed: _deleteReview,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete Review',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: const Color(0xFFE6F0FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 28, color: AppColors.primaryEnd),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
        ],
      ),
    );
  }
}