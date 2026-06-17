import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/auth/services/auth_service.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class RoomReviewListPage extends StatefulWidget {
  final int kamarId;
  final String title;

  const RoomReviewListPage({
    super.key,
    required this.kamarId,
    this.title = 'Reviews',
  });

  @override
  State<RoomReviewListPage> createState() => _RoomReviewListPageState();
}

class _RoomReviewListPageState extends State<RoomReviewListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  ReviewResponse? _reviewResponse;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final result = await ReviewService().getReviews(
        kamarId: widget.kamarId,
      );

      if (!mounted) return;
      setState(() {
        _reviewResponse = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateLocalReview(ReviewModel updatedReview) {
    final reviews = _reviewResponse?.reviews;
    if (reviews == null) return;

    final index = reviews.indexWhere((r) => r.id == updatedReview.id);
    if (index >= 0) {
      setState(() {
        reviews[index] = updatedReview;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviewResponse?.reviews ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryEnd,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadReviews();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : reviews.isEmpty
                  ? const Center(
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        return _RoomReviewCard(
                          key: ValueKey(reviews[index].id),
                          review: reviews[index],
                          onUpdated: _updateLocalReview,
                        );
                      },
                    ),
    );
  }
}

class _RoomReviewCard extends StatefulWidget {
  final ReviewModel review;
  final Function(ReviewModel updatedReview)? onUpdated;

  const _RoomReviewCard({
    super.key,
    required this.review,
    this.onUpdated,
  });

  @override
  State<_RoomReviewCard> createState() => _RoomReviewCardState();
}

class _RoomReviewCardState extends State<_RoomReviewCard> {
  bool _isSubmittingHelpful = false;
  late ReviewModel _review;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
  }

  @override
  void didUpdateWidget(covariant _RoomReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.review != widget.review) {
      _review = widget.review;
    }
  }

  Future<void> _toggleHelpful() async {
    if (_isSubmittingHelpful) return;

    setState(() => _isSubmittingHelpful = true);

    try {
      final session = await AuthService.currentSession();
      if (session == null) throw Exception('User not logged in');

      final response = await ReviewService().toggleHelpful(
        reviewId: _review.id,
      );

      if (response != null) {
        // FIX 2: Gunakan copyWith, jangan mutasi langsung
        final updatedReview = _review.copyWith(
          helpfulCount: response['helpful_count'] as int,
          isHelpful: response['is_helpful'] as bool,
        );

        setState(() => _review = updatedReview);
        widget.onUpdated?.call(updatedReview);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingHelpful = false);
      }
    }
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
    if (difference.inDays >= 30) {
      final month = (difference.inDays / 30).floor();
      return '$month ${month == 1 ? 'month' : 'months'} ago';
    }
    if (difference.inDays >= 1) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    // FIX 3: Render dari _review (local state), bukan widget.review
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AvatarImage(url: _review.userPhoto),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _review.userName ?? 'User',
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < _review.rating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: const Color(0xFFFFC107),
                  size: 13,
                );
              }),
              const SizedBox(width: 6),
              Text(
                _timeAgo(_review.createdAt),
                style: const TextStyle(
                  color: Color(0xFF9DA5B7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _review.komentar.isEmpty ? 'No comment' : _review.komentar,
            style: const TextStyle(
              color: AppColors.darkBlue,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _isSubmittingHelpful ? null : _toggleHelpful,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isSubmittingHelpful
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      : Icon(
                          _review.isHelpful
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color: _review.isHelpful
                              ? AppColors.primaryEnd
                              : const Color(0xFF5E7CEB),
                          size: 14,
                        ),
                  const SizedBox(width: 4),
                  Text(
                    'Helpful (${_review.helpfulCount})',
                    style: const TextStyle(
                      color: AppColors.primaryEnd,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ReviewPhotos(photos: _review.photoUrls),
          ],
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String? url;

  const _AvatarImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFDCE4F5),
        child: Icon(Icons.person, color: Colors.white, size: 21),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFDCE4F5),
      backgroundImage: NetworkImage(url!),
      onBackgroundImageError: (_, __) {},
    );
  }
}

class _ReviewPhotos extends StatelessWidget {
  final List<String> photos;

  const _ReviewPhotos({required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.length == 1) {
      return _PhotoTile(
        photoUrl: photos.first,
        width: double.infinity,
        height: 270,
        photos: photos,
        initialIndex: 0,
      );
    }

    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _PhotoTile(
            photoUrl: photos[index],
            width: 282,
            height: 270,
            photos: photos,
            initialIndex: index,
          );
        },
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String photoUrl;
  final double width;
  final double height;
  final List<String> photos;
  final int initialIndex;

  const _PhotoTile({
    required this.photoUrl,
    required this.width,
    required this.height,
    required this.photos,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ReviewPhotoViewer(
              photos: photos,
              initialIndex: initialIndex,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          photoUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: width,
              height: height,
              color: const Color(0xFFE6F0FF),
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewPhotoViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _ReviewPhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_ReviewPhotoViewer> createState() => _ReviewPhotoViewerState();
}

class _ReviewPhotoViewerState extends State<_ReviewPhotoViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    widget.photos[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 48,
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white54),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 42,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          if (widget.photos.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1}/${widget.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
