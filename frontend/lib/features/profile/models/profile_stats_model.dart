class ProfileStatsModel {
  final int reviewCount;
  final int bookedCount;
  final int wishlistCount;

  ProfileStatsModel({
    required this.reviewCount,
    required this.bookedCount,
    required this.wishlistCount,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      reviewCount: json['review_count'] ?? 0,
      bookedCount: json['booked_count'] ?? 0,
      wishlistCount: json['wishlist_count'] ?? 0,
    );
  }
}