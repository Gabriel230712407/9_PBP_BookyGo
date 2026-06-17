import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
// import '../../navigation/widgets/app_bottom_nav_bar.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';
import '../../../core/auth/services/auth_service.dart';

class ReviewListPage extends StatefulWidget {
  final int? hotelId;
  final int? kamarId;
  final String title;
  final String? hotelName;
  final String? hotelLocation;
  final String? hotelImage;

  const ReviewListPage({
    super.key,
    this.hotelId,
    this.kamarId,
    this.title = 'Reviews',
    this.hotelName,
    this.hotelLocation,
    this.hotelImage,
  });

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
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
    final session = await AuthService.currentSession();

    print('SESSION: $session');

    final result = await ReviewService().getReviews(
      hotelId: widget.hotelId,
      kamarId: widget.kamarId,
      token: session?.token,
    );

      setState(() {
        _reviewResponse = result;
        _isLoading = false;
      });
    } catch (e) {
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
    final summary = _reviewResponse?.summary;
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
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
                  children: [
                    _HotelReviewHeader(
                      hotelName: widget.hotelName ?? 'Hotel',
                      hotelLocation: widget.hotelLocation ?? '',
                      hotelImage: widget.hotelImage,
                      averageRating: summary?.averageRating ?? 0,
                      totalReview: summary?.totalReview ?? 0,
                    ),
                    const SizedBox(height: 12),
                    if (reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(
                          child: Text(
                            'No reviews yet',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ...reviews.map(
                        (review) => _ReviewCard(
                          key: ValueKey(review.id),
                          review: review,
                          onUpdated: _updateLocalReview,
                        ),
                      ),
                  ],
                ),
      // bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _HotelReviewHeader extends StatelessWidget {
  final String hotelName;
  final String hotelLocation;
  final String? hotelImage;
  final double averageRating;
  final int totalReview;

  const _HotelReviewHeader({
    required this.hotelName,
    required this.hotelLocation,
    required this.hotelImage,
    required this.averageRating,
    required this.totalReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 74,
              height: 74,
              child: _SmartImage(
                image: hotelImage,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotelName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      '${averageRating.toStringAsFixed(1)}/5',
                      style: const TextStyle(
                        color: Color(0xFF5E7CEB),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '($totalReview ${totalReview == 1 ? 'review' : 'reviews'})',
                      style: const TextStyle(
                        color: Color(0xFF8F97A8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(
                        color: Color(0xFF8F97A8),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hotelLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8F97A8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final ReviewModel review;
  final Function(ReviewModel updatedReview)? onUpdated;

  const _ReviewCard({
    super.key,
    required this.review,
    this.onUpdated,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isSubmittingHelpful = false;

  late ReviewModel _review;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
  }

  @override
  void didUpdateWidget(covariant _ReviewCard oldWidget) {
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
        final updatedReview = _review.copyWith(
          helpfulCount: response['helpful_count'] as int,
          isHelpful: response['is_helpful'] as bool,
        );

        setState(() {
          _review = updatedReview; 
        });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
                          // FIX MINOR: warna konsisten saat helpful/tidak
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

  String _timeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'just now';
  }
}

class _AvatarImage extends StatelessWidget {
  final String? url;

  const _AvatarImage({this.url});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim();

    if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'null') {
      return _fallbackAvatar();
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _fallbackAvatar();
        },
      ),
    );
  }

  Widget _fallbackAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Color(0xFFDCE4F5),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 21,
      ),
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
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SmartImage extends StatelessWidget {
  final String? image;
  final BoxFit fit;

  const _SmartImage({
    required this.image,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return Container(
        color: const Color(0xFFDCE4F5),
        child: const Icon(
          Icons.image,
          color: Colors.white,
          size: 28,
        ),
      );
    }

    if (image!.startsWith('http')) {
      return Image.network(
        image!,
        fit: fit,
        errorBuilder: (_, __, ___) {
          return Container(
            color: const Color(0xFFDCE4F5),
            child: const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 28,
            ),
          );
        },
      );
    }

    return Image.asset(
      image!,
      fit: fit,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFDCE4F5),
          child: const Icon(
            Icons.broken_image,
            color: Colors.white,
            size: 28,
          ),
        );
      },
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
              setState(() {
                _currentIndex = index;
              });
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
