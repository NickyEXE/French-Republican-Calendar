import 'package:flutter/material.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'widgets/republican_calendar_widget.dart';
import 'decimal_time.dart';
import 'clock_painter.dart';
import 'dart:async';
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late String republicanDate = "Loading...";
  late String decimalTime = "Loading...";
  late String dedicationFr = "Loading...";
  late String dedicationEng = "Loading...";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRepublicanDate();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimer();
    } else if (state == AppLifecycleState.paused) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _loadDecimalTime();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _loadRepublicanDate() async {
    DateTime today = DateTime.now();
    RepublicanDate republicanDateObj = await RepublicanDate.fromGregorian(today);

    setState(() {
      republicanDate = "${republicanDateObj.getDayName()}, ${republicanDateObj.getDay()} ${republicanDateObj.getMonthName()} ${republicanDateObj.getYearArabic()}";
      dedicationFr = republicanDateObj.dedicatedToFr;
      dedicationEng = republicanDateObj.dedicatedToEng;
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
              const Text(
                "Today in the Republican Calendar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                republicanDate,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: RepublicanClockPainter(DecimalTime.fromStandardTime(DateTime.now())),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Current Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                decimalTime,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "The day is",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                dedicationFr,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                "Please take some time to reflect on",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                dedicationEng,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}