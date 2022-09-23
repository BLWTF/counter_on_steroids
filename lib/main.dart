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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _textKey = GlobalKey();
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: 250,
    ),
  );

  Future<void> animateCounter() async {
    RenderBox box = _textKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position

    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned(
              top: position.dy,
              left: position.dx,
              child: child!,
            );
          },
          child: ValueListenableBuilder<int>(
            builder: (context, value, child) {
              return Opacity(
                opacity: 1 - _animationController.value,
                child: Transform.scale(
                  scale: 1 + (_animationController.value / 2),
                  child: Text(
                    '$value',
                    textScaleFactor: 2,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              );
            },
            valueListenable: _counter,
          ),
        );
      },
    );
    Overlay.of(context)!.insert(entry);
    await _animationController.forward(from: 0);
    entry.remove();
  }

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
                return Text(
                  '$value',
                  key: _textKey,
                  textScaleFactor: 2,
                );
              },
              valueListenable: _counter,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ActionButton(
            action: () => _counter.value -= 1,
            icon: const Icon(Icons.remove),
            onSpeedChange: () => animateCounter(),
          ),
          const SizedBox(width: 4),
          _ActionButton(
            action: () => _counter.value += 1,
            icon: const Icon(Icons.add),
            onSpeedChange: () => animateCounter(),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final Function() action;
  final Icon icon;
  final Function() onSpeedChange;

  const _ActionButton({
    Key? key,
    required this.action,
    required this.icon,
    required this.onSpeedChange,
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
    // Duration(microseconds: 750),
    Duration(microseconds: 500),
    // Duration(milliseconds: 250),
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
            widget.onSpeedChange();
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
