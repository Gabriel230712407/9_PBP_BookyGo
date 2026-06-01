import 'package:flutter/material.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _reviewResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get reviewResponse => _reviewResponse;

  Future<bool> createReview(
    Map<String, dynamic> data,
    List<String> photos,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _reviewService.createReview(data, photos);
      _reviewResponse = result;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateReview(
    int reviewId,
    Map<String, dynamic> data,
    List<String> photos,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _reviewService.updateReview(
        reviewId,
        data,
        photos,
      );

      _reviewResponse = result;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> deleteReview(int reviewId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _reviewService.deleteReview(reviewId);
      _setLoading(false);
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}