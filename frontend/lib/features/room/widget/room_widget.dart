import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/room_model.dart';

class RoomCardWidget extends StatelessWidget {
  final RoomModel room;

  RoomCardWidget({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 28),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: room.image != null && room.image!.isNotEmpty
                  ? Image.asset(
                      room.image!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.home,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            Text(
              room.name,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xff26346B),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.bed, size: 18, color: Color(0xff26346B)),
                const SizedBox(width: 6),
                Text(
                  room.type,
                  style: const TextStyle(
                    color: Color(0xff26346B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(Icons.smoke_free, size: 18, color: Color(0xff26346B)),
                SizedBox(width: 6),
                Text(
                  'Non-smoking Room',
                  style: TextStyle(color: Color(0xff26346B), fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              room.facility,
              style: const TextStyle(color: Color(0xff26346B), fontSize: 14),
            ),

            const Divider(height: 24),

            const Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.grey),
                SizedBox(width: 6),
                Text('2 adults', style: TextStyle(color: Colors.grey)),
              ],
            ),

            const Divider(height: 24),

            const Row(
              children: [
                Icon(Icons.comment, size: 18, color: AppColors.primaryEnd),
                SizedBox(width: 4),
                Text(
                  'See Reviews(1)',
                  style: TextStyle(
                    color: AppColors.primaryEnd,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: room.price,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' / Night',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEnd,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  // nanti arahkan ke booking page
                },
                child: const Text(
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
