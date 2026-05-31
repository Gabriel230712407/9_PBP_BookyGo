import 'package:flutter/material.dart';
import '../../mybook/models/booking_model.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:io';

class ReviewFormPage extends StatefulWidget {
  final BookingModel booking;
  const ReviewFormPage({super.key, required this.booking});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  List<String> _photos = [];

  void _submitReview() {
    // TODO: panggil API review
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 18, 
          fontWeight: FontWeight.w700, 
        ),
        backgroundColor: AppColors.primaryEnd,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card hotel + room
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.booking.imagePath.startsWith('http')
                        ? Image.network(
                            widget.booking.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            widget.booking.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Stay Completed",
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryEnd,
                                fontWeight: FontWeight.w700)),
                        Text(widget.booking.hotelName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.darkBlue)),
                        Text(widget.booking.roomName,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.textMuted)),
                        Text(
                          "${BookingFormatters.dayMonthYear(widget.booking.checkInDate)} - ${BookingFormatters.dayMonthYear(widget.booking.checkOutDate)}",
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating
            const Center(
              child: Text(
                'Rate your stay',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text('Tap to rate your experience',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
            const SizedBox(height: 24),

            // Comment
            const Text('Share your experience',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Tell us about your stay, service, cleanliness, and overall experience...',
                hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                fillColor: const Color(0xFFF1F5FF),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),

            // Add photos
            const Text('Add photos (optional)',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PhotoButton(
                      icon: Icons.camera_alt,
                      label: 'Take Photo',
                      onTap: () {}),
                  const SizedBox(width: 16),
                  _PhotoButton(icon: Icons.image, label: 'Gallery', onTap: () {}),
                  const SizedBox(width: 16),
                  ..._photos.map((path) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                              image: FileImage(File(path)), fit: BoxFit.cover),
                        ),
                      )),
                  if (_photos.isEmpty)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(Icons.add, size: 36, color: AppColors.textMuted),
                    )
                ],
              ),
            ),
            const SizedBox(height: 32), // sedikit di atas dari bawah

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _rating > 0 ? AppColors.primaryEnd : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
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

  const _PhotoButton(
      {super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 36, color: AppColors.primaryEnd),
          ),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textDark))
        ],
      ),
    );
  }
}