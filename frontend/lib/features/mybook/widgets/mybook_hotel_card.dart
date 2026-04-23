import 'package:flutter/material.dart';

class MyBookHotelCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String ratingText;

  const MyBookHotelCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.ratingText,
  });

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1F2A44);
    const textGrey = Color(0xFF7B88A8);

    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            child: Image.network(
              imageUrl,
              width: 190,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 190,
                  height: 120,
                  color: const Color(0xFFE9EEFF),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkBlue,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ratingText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textGrey,
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