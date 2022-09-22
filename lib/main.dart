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
  final Widget goodJob = const Text('Good Job!');
  bool heldDownPlus = false;
  bool heldDownMinus = false;

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
                  textScaleFactor: 2,
                );
              },
              valueListenable: _counter,
            ),
          ],
        ),
      ),
      floatingActionButton: _Actions(
        heldDownPlus: heldDownPlus,
        heldDownMinus: heldDownMinus,
        plus: () => _counter.value += 1,
        minus: () => _counter.value -= 1,
        startHoldPlus: () {
          setState(() {
            heldDownPlus = true;
          });
        },
        endHoldPlus: () {
          setState(() {
            heldDownPlus = false;
          });
        },
        startHoldMinus: () {
          setState(() {
            heldDownMinus = true;
          });
        },
        endHoldMinus: () {
          setState(() {
            heldDownMinus = false;
          });
        },
      ),
    );
  }
}

class _Actions extends StatefulWidget {
  final bool heldDownPlus;
  final bool heldDownMinus;
  final Function() plus;
  final Function() startHoldPlus;
  final Function() endHoldPlus;
  final Function() minus;
  final Function() startHoldMinus;
  final Function() endHoldMinus;

  const _Actions({
    Key? key,
    required this.heldDownPlus,
    required this.heldDownMinus,
    required this.plus,
    required this.startHoldPlus,
    required this.endHoldPlus,
    required this.minus,
    required this.startHoldMinus,
    required this.endHoldMinus,
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
          onTap: widget.minus,
          onHoldDownStart: widget.startHoldMinus,
          onHoldDownEnd: widget.endHoldMinus,
          icon: const Icon(Icons.remove),
          heldDown: widget.heldDownMinus,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          onTap: widget.plus,
          onHoldDownStart: widget.startHoldPlus,
          onHoldDownEnd: widget.endHoldPlus,
          icon: const Icon(Icons.add),
          heldDown: widget.heldDownPlus,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final Function() onTap;
  final Function() onHoldDownStart;
  final Function() onHoldDownEnd;
  final bool heldDown;
  final Icon icon;

  const _ActionButton({
    Key? key,
    required this.onTap,
    required this.onHoldDownStart,
    required this.onHoldDownEnd,
    required this.heldDown,
    required this.icon,
  }) : super(key: key);

  @override
  State<_ActionButton> createState() => __ActionButtonState();
}

class __ActionButtonState extends State<_ActionButton> {
  Stopwatch stopwatch = Stopwatch();
  Duration durationTillAction = const Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (details) {
        widget.onHoldDownStart();
      },
      onLongPressStart: (details) {
        stopwatch.start();
      },
      onLongPressEnd: (details) {
        widget.onHoldDownEnd();
        stopwatch
          ..stop()
          ..reset();
      },
      onLongPress: () async {
        while (widget.heldDown) {
          await Future.delayed(durationTillAction);
          widget.onTap();
        }
      },
      child: FloatingActionButton(
        backgroundColor: widget.heldDown ? Colors.grey : null,
        elevation: 60,
        onPressed: () {
          widget.onTap();
          widget.onHoldDownEnd();
        },
        child: widget.icon,
      ),
    );
  }
}
