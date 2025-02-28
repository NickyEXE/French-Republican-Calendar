import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'widgets/republican_calendar_widget.dart';
import 'decimal_time.dart';
import 'clock_painter.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'settings_page.dart';

void main() {
  runApp(const MyApp());

  if (Platform.isIOS) {
    WidgetKit.setItem('republican_date', 'Loading...', 'group.com.example');
    WidgetKit.reloadAllTimelines();
  }

  const MethodChannel('com.example.republican_calendar/republican_date').setMethodCallHandler((call) async {
    if (call.method == 'getRepublicanDate') {
      DateTime today = DateTime.now();
      RepublicanDate republicanDateObj = await RepublicanDate.fromGregorian(today);
      String republicanDate = "${republicanDateObj.dedicatedToFr} - ${republicanDateObj.getDay()} ${republicanDateObj.getMonthName()} - Year ${republicanDateObj.getYearArabic()}";
      return republicanDate;
    }
    return null;
  });
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
  late String randomQuote = "Loading...";
  late String quoteAuthor = "Loading...";
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

    _loadRandomQuote(republicanDateObj.getDay(), republicanDateObj.getMonthName());

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

  void _loadRandomQuote(int day, String month) async {
    String jsonString = await rootBundle.loadString('assets/quotes.json');
    List<dynamic> quotes = json.decode(jsonString);
    int seed = day + month.hashCode;
    Random random = Random(seed);
    int randomIndex = random.nextInt(quotes.length);
    Map<String, dynamic> randomQuoteObj = quotes[randomIndex];

    setState(() {
      randomQuote = randomQuoteObj['quote'];
      quoteAuthor = randomQuoteObj['author'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
                ),
              ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Today in the Republican Calendar",
                      style: TextStyle(fontFamily: "Cinzel", fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      republicanDate,
                      style: const TextStyle(fontFamily: "Cinzel", fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: RepublicanClockPainter(DecimalTime.fromStandardTime(DateTime.now())),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      decimalTime,
                      style: const TextStyle(fontFamily: "Cinzel", fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "The day is",
                      style: const TextStyle(fontFamily: "Cinzel", fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dedicationFr,
                      style: const TextStyle(fontFamily: "Cinzel", fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Please take some time to reflect on",
                      style: const TextStyle(fontFamily: "Cinzel", fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dedicationEng,
                      style: const TextStyle(fontFamily: "Cinzel", fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        randomQuote,
                        style: const TextStyle(fontFamily: "Cinzel", fontSize: 16, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "- $quoteAuthor",
                      style: const TextStyle(fontFamily: "Cinzel", fontSize: 16, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}