import 'dart:async';

import 'package:flutter/material.dart';

import 'action_button.dart';

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
  late final Map<CounterAction, Function(int)> actions = {
    CounterAction.minus: (number) => () => _counter.value -= number,
    CounterAction.plus: (number) => () => _counter.value += number,
  };
  CounterAction? fixedAction;

  Future<void> animateCounter() async {
    RenderBox box = _textKey.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    final AnimationController counterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 250,
      ),
    );
    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: counterAnimationController,
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
                opacity: 1 - counterAnimationController.value,
                child: Transform.scale(
                  scale: 1 + (counterAnimationController.value / 2),
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
    await counterAnimationController.forward(from: 0);
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
                return DragTarget<CounterAction>(
                  builder: (context, candidateData, rejectedData) => SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RepaintBoundary(
                            child: Text(
                              '$value',
                              key: _textKey,
                              textScaleFactor: 3,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: fixedAction != null ? 1 : 0,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: FloatingActionButton(
                                backgroundColor: Colors.grey,
                                elevation: 0,
                                onPressed: () {},
                                child: fixedAction?.icon,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onAccept: (action) {
                    setState(() {
                      fixedAction = action;
                    });
                  },
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
          ActionButton(
            action: actions[CounterAction.minus]!(1),
            actionType: CounterAction.minus,
            onSpeedChange: () => animateCounter(),
            isInAction: fixedAction == CounterAction.minus,
            onActionEnd: () => setState(() => fixedAction = null),
          ),
          const SizedBox(width: 4),
          ActionButton(
            action: actions[CounterAction.plus]!(1),
            actionType: CounterAction.plus,
            onSpeedChange: () => animateCounter(),
            isInAction: fixedAction == CounterAction.plus,
            onActionEnd: () => setState(() => fixedAction = null),
          ),
        ],
      ),
    );
  }
}

enum CounterAction {
  plus,
  minus;

  Icon get icon {
    switch (this) {
      case CounterAction.plus:
        return const Icon(Icons.add);
      case CounterAction.minus:
        return const Icon(Icons.remove);
    }
  }
}
