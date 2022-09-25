import 'package:flutter/material.dart';

import 'main.dart' show CounterAction;

class ActionButton extends StatefulWidget {
  final Function() action;
  final CounterAction actionType;
  final Function() onSpeedChange;
  final bool isInAction;
  final Function() onActionEnd;

  const ActionButton({
    Key? key,
    required this.action,
    required this.onSpeedChange,
    required this.actionType,
    required this.isInAction,
    required this.onActionEnd,
  }) : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  bool isInAction = false;
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

  @override
  void didUpdateWidget(covariant ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.isInAction) {
      endAction();
    }
  }

  void _initTimer() {
    durationTillActionMicroseconds = 1000000;
    elapsedTimeSinceAction = 0;
    durationTillAction = Duration(microseconds: durationTillActionMicroseconds);
  }

  Future<void> onAction() async {
    setState(() {
      isInAction = true;
    });
    _progressAnimationController.forward(from: 0);
    stopwatch.start();

    while (isInAction) {
      widget.action();

      await Future.delayed(durationTillAction);

      final tick = stopwatch.elapsedMilliseconds / 5000;

      if (tick.floor() > elapsedTimeSinceAction &&
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
  }

  void endAction() {
    stopwatch
      ..stop()
      ..reset();

    setState(() {
      _initTimer();
      isInAction = false;
    });

    _progressAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressEnd: (details) {
        endAction();
      },
      onLongPress: () async {
        await onAction();
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
            child: Draggable<CounterAction>(
              onDragStarted: () {
                setState(() {
                  isInAction = true;
                });
              },
              onDragEnd: (_) {
                setState(() {
                  isInAction = false;
                });
              },
              onDragCompleted: () async {
                setState(() {
                  isInAction = true;
                });
                await onAction();
              },
              data: widget.actionType,
              feedback: SizedBox(
                height: 30,
                width: 30,
                child: FloatingActionButton(
                  backgroundColor: Colors.grey,
                  elevation: 0,
                  onPressed: () {},
                  child: widget.actionType.icon,
                ),
              ),
              child: FloatingActionButton(
                backgroundColor: isInAction ? Colors.grey : null,
                elevation: 10,
                onPressed: () {
                  widget.action();
                  if (isInAction) {
                    widget.onActionEnd();
                    setState(() {
                      isInAction = false;
                    });
                  }
                },
                child: widget.actionType.icon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
