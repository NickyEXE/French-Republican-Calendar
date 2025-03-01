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
    WidgetKit.setItem('republican_date', 'Loading...', 'group.french.republican');
    WidgetKit.reloadAllTimelines();
  }

  const MethodChannel('french.republican.republican_calendar/republican_date').setMethodCallHandler((call) async {
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
  double _sizeForQuote = 0.0;

  final GlobalKey _appBarKey = GlobalKey();
  final GlobalKey _clockKey = GlobalKey();
  final GlobalKey _republicanDateKey = GlobalKey();
  final GlobalKey _decimalTimeKey = GlobalKey();
  final GlobalKey _dedicationFrKey = GlobalKey();
  final GlobalKey _dedicationEngKey = GlobalKey();
  final GlobalKey _dividerKey = GlobalKey();

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
      WidgetKit.setItem('republican_date', republicanDate, 'group.french.republican');
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
    return MaterialApp(
      home: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                key: _appBarKey,
                title: Text(
                  "Today in the Republican Calendar",
                  style: TextStyle(fontFamily: "Cinzel", fontSize: MediaQuery.of(context).size.height > 700 ? 16.0 : 12.0),
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
              body: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxHeight == 0) {
                    return Container(); // Return an empty container if height is 0
                  }

                  bool bigScreen = constraints.maxHeight > 700;
                  double headingSize = bigScreen ? 20.0 : 14.0;
                  double textSize = bigScreen ? 18.0 : 12.0;
                  double quoteSize = bigScreen ? 14.0 : 12.0;
                  double bigDividerHeight = bigScreen ? 20 : 6;
                  double smallDividerHeight = bigScreen ? 10 : 6;
                  double clockSize = bigScreen ? 200 : 140;

                  // all of this logic is to calculate the available space for the quote
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    double appBarHeight = _appBarKey.currentContext?.size?.height ?? 0;
                    double clockHeight = _clockKey.currentContext?.size?.height ?? 0;
                    double republicanDateHeight = _republicanDateKey.currentContext?.size?.height ?? 0;
                    double decimalTimeHeight = _decimalTimeKey.currentContext?.size?.height ?? 0;
                    double dedicationFrHeight = _dedicationFrKey.currentContext?.size?.height ?? 0;
                    double dedicationEngHeight = _dedicationEngKey.currentContext?.size?.height ?? 0;
                    double dividerHeight = _dividerKey.currentContext?.size?.height ?? 0;

                    double totalHeight = appBarHeight +
                        clockHeight +
                        republicanDateHeight +
                        decimalTimeHeight +
                        dedicationFrHeight +
                        dedicationEngHeight +
                        dividerHeight +
                        (4 * smallDividerHeight) +
                        (2 * bigDividerHeight);

                    double sizeForQuote = constraints.maxHeight - totalHeight;

                    setState(() {
                      _sizeForQuote = sizeForQuote;
                    });
                  });

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          republicanDate,
                          key: _republicanDateKey,
                          style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: smallDividerHeight),
                        SizedBox(
                          key: _clockKey,
                          width: clockSize,
                          height: clockSize,
                          child: CustomPaint(
                            painter: RepublicanClockPainter(DecimalTime.fromStandardTime(DateTime.now())),
                          ),
                        ),
                        SizedBox(height: smallDividerHeight),
                        Text(
                          decimalTime,
                          key: _decimalTimeKey,
                          style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: bigDividerHeight),
                        Text(
                          "The day is",
                          style: TextStyle(fontFamily: "Cinzel", fontSize: textSize),
                        ),
                        SizedBox(height: smallDividerHeight),
                        Text(
                          dedicationFr,
                          key: _dedicationFrKey,
                          style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: bigDividerHeight),
                        Text(
                          "Please take some time to reflect on",
                          style: TextStyle(fontFamily: "Cinzel", fontSize: textSize),
                        ),
                        SizedBox(height: smallDividerHeight),
                        Text(
                          dedicationEng,
                          key: _dedicationEngKey,
                          style: TextStyle(fontFamily: "Cinzel", fontSize: headingSize, fontWeight: FontWeight.bold),
                        ),
                        Divider(
                          key: _dividerKey,
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
                                height: _sizeForQuote,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(
                                        randomQuote,
                                        style: TextStyle(fontFamily: "Cinzel", fontSize: quoteSize, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: smallDividerHeight),
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
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}