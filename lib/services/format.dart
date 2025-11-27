import 'package:intl/intl.dart';

class FormatHelper {
  static String price(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',        // tanpa simbol
      decimalDigits: 0,  // ga ada koma belakang
    );
    return formatter.format(value);
  }
}