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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final GlobalKey _textKey = GlobalKey();
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  late final AnimationController _counterAnimationController =
      AnimationController(
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
          animation: _counterAnimationController,
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
                opacity: 1 - _counterAnimationController.value,
                child: Transform.scale(
                  scale: 1 + (_counterAnimationController.value / 2),
                  child: Text(
                    '$value',
                    textScaleFactor: 3,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.w300),
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
    await _counterAnimationController.forward(from: 0);
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
            ValueListenableBuilder<int>(
              builder: (context, value, _) {
                return SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(
                    child: RepaintBoundary(
                      child: Text(
                        '$value',
                        key: _textKey,
                        textScaleFactor: 3,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
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

class __ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  bool heldDown = false;
  Stopwatch stopwatch = Stopwatch();
  late int durationTillActionMicroseconds;
  late int elapsedTimeSinceAction;
  late Duration durationTillAction;
  late final AnimationController _progressAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(
      seconds: 5,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    durationTillActionMicroseconds = 1000000;
    elapsedTimeSinceAction = 0;
    durationTillAction = Duration(microseconds: durationTillActionMicroseconds);
  }

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
        _progressAnimationController.forward(from: 0);
      },
      onLongPressEnd: (details) {
        stopwatch
          ..stop()
          ..reset();

        setState(() {
          _initTimer();
          heldDown = false;
        });

        _progressAnimationController.reset();
      },
      onLongPress: () async {
        while (heldDown) {
          widget.action();

          await Future.delayed(durationTillAction);

          final tick = stopwatch.elapsedMilliseconds / 5000;

          if (tick.round() > elapsedTimeSinceAction &&
              durationTillActionMicroseconds != 1) {
            _progressAnimationController.reset();
            widget.onSpeedChange();
            _progressAnimationController.forward(from: 0);

            setState(() {
              durationTillActionMicroseconds =
                  (durationTillActionMicroseconds / 10).round();
              durationTillAction =
                  Duration(microseconds: durationTillActionMicroseconds);
              elapsedTimeSinceAction = tick.round();
            });
          }
        }
      },
      child: Stack(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: AnimatedBuilder(
              animation: _progressAnimationController,
              builder: (context, child) => CircularProgressIndicator(
                value: _progressAnimationController.value,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 50,
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
          ),
        ],
      ),
    );
  }
}
