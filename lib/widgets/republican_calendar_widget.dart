import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';

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

  Future<void> _loadRepublicanDate() async {
    String jsonString = await rootBundle.loadString('assets/months.json');
    List<dynamic> months = jsonDecode(jsonString);
    DateTime today = DateTime.now();

    for (var month in months) {
      for (var day in month['days']) {
        if (day['gregorianEquivalent'] == '${today.day} ${_getMonthAbbreviation(today.month)}') {
          setState(() {
            republicanDate = "${day['day']} ${month['monthName']} - ${day['dedicatedToEng']}";
          });

          // Update home screen widget data
          WidgetKit.setItem('republican_date', republicanDate, 'group.com.example');
          WidgetKit.reloadAllTimelines();
          return;
        }
      }
    }
    setState(() {
      republicanDate = "Unknown Date";
    });
  }

  String _getMonthAbbreviation(int month) {
    const monthNames = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return monthNames[month - 1];
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
