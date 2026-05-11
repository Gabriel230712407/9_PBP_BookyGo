class RoomModel {
  final String name;
  final String type;
  String? image;
  final String facility;
  final String price;

  RoomModel({
    required this.name,
    required this.type,
    this.image,
    required this.facility,
    required this.price,
  });
}
