import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'widgets/republican_calendar_widget.dart';

void main() {
  runApp(const MyApp());
  WidgetKit.setItem('republican_date', 'Loading...', 'group.com.example');
  WidgetKit.reloadAllTimelines();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String republicanDate = "Loading...";

  @override
  void initState() {
    super.initState();
    loadRepublicanDate();
  }

  Future<void> loadRepublicanDate() async {
    String jsonString = await rootBundle.loadString('assets/months.json');
    List<dynamic> months = jsonDecode(jsonString);
    DateTime today = DateTime.now();

    for (var month in months) {
      for (var day in month['days']) {
        if (day['gregorianEquivalent'] == '${today.day} ${_getMonthAbbreviation(today.month)}') {
          setState(() {
            republicanDate = "${day['day']} ${month['monthName']} - ${day['dedicatedToEng']}";
          });
          return;
        }
      }
    }
    setState(() {
      republicanDate = "Date Not Found";
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("French Republican Calendar")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Today in the Republican Calendar:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                republicanDate,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
