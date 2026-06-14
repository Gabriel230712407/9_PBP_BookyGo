import 'package:flutter/material.dart';
import '../../../core/auth/services/auth_storage.dart';
import '../../../core/widgets/app_image.dart';
import '../services/whistlist_service.dart';
import '../widgets/wishlist_empty_state.dart';
import '../widgets/wishlist_header.dart';
import '../../hotel/pages/hotel_detail.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  String _token = '';
  List<Map<String, dynamic>> _wishlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = await AuthStorage.getSession();
    if (session != null) {
      _token = session.token;
    }
    await _loadWishlists();
  }

  Future<void> _loadWishlists() async {
    if (_token.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }
    try {
      final data = await WishlistService().getMyWishlists(_token);
      if (mounted) {
        setState(() {
          _wishlists = _sortWishlistsByNewest(data);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _sortWishlistsByNewest(
    List<Map<String, dynamic>> data,
  ) {
    final sorted = List<Map<String, dynamic>>.from(data);

    sorted.sort((a, b) {
      final aDate = DateTime.tryParse((a['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse((b['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return sorted;
  }

  Future<void> _confirmRemove(Map<String, dynamic> item) async {
    final hotelId = item['hotel_id'] as int;
    final hotelName = item['hotel']?['nama'] ?? 'hotel ini';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xffEEF1FF),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.luggage_rounded,
                color: Color(0xff5E7CEB),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Remove Wishlist?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff26346B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Are you sure want to delete this wishlist?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffC0392B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xff26346B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _removeWishlist(hotelId);
    }
  }

  Future<void> _removeWishlist(int hotelId) async {
    setState(() {
      _wishlists.removeWhere((w) => w['hotel_id'] == hotelId);
    });

    try {
      await WishlistService().toggleWishlist(_token, hotelId);
    } catch (_) {
      await _loadWishlists();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus wishlist, coba lagi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getImageUrl(Map<String, dynamic> item) {
    try {
      final fotos = item['hotel']?['foto_hotels'] as List?;
      if (fotos != null && fotos.isNotEmpty) {
        // Urutkan by urutan
        final sorted = List.from(fotos)
          ..sort((a, b) => (a['urutan'] ?? 0).compareTo(b['urutan'] ?? 0));

        // Skip _group.png / _Group.png, ambil foto pertama yang ada
        for (final foto in sorted) {
          final path = (foto['path'] ?? '') as String;
          if (path.isNotEmpty &&
              !path.contains('_group') &&
              !path.contains('_Group')) {
            return path;
          }
        }

        // Fallback: ambil apapun yang ada pathnya
        for (final foto in sorted) {
          final path = (foto['path'] ?? '') as String;
          if (path.isNotEmpty) return path;
        }
      }
    } catch (_) {}
    return '';
  }

  Widget _buildWishlistCard(Map<String, dynamic> item) {
    final hotel = item['hotel'] as Map<String, dynamic>? ?? {};
    final name = hotel['nama'] ?? 'Hotel';
    final location = hotel['kota'] ?? '';
    final rawRating = double.tryParse(hotel['total_rating']?.toString() ?? '') ?? 0.0;

    final truncatedRating = (rawRating * 10).truncate() / 10;

    final rating = truncatedRating % 1 == 0
        ? truncatedRating.toInt().toString()
        : truncatedRating.toStringAsFixed(1);
    final imageUrl = _getImageUrl(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                imageUrl.isNotEmpty
                    ? AppImage(
                        imagePath: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _confirmRemove(item),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff26346B),
                        ),
                      ),
                    ),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff26346B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final now = DateTime.now();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailPage(
                            hotelId: item['hotel_id'] as int,
                            checkInDate: now,
                            checkOutDate: now.add(const Duration(days: 1)),
                            roomCount: 1,
                            guestCount: 1,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5E7CEB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text(
                      'Book now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: const Color(0xffD7DCEB),
      child: const Icon(Icons.hotel, size: 50, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: Column(
        children: [
          const WishlistHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _wishlists.isEmpty
                    ? const WishlistEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadWishlists,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 16, 16, 90),
                          itemCount: _wishlists.length,
                          itemBuilder: (context, index) {
                            return _buildWishlistCard(_wishlists[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
