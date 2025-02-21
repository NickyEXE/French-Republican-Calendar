import 'package:flutter/material.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'widgets/republican_calendar_widget.dart';
import 'decimal_time.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());

  if (Platform.isIOS) {
    WidgetKit.setItem('republican_date', 'Loading...', 'group.com.example');
    WidgetKit.reloadAllTimelines();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String republicanDate = "Loading...";
  late String decimalTime = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadRepublicanDate();
    _loadDecimalTime();
  }

  void _loadRepublicanDate() {
    DateTime today = DateTime.now();
    RepublicanDate republicanDateObj = RepublicanDate.fromGregorian(today);

    setState(() {
      republicanDate = "${republicanDateObj.getDayName()}, ${republicanDateObj.getDay()} ${republicanDateObj.getMonthName()} ${republicanDateObj.getYearArabic()}";
    });

    // Update home screen widget data only on iOS
    if (Platform.isIOS) {
      WidgetKit.setItem('republican_date', republicanDate, 'group.com.example');
      WidgetKit.reloadAllTimelines();
    }
  }

  void _loadDecimalTime() {
    DateTime now = DateTime.now();
    DecimalTime decimalTimeObj = DecimalTime.fromStandardTime(now);

    setState(() {
      decimalTime = decimalTimeObj.toString();
    });
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
              const SizedBox(height: 10),
              const Text(
                "Today in the Republican Calendar:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                republicanDate,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Current French Revolutionary Time:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                decimalTime,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}