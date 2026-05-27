import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../mybook/models/booking_model.dart';
import '../../mybook/services/booking_service.dart';
import '../widgets/empty_history_view.dart';
import '../widgets/history_card.dart';
import '../widgets/history_header.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final BookingService _bookingService = BookingService();

  bool isSelecting = false;
  final Set<int> selectedBookingIds = {};
  late Future<List<BookingModel>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = _bookingService.fetchMyBookings();
  }

  Future<void> _refresh() async {
    final future = _bookingService.fetchMyBookings();
    setState(() {
      _futureBookings = future;
    });
    await future;
  }

  void _enterSelectMode() {
    setState(() {
      isSelecting = true;
    });
  }

  void _cancelSelectMode() {
    setState(() {
      isSelecting = false;
      selectedBookingIds.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final ids = selectedBookingIds.toList();
    for (final id in ids) {
      await _bookingService.deleteBooking(id);
    }
    selectedBookingIds.clear();
    isSelecting = false;
    await _refresh();
  }

  Future<void> _deleteAll(List<BookingModel> bookings) async {
    for (final booking in bookings) {
      await _bookingService.deleteBooking(booking.id);
    }
    selectedBookingIds.clear();
    isSelecting = false;
    await _refresh();
  }

  void _toggleSelected(int bookingId, bool? value) {
    setState(() {
      if (value == true) {
        selectedBookingIds.add(bookingId);
      } else {
        selectedBookingIds.remove(bookingId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgVeryLight,
      body: FutureBuilder<List<BookingModel>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          final bookings = snapshot.data ?? const [];

          return Column(
            children: [
              HistoryHeader(
                isSelecting: isSelecting,
                hasSelectedItem: selectedBookingIds.isNotEmpty,
                onSelect: _enterSelectMode,
                onCancelSelect: _cancelSelectMode,
                onDeleteAll: () {
                  _deleteAll(bookings);
                },
                onDeleteSelected: () {
                  _deleteSelected();
                },
              ),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : bookings.isEmpty
                            ? const EmptyHistoryView()
                            : RefreshIndicator(
                                onRefresh: _refresh,
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                                  itemCount: bookings.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final booking = bookings[index];

                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (isSelecting) ...[
                                          SizedBox(
                                            width: 40,
                                            child: Checkbox(
                                              value: selectedBookingIds.contains(
                                                booking.id,
                                              ),
                                              activeColor: AppColors.primaryEnd,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              onChanged: (value) {
                                                _toggleSelected(booking.id, value);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Expanded(
                                          child: HistoryCard(
                                            booking: booking,
                                            onDelete: () async {
                                              await _bookingService.deleteBooking(
                                                booking.id,
                                              );
                                              await _refresh();
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}
