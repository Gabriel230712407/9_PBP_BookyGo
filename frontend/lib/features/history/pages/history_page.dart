import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/history_header.dart';
import '../widgets/history_card.dart';
import '../widgets/empty_history_view.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, String>> histories;

  const HistoryPage({
    super.key,
    required this.histories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: Column(
        children: [
          const HistoryHeader(),
          Expanded(
            child: histories.isEmpty
                ? const EmptyHistoryView()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    itemCount: histories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return HistoryCard(
                        history: histories[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}