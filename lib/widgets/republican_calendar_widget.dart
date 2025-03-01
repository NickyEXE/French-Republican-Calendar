import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

// This code lovingly ripped and converted to Dart from: https://github.com/dekadans/repcal/blob/main/repcal/RepublicanDate.py
class RepublicanCalendarWidget extends StatefulWidget {
  const RepublicanCalendarWidget({Key? key}) : super(key: key);

  @override
  _RepublicanCalendarWidgetState createState() => _RepublicanCalendarWidgetState();
}

class _RepublicanCalendarWidgetState extends State<RepublicanCalendarWidget> {
  String republicanDate = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadRepublicanDate();
  }

  void _loadRepublicanDate() async {
    DateTime today = DateTime.now();
    RepublicanDate republicanDateObj = await RepublicanDate.fromGregorian(today);

    setState(() {
      republicanDate = "${republicanDateObj.getDayName()}, ${republicanDateObj.getDay()} ${republicanDateObj.getMonthName()} ${republicanDateObj.getYearArabic()}";
    });

    // Update home screen widget data
    WidgetKit.setItem('republican_date', republicanDate, 'group.french.republican');
    WidgetKit.reloadAllTimelines();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        republicanDate,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RepublicanDate {
  static const List<String> months = [
    'Vendémiaire', 'Brumaire', 'Frimaire', 'Nivôse', 'Pluviôse', 'Ventôse',
    'Germinal', 'Floréal', 'Prairial', 'Messidor', 'Thermidor', 'Fructidor',
    'Sansculottides'
  ];

  static const List<String> days = [
    'Primidi', 'Duodi', 'Tridi', 'Quartidi', 'Quintidi',
    'Sextidi', 'Septidi', 'Octidi', 'Nonidi', 'Décadi'
  ];

  static Map<String, Map<String, String>> dedications = {};

  final int year;
  final int monthIndex;
  final int monthDayIndex;
  final int weekDayIndex;
  final String dedicatedToFr;
  final String dedicatedToEng;

  RepublicanDate(this.year, this.monthIndex, this.monthDayIndex, this.dedicatedToFr, this.dedicatedToEng)
      : weekDayIndex = monthDayIndex % 10;

  String getYearArabic() => year.toString();

  String getMonthName() => months[monthIndex];

  String getDayName() => days[weekDayIndex];

  int getDay() => monthDayIndex + 1;

  // yanked these bad boys from Wikipedia
  static Future<void> loadDedications() async {
    if (dedications.isEmpty) {
      String jsonString = await rootBundle.loadString('assets/dedications.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      dedications = jsonData.map((key, value) => MapEntry(key, Map<String, String>.from(value as Map)));
    }
  }

  static Future<RepublicanDate> fromGregorian(DateTime dateToConvert) async {
    await loadDedications();

    DateTime start = DateTime(1792, 9, 22);

    if (dateToConvert.isBefore(start)) {
      throw ArgumentError('Provided date is before the adoption of the calendar');
    }

    int dayDiff = dateToConvert.difference(start).inDays + 1;

    int year = 1;
    int startDay = 1;

    while (true) {
      int endDay = startDay + (isLeapYear(year) ? 365 : 364);

      if (endDay >= dayDiff) {
        break;
      }

      year += 1;
      startDay = endDay + 1;
    }

    int dayInYear = dayDiff - startDay;

    int month = dayInYear ~/ 30;
    int dayInMonth = dayInYear % 30;

    String key = "${dayInMonth + 1}_${months[month]}";
    Map<String, String> dedication = dedications[key] ?? {"fr": "Unknown", "eng": "Unknown"};

    return RepublicanDate(year, month, dayInMonth, dedication["fr"]!, dedication["eng"]!);
  }

  static bool isLeapYear(int year) {
    if (year < 1) {
      throw ArgumentError('Year is less than one');
    }

    List<int> firstLeapYears = [3, 7, 11, 15, 20];
    if (year <= firstLeapYears.last) {
      return firstLeapYears.contains(year);
    }

    if (year % 4 == 0) {
      if (year % 100 == 0) {
        if (year % 400 == 0) {
          return true;
        } else {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}
