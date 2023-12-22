import 'dart:async';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late App app;

  // State variables for stopwatch functionality
  bool isLap = true;
  bool isRunning = false;
  List<String> laps = [];
  DateTime? startTime;
  DateTime? lapStartTime;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Start the stopwatch
  void startStopwatch() {
    isRunning = true;
    isLap = true;
    startTime = DateTime.now();
    lapStartTime = DateTime.now();
    // Periodically update the UI to show elapsed time
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
      setState(() {});
    });
  }

  // Stop the stopwatch
  void stopStopwatch() {
    isRunning = false;
    isLap = false;
    timer?.cancel(); // Cancel the timer when stopping the stopwatch
    setState(() {});
  }

  // Reset the stopwatch
  void resetStopwatch() {
    isRunning = false;
    laps.clear();
    setState(() {});
  }

  // Record a lap in the stopwatch
  void recordLap() {
    if (isRunning) laps.add(calculateElapsedTime(lapStartTime!));
  }

  // Build a row for displaying lap information
  Widget buildLapRow(String lapText, String timeText) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lapText),
            Text(timeText),
          ],
        ),
        const Divider(
          color: Colors.white,
        ),
      ],
    );
  }

  // Format the duration as a string
  String formatDuration(Duration duration) {
    return '${(duration.inMinutes).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}.${(duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}';
  }

  // Calculate the elapsed time since a given start time
  String calculateElapsedTime(DateTime startTime) {
    Duration elapsed = DateTime.now().difference(startTime);
    return formatDuration(elapsed);
  }

  // Build the UI for displaying the stopwatch time
  Widget buildStopwatchDisplay() {
    return Container(
      height: app.appHeight(20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            isRunning ? calculateElapsedTime(startTime!) : '00:00.00',
            style: const TextStyle(
              fontSize: 40.0,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
      ),
    );
  }

  // Build the row containing buttons for lap and start/stop
  Widget buildButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircularButton(
          label: isLap ? 'Lap' : 'Reset',
          labelColor: Colors.blue,
          backgroundColor: Colors.blue,
          onPressed: isLap ? recordLap : resetStopwatch,
        ),
        CircularButton(
          label: isRunning ? 'Stop' : 'Start',
          labelColor: Colors.green,
          backgroundColor: Colors.green,
          onPressed: isRunning ? stopStopwatch : startStopwatch,
        ),
      ],
    );
  }

  // Build the rows displaying lap information
  Widget buildLapRows() {
    return SizedBox(
      height: app.appHeight(40),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: app.appHeight(5)),
        child: Column(
          children: [
            const Divider(
              color: Colors.white,
            ),
            for (int index = laps.length - 1; index > -1; index--)
              buildLapRow('Lap$index', laps[index]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    app = App(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildStopwatchDisplay(),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: app.appVerticalPadding(5),
                horizontal: app.appHorizontalPadding(10),
              ),
              color: Colors.deepPurple.withOpacity(0.1),
              child: Column(
                children: [
                  buildButtonsRow(),
                  buildLapRows(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Utility class for handling screen dimensions
class App {
  late BuildContext content;
  late double _height;
  late double _width;
  late double _heightPadding;
  late double _widthPadding;

  App(this.content) {
    MediaQueryData queryData = MediaQuery.of(content);
    _height = queryData.size.height / 100.0;
    _width = queryData.size.width / 100.0;
    _heightPadding =
        _height - ((queryData.padding.top + queryData.padding.bottom) / 100.0);
    _widthPadding =
        _width - (queryData.padding.left + queryData.padding.right) / 100.0;
  }

  double appHeight(double v) {
    return _height * v;
  }

  double appWidth(double v) {
    return _width * v;
  }

  double appVerticalPadding(double v) {
    return _heightPadding * v;
  }

  double appHorizontalPadding(double v) {
    return _widthPadding * v;
  }
}

// Utility class for circular button
class CircularButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final double size;

  const CircularButton({
    Key? key,
    this.onPressed,
    this.backgroundColor = Colors.blue,
    this.size = 56.0,
    required this.label,
    this.labelColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor.withOpacity(0.3),
          border: Border.all(
            color: backgroundColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
            ),
          ),
        ),
      ),
    );
  }
}
