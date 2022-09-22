import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter On Steroids',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Counter On Steroids'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times: '),
            ValueListenableBuilder<int>(
              builder: (context, value, child) {
                return Stack(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: Transform(
                        transform: Matrix4.identity()..scale(1.5),
                        child: Text(
                          '$value',
                          textScaleFactor: 2,
                        ),
                      ),
                    ),
                    Text(
                      '$value',
                      textScaleFactor: 2,
                    ),
                  ],
                );
              },
              valueListenable: _counter,
            ),
          ],
        ),
      ),
      floatingActionButton: _Actions(
        plus: () => _counter.value += 1,
        minus: () => _counter.value -= 1,
      ),
    );
  }
}

class _Actions extends StatefulWidget {
  final Function() plus;
  final Function() minus;

  const _Actions({
    Key? key,
    required this.plus,
    required this.minus,
  }) : super(key: key);

  @override
  State<_Actions> createState() => __ActionsState();
}

class __ActionsState extends State<_Actions> {
  @override
  void didUpdateWidget(covariant _Actions oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _ActionButton(
          action: widget.minus,
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 4),
        _ActionButton(
          action: widget.plus,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final Function() action;
  final Icon icon;

  const _ActionButton({
    Key? key,
    required this.action,
    required this.icon,
  }) : super(key: key);

  @override
  State<_ActionButton> createState() => __ActionButtonState();
}

class __ActionButtonState extends State<_ActionButton> {
  bool heldDown = false;
  Stopwatch stopwatch = Stopwatch();
  final List<Duration> durationTillActionList = const [
    Duration(milliseconds: 100),
    // Duration(milliseconds: 75),
    Duration(milliseconds: 50),
    // Duration(milliseconds: 25),
    Duration(milliseconds: 1),
    // Duration(milliseconds: 25),
    Duration(milliseconds: 50),
    // Duration(milliseconds: 75),
    Duration(microseconds: 100),
    // Duration(microseconds: 75),
    Duration(microseconds: 50),
    // Duration(microseconds: 25),
    Duration(microseconds: 1),
  ];
  int durationTillActionListIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (details) {
        setState(() {
          heldDown = true;
        });
      },
      onLongPressStart: (details) {
        stopwatch.start();
      },
      onLongPressEnd: (details) {
        stopwatch
          ..stop()
          ..reset();
        setState(() {
          durationTillActionListIndex = 0;
          heldDown = false;
        });
      },
      onLongPress: () async {
        while (heldDown) {
          await Future.delayed(
              durationTillActionList[durationTillActionListIndex]);
          widget.action();
          final tick = stopwatch.elapsedMilliseconds / 5000;
          if (tick.round() > durationTillActionListIndex &&
              tick.round() < durationTillActionList.length) {
            setState(() {
              durationTillActionListIndex = tick.round();
            });
          }
        }
      },
      child: FloatingActionButton(
        backgroundColor: heldDown ? Colors.grey : null,
        elevation: 60,
        onPressed: () {
          widget.action();
          setState(() {
            heldDown = false;
          });
        },
        child: widget.icon,
      ),
    );
  }
}
