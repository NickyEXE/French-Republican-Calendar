import 'package:intl/intl.dart';
import 'dart:math';

class DecimalTime {
  final int hour;
  final int minute;
  final int second;
  final String decimal;

  DecimalTime(this.hour, this.minute, this.second) : decimal = _makeDecimalValue(hour, minute, second);

  static String _makeDecimalValue(int hour, int minute, int second) {
    if ([hour, minute, second].reduce(max) == 0) {
      return '0';
    }

    String h = hour.toString();
    String m = minute > 0 ? minute.toString().padLeft(2, '0') : '';
    String s = second > 0 ? second.toString().padLeft(2, '0') : '';
    return '0.$h$m$s'.replaceAll(RegExp(r'0+$'), '');
  }

  @override
  String toString() {
    return '$hour:$minute:$second ($decimal)';
  }

  static DecimalTime fromStandardTime(DateTime standardTime) {
    DateTime midnight = DateTime(standardTime.year, standardTime.month, standardTime.day);
    int standardSeconds = standardTime.difference(midnight).inSeconds;

    double secondRatio = (100 * 100 * 10) / (60 * 60 * 24);
    int decimalSeconds = (standardSeconds * secondRatio).floor();

    int secondsPerHour = 100 * 100;
    int secondsPerMinute = 100;

    int hour = decimalSeconds ~/ secondsPerHour;
    decimalSeconds -= hour * secondsPerHour;

    int minute = decimalSeconds ~/ secondsPerMinute;
    decimalSeconds -= minute * secondsPerMinute;

    return DecimalTime(hour, minute, decimalSeconds);
  }
}