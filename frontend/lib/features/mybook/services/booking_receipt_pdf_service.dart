import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/booking_model.dart';

class BookingReceiptPdfService {
  BookingReceiptPdfService._();

  static Future<Uint8List> build(BookingModel booking) async {
    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(34),
          buildBackground: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColors.white),
          ),
        ),
        build: (_) => [
          _header(booking),
          pw.SizedBox(height: 20),
          _hotelInfo(booking),
          pw.SizedBox(height: 20),
          _stayGrid(booking),
          pw.SizedBox(height: 20),
          _guestInfo(booking),
          pw.SizedBox(height: 18),
          _paymentSummary(booking),
          pw.SizedBox(height: 18),
          _paymentMethod(booking),
          pw.SizedBox(height: 22),
          _qrSection(booking),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text(
              'THANK YOU FOR YOUR BOOKING',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromInt(0xFF6D7897),
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static String fileName(BookingModel booking) {
    final code = booking.bookingCode.isEmpty ? booking.id : booking.bookingCode;
    return 'bookygo-receipt-$code.pdf';
  }

  static String receiptQrData(BookingModel booking) {
    return jsonEncode({
      'receipt': 'BookyGo Booking Receipt',
      'booking_id': booking.bookingCode,
      'hotel': booking.hotelName,
      'room': booking.roomName,
      'guest_name': booking.contactName,
      'check_in': BookingFormatters.dayMonthYear(booking.checkInDate),
      'check_out': BookingFormatters.dayMonthYear(booking.checkOutDate),
      'duration': booking.stayLabel,
      'guests': booking.guestCountLabel,
      'rooms': booking.roomCountLabel,
      'payment_method': paymentMethodName(booking),
      'total_paid': booking.formattedTotalPrice,
      'status': 'PAID',
    });
  }

  static String paymentMethodName(BookingModel booking) {
    if (booking.paymentMethod == 'ewallet') {
      return 'QRIS';
    }

    if (booking.paymentMethod == 'transfer') {
      return 'BRI Virtual Account';
    }

    return booking.paymentMethodLabel;
  }

  static pw.Widget _header(BookingModel booking) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Booking Detail',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF162551),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'ID : ${booking.bookingCode}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromInt(0xFF7E88AF),
                ),
              ),
            ],
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFEAF8F0),
            borderRadius: pw.BorderRadius.circular(14),
          ),
          child: pw.Text(
            'PAID',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF1C9A5E),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _hotelInfo(BookingModel booking) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            booking.hotelName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF162551),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            booking.roomName,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromInt(0xFF3F7BEA),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            booking.hotelAddress,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromInt(0xFF7E88AF),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _stayGrid(BookingModel booking) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFE3E8FF)),
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE3E8FF)),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              _infoBlock(
                'CHECK-IN',
                BookingFormatters.dayMonthYear(booking.checkInDate),
              ),
              _infoBlock('DURATION', booking.stayLabel, alignRight: true),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _infoBlock(
                'CHECK-OUT',
                BookingFormatters.dayMonthYear(booking.checkOutDate),
              ),
              _infoBlock('GUESTS', booking.guestCountLabel, alignRight: true),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _guestInfo(BookingModel booking) {
    return pw.Column(
      children: [
        _receiptRow('GUEST NAME', booking.contactName, labelCaps: true),
        pw.SizedBox(height: 12),
        _receiptRow('ROOM COUNT', booking.roomCountLabel, labelCaps: true),
      ],
    );
  }

  static pw.Widget _paymentSummary(BookingModel booking) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE3E8FF)),
        ),
      ),
      child: pw.Column(
        children: [
          _priceRow(
            'Subtotal',
            BookingFormatters.currency(booking.staySubtotal),
            shaded: true,
          ),
          _priceRow('Tax', BookingFormatters.currency(booking.taxAmount)),
          _priceRow(
            'Service Fee',
            BookingFormatters.currency(booking.addonsTotal),
            shaded: true,
          ),
          pw.SizedBox(height: 8),
          _priceRow('Total Paid', booking.formattedTotalPrice, strong: true),
        ],
      ),
    );
  }

  static pw.Widget _paymentMethod(BookingModel booking) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF3F5FC),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 34,
            height: 24,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E5F4)),
            ),
            child: pw.Text(
              booking.paymentMethod == 'ewallet' ? 'QR' : 'BRI',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF3F7BEA),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Paid Via',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColor.fromInt(0xFF7E88AF),
                  ),
                ),
                pw.Text(
                  paymentMethodName(booking),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF162551),
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFF36C78A),
              borderRadius: pw.BorderRadius.circular(14),
            ),
            child: pw.Text(
              'PAID',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _qrSection(BookingModel booking) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: receiptQrData(booking),
          width: 92,
          height: 92,
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Receipt QR',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF162551),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Scan this QR to show the booking receipt information.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromInt(0xFF7E88AF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoBlock(
    String label,
    String value, {
    bool alignRight = false,
  }) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: alignRight
            ? pw.CrossAxisAlignment.end
            : pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF4B5578),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF162551),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _receiptRow(
    String label,
    String value, {
    bool labelCaps = false,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: labelCaps ? 9 : 10,
              fontWeight: labelCaps ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: const PdfColor.fromInt(0xFF4B5578),
            ),
          ),
        ),
        pw.Text(
          value.isEmpty ? '-' : value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor.fromInt(0xFF162551),
          ),
        ),
      ],
    );
  }

  static pw.Widget _priceRow(
    String label,
    String value, {
    bool shaded = false,
    bool strong = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: shaded ? const PdfColor.fromInt(0xFFF0F6FF) : PdfColors.white,
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: strong ? 14 : 11,
                fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: strong
                    ? const PdfColor.fromInt(0xFF162551)
                    : const PdfColor.fromInt(0xFF7E88AF),
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: strong ? 14 : 11,
              fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: strong
                  ? const PdfColor.fromInt(0xFF213C7C)
                  : const PdfColor.fromInt(0xFF4B5578),
            ),
          ),
        ],
      ),
    );
  }
}
