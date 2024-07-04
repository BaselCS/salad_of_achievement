library circular_countdown_timer;

import 'dart:developer';

import 'package:circular_countdown_timer/custom_timer_painter.dart';
import 'package:flutter/material.dart';
import 'package:salad_of_achievement/Pages/active_session.dart';

/// Create a Circular Countdown Timer.
class MyCircularCountDownTimer extends StatefulWidget {
  /// Filling Color for Countdown Widget.
  final Color fillColor;

  /// Ring Color for Countdown Widget.
  final Color ringColor;

  /// This Callback will execute when the Countdown Ends.
  final VoidCallback? onComplete;

  /// This Callback will execute when the Countdown Starts.
  final VoidCallback? onStart;

  /// This Callback will execute when the Countdown Changes.
  final ValueChanged<String>? onChange;

  /// Countdown duration in Seconds.
  final int duration;

  /// Countdown initial elapsed Duration in Seconds.
  final int initialDuration;

  /// Width of the Countdown Widget.
  final double width;

  /// Height of the Countdown Widget.
  final double height;

  /// Border Thickness of the Countdown Ring.
  final double strokeWidth;

  /// Begin and end contours with a flat edge and no extension.
  final StrokeCap strokeCap;

  /// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
  final CountDownCcontrollers? controller;

  final Widget child;

  const MyCircularCountDownTimer({
    required this.width,
    required this.height,
    required this.duration,
    required this.fillColor,
    required this.ringColor,
    required this.child,
    this.initialDuration = 0,
    this.onComplete,
    this.onStart,
    this.onChange,
    this.strokeWidth = 5.0,
    this.strokeCap = StrokeCap.butt,
    super.key,
    this.controller,
  }) : assert(initialDuration <= duration);

  @override
  MyCircularCountDownTimerState createState() => MyCircularCountDownTimerState();
}

class MyCircularCountDownTimerState extends State<MyCircularCountDownTimer> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _countDownAnimation;
  CountDownCcontrollers? countDownController;

  String get time {
    String timeStamp = "";
    // If the timer is not started, then show the initial duration
    if (!countDownController!.isStarted.value) {
      timeStamp = _getTimeFormatted(Duration(seconds: widget.duration));      
    } else {
      // If the timer is started, then show the current time
      Duration? duration = _controller!.duration! * _controller!.value;
      timeStamp = _getTimeFormatted(duration);
    }
    // Show the current time in on change callback
    if (widget.onChange != null) widget.onChange!(timeStamp);

    return timeStamp;
  }

  void _setAnimation() {
    _controller!.reverse(from: 1);
  }

  void _setAnimationDirection() {
    _countDownAnimation = Tween<double>(begin: 0, end: 1).animate(_controller!);
  }

  void _setController() {
    countDownController?._timerState = this;
    countDownController?._initialDuration = widget.initialDuration;
    countDownController?._duration = widget.duration;
    // countDownController?.isStarted.value = widget.autoStart;
    countDownController?.isStarted.value = true;

    if (widget.initialDuration > 0) {
      _controller?.value = 1 - (widget.initialDuration / widget.duration);

      countDownController?.start();
    }
  }

  String _getTimeFormatted(Duration duration) {
    // For mm:ss format
    return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void _onStart() {
    if (widget.onStart != null) widget.onStart!();
  }

  void _onComplete() {
    if (widget.onComplete != null) widget.onComplete!();
  }

  @override
  void initState() {
    countDownController = widget.controller ?? CountDownCcontrollers();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _controller!.addStatusListener((status) {
      switch (status) {
        // بدأ الوقت ولكن بالعكس
        case AnimationStatus.reverse:
          _onStart();
          break;
        // انتهى الوقت
        case AnimationStatus.dismissed:
          _onComplete();
          break;
        default:
      }
    });

    _setAnimation();
    _setAnimationDirection();
    _setController();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            return Align(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CustomTimerPainter(
                          animation: _countDownAnimation ?? _controller,
                          fillColor: widget.fillColor,
                          ringColor: widget.ringColor,
                          strokeWidth: widget.strokeWidth,
                          strokeCap: widget.strokeCap,
                        ),
                      ),
                    ),
                    Align(
                        alignment: FractionalOffset.center,
                        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                          SizedBox(width: widget.width / 2, child: widget.child),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              width: widget.width / 2,
                              child: Center(
                                  child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(time, style: Theme.of(context).textTheme.displayMedium!.copyWith(color: widget.fillColor)))))
                        ]))
                  ],
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    _controller!.stop();
    _controller!.dispose();
    super.dispose();
  }
}

/// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
class CountDownCcontrollers {
  MyCircularCountDownTimerState? _timerState;

  ValueNotifier<bool> isStarted = ValueNotifier<bool>(false),
      isPaused = ValueNotifier<bool>(false),
      isResumed = ValueNotifier<bool>(false),
      isRestarted = ValueNotifier<bool>(false);
  int? _initialDuration, _duration;

  /// This Method Starts the Countdown Timer
  void start() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reverse(from: _initialDuration == 0 ? 1 : 1 - (_initialDuration! / _duration!));

      isStarted.value = true;
      isPaused.value = false;
      isResumed.value = false;
      isRestarted.value = false;
      inform += "${DateTime.now()}  - تم بدء الوقت\n";
    }
  }

  /// This Method Pauses the Countdown Timer
  void pause() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.stop(canceled: false);
      isPaused.value = true;
      isRestarted.value = false;
      isResumed.value = false;
      inform += "${DateTime.now()}  - تم إيقاف الوقت\n";
    }
  }

  /// This Method Resumes the Countdown Timer
  void resume() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reverse(from: _timerState!._controller!.value);

      isResumed.value = true;
      isRestarted.value = false;
      isPaused.value = false;
      inform += "${DateTime.now()}  - تم استئناف الوقت\n";
    }
  }

  /// This Method Restarts the Countdown Timer,
  /// Here optional int parameter **duration** is the updated duration for countdown timer

  void restart({int? duration}) {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller!.duration = Duration(seconds: duration ?? _timerState!._controller!.duration!.inSeconds);
      _timerState?._controller?.reverse(from: 1);
      isStarted.value = true;
      isRestarted.value = true;
      isPaused.value = false;
      isResumed.value = false;
      inform += "${DateTime.now()} - تم إعادة الوقت\n";
    }
  }

  void correctTime(int remainingTime) {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reverse(from: remainingTime / controller._duration!);
      _timerState?._controller!.duration = Duration(seconds: remainingTime);

      log("تم تصحيح الوقت ليصبح $remainingTime أي ${remainingTime % 60} دقيقة و ${remainingTime ~/ 60} ثانية");
      inform += "${DateTime.now()} - تم تصحيح الوقت ليصبح $remainingTime أي ${remainingTime % 60} دقيقة و ${remainingTime ~/ 60} ثانية\n";
    }
  }

  /// This Method resets the Countdown Timer
  void reset() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reset();
      isStarted.value = true;
      isRestarted.value = false;
      isPaused.value = false;
      isResumed.value = false;
      inform += "${DateTime.now()} - تم إعادة الوقت\n";
    }
  }

  /// This Method returns the **Current Time** of Countdown Timer i.e
  /// Time Used in terms of **Forward Countdown** and Time Left in terms of **Reverse Countdown**

  String? getTime() {
    if (_timerState != null && _timerState?._controller != null) {
      return _timerState?._getTimeFormatted(_timerState!._controller!.duration! * _timerState!._controller!.value);
    }
    return "";
  }
}
