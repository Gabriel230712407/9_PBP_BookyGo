// // history_model.dart

// class HistoryModel {
//   final int id;
//   final String hotelName;
//   final String hotelAddress;
//   final String bookingCode;
//   final String imagePath;
//   final String formattedDateRange;
//   final String stayLabel;
//   final String formattedTotalPrice;
//   final bool isCompleted; // selalu true sekarang

//   HistoryModel({
//     required this.id,
//     required this.hotelName,
//     required this.hotelAddress,
//     required this.bookingCode,
//     required this.imagePath,
//     required this.formattedDateRange,
//     required this.stayLabel,
//     required this.formattedTotalPrice,
//     this.isCompleted = true, // default completed
//   });

//   factory HistoryModel.fromJson(Map<String, dynamic> json) {
//     return HistoryModel(
//       id: json['id'],
//       hotelName: json['hotel_name'],
//       hotelAddress: json['hotel_address'],
//       bookingCode: json['booking_code'],
//       imagePath: json['image_path'],
//       formattedDateRange: json['formatted_date_range'],
//       stayLabel: json['stay_label'],
//       formattedTotalPrice: json['formatted_total_price'],
//       isCompleted: true, // selalu completed
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'hotel_name': hotelName,
//       'hotel_address': hotelAddress,
//       'booking_code': bookingCode,
//       'image_path': imagePath,
//       'formatted_date_range': formattedDateRange,
//       'stay_label': stayLabel,
//       'formatted_total_price': formattedTotalPrice,
//       'status': 'completed', // untuk API
//     };
//   }
// }