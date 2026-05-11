class HotelModel {
  final String name;
  final String location;
  final String rating;
  final String review;
  final String? image;
  final String facilities;
  final String description;

  HotelModel({
    required this.name,
    required this.location,
    required this.rating,
    required this.review,
    this.image,
    required this.facilities,
    required this.description,
  });
}
