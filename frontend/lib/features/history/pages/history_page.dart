import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/history_header.dart';
import '../widgets/history_card.dart';
import '../widgets/empty_history_view.dart';

class HistoryPage extends StatefulWidget {
  final List<Map<String, dynamic>> histories;

  const HistoryPage({
    super.key,
    required this.histories,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<Map<String, dynamic>> histories;

  bool isSelecting = false;
  final Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();

    // Dibuat copy supaya list history bisa dihapus dari halaman ini
    histories = List<Map<String, dynamic>>.from(widget.histories);
  }

  void _enterSelectMode() {
    setState(() {
      isSelecting = true;
    });
  }

  void _cancelSelectMode() {
    setState(() {
      isSelecting = false;
      selectedIndexes.clear();
    });
  }

  void _deleteAll() {
    setState(() {
      histories.clear();
      selectedIndexes.clear();
      isSelecting = false;
    });
  }

  void _deleteSelected() {
    setState(() {
      histories = histories
          .asMap()
          .entries
          .where((entry) => !selectedIndexes.contains(entry.key))
          .map((entry) => entry.value)
          .toList();

      selectedIndexes.clear();
      isSelecting = false;
    });
  }

  void _toggleSelected(int index, bool? value) {
    setState(() {
      if (value == true) {
        selectedIndexes.add(index);
      } else {
        selectedIndexes.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: Column(
        children: [
          HistoryHeader(
            isSelecting: isSelecting,
            hasSelectedItem: selectedIndexes.isNotEmpty,
            onSelect: _enterSelectMode,
            onCancelSelect: _cancelSelectMode,
            onDeleteAll: _deleteAll,
            onDeleteSelected: _deleteSelected,
          ),

          Expanded(
            child: histories.isEmpty
                ? const EmptyHistoryView()
                : ListView.separated(
  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
  itemCount: histories.length,
  separatorBuilder: (_, __) => const SizedBox(height: 16),
  itemBuilder: (context, index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isSelecting) ...[
          SizedBox(
            width: 40,
            child: Checkbox(
              value: selectedIndexes.contains(index),
              activeColor: AppColors.primaryEnd,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) {
                _toggleSelected(index, value);
              },
            ),
          ),
          const SizedBox(width: 6),
        ],

        Expanded(
          child: HistoryCard(
            history: histories[index],
          ),
        ),
      ],
    );
  },
)
          ),
        ],
      ),
    );
  }
}