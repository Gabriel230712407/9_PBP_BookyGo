import 'package:flutter/material.dart';
import '../../../core/widgets/app_image.dart';

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
    final double width = (MediaQuery.of(context).size.width * 0.52)
        .clamp(168.0, 190.0)
        .toDouble();
    final double imageHeight = width < 180 ? 108 : 120;

    return Container(
      width: width,
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
            child: imageUrl.isEmpty
                ? Container(
                    width: double.infinity,
                    height: imageHeight,
                    color: const Color(0xFFE9EEFF),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    ),
                  )
                : AppImage(
                    imagePath: imageUrl,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: imageHeight,
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
                  style: TextStyle(
                    fontSize: width < 180 ? 15 : 16,
                    fontWeight: FontWeight.w800,
                    color: darkBlue,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: width < 180 ? 12 : 13,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ratingText,
                  style: TextStyle(
                    fontSize: width < 180 ? 12 : 13,
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