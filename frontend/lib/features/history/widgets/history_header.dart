import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HistoryHeader extends StatelessWidget {
  final bool isSelecting;
  final bool hasSelectedItem;
  final VoidCallback onSelect;
  final VoidCallback onCancelSelect;
  final VoidCallback onDeleteAll;
  final VoidCallback onDeleteSelected;
  final bool showActions;

  const HistoryHeader({
    super.key,
    this.isSelecting = false,
    this.hasSelectedItem = false,
    required this.onSelect,
    required this.onCancelSelect,
    required this.onDeleteAll,
    required this.onDeleteSelected,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryEnd,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {
                  if (isSelecting) {
                    onCancelSelect();
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 24,
                ),
              ),

              Text(
                isSelecting ? 'Select History' : 'History',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              if (!showActions)
                const SizedBox(width: 4)
              else if (isSelecting)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: hasSelectedItem ? onDeleteSelected : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      
                      child: Icon(
                        Icons.delete,
                        size: 28,
                        color: hasSelectedItem
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : AppColors.white.withOpacity(0.35),
                      ),
                    ),
                  ),
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.white,
                    size: 24,
                  ),
                  offset: const Offset(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: AppColors.white.withOpacity(0.96),
                  elevation: 6,
                  onSelected: (value) {
                    if (value == 'select') {
                      onSelect();
                    } else if (value == 'delete_all') {
                      onDeleteAll();
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'select',
                        height: 44,
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_box_outlined,
                              size: 20,
                              color: AppColors.primaryEnd,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Select',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuDivider(height: 1),
                      PopupMenuItem(
                        value: 'delete_all',
                        height: 44,
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_sweep_outlined,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Delete All',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),

              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
