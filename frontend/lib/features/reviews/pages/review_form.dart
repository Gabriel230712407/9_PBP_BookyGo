import 'package:flutter/material.dart';
import '../../mybook/models/booking_model.dart';
import '../../../core/theme/app_colors.dart';

class ReviewFormPage extends StatefulWidget {
  final BookingModel booking;
  const ReviewFormPage({super.key, required this.booking});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  void _submitReview() {
    // TODO: panggil API review dengan data berikut:
    // bookingCode: widget.booking.bookingCode
    // rating: _rating
    // comment: _commentController.text
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted!')),
    );
    Navigator.pop(context); // kembali ke halaman detail
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
        backgroundColor: AppColors.primaryEnd,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.booking.hotelName,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 8),
            Text(widget.booking.roomName,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 24),

            const Text('Rating', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 24),
            const Text('Comment', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your comment here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEnd,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Review',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}