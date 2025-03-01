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
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRepublicanDate();
    _startTimer();
    _scheduleMidnightUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _midnightTimer?.cancel();
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

  void _scheduleMidnightUpdate() {
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day + 1);
    Duration timeUntilMidnight = midnight.difference(now);

    _midnightTimer = Timer(timeUntilMidnight, () {
      _loadRepublicanDate();
      _scheduleMidnightUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool bigScreen = MediaQuery.of(context).size.height > 700;
    double headingSize = bigScreen ? 20.0 : 14.0;
    double textSize = bigScreen ? 18.0 : 12.0;
    double quoteSize = bigScreen ? 14.0 : 12.0;
    SizedBox bigDivider = bigScreen ? SizedBox(height: 20) : SizedBox(height: 6);
    SizedBox smallDivider = bigScreen ? SizedBox(height: 10) : SizedBox(height: 6);
    double clockSize = bigScreen ? 200 : 140;
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                title: Text(
                      "Today in the Republican Calendar",
                      style: TextStyle(fontFamily: "Cinzel", fontSize: bigScreen ? 16.0 : 12.0),
                ),
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
                    Text(
                      republicanDate,
                      style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                    ),
                    smallDivider,
                    SizedBox(
                      width: clockSize,
                      height: clockSize,
                      child: CustomPaint(
                        painter: RepublicanClockPainter(DecimalTime.fromStandardTime(DateTime.now())),
                      ),
                    ),
                    smallDivider,
                    Text(
                      decimalTime,
                      style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                    ),
                    bigDivider,
                    Text(
                      "The day is",
                      style: TextStyle(fontFamily: "Cinzel", fontSize: textSize),
                    ),
                    smallDivider,
                    Text(
                      dedicationFr,
                      style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                    ),
                    bigDivider,
                    Text(
                      "Please take some time to reflect on",
                      style: TextStyle(fontFamily: "Cinzel", fontSize: textSize),
                    ),
                    smallDivider,
                    Text(
                      dedicationEng,
                      style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      height: 20,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            height: bigScreen ? 200 : 150,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    randomQuote,
                                    style: TextStyle(fontFamily: "Cinzel", fontSize: quoteSize, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.center,
                                  ),
                                  smallDivider,
                                  Text(
                                    "- $quoteAuthor",
                                    style: TextStyle(fontFamily: "Cinzel", fontSize: quoteSize, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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