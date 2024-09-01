library circular_countdown_timer;

import 'dart:async';

import 'package:circular_countdown_timer/custom_timer_painter.dart';
import 'package:flutter/material.dart';

/// Create a Circular Countdown Timer.
class MyCircularCountDownTimer extends StatefulWidget {
  //######################## خصائص الواجهة
  /// Filling Color for Countdown Widget.
  final Color fillColor;

  /// Ring Color for Countdown Widget.
  final Color ringColor;

  /// Width of the Countdown Widget.
  final double width;

  /// Height of the Countdown Widget.
  final double height;

  /// Border Thickness of the Countdown Ring.
  final double strokeWidth;

  /// Begin and end contours with a flat edge and no extension.
  final StrokeCap strokeCap;

  final Widget child;

  //######################## فعاليات الواجهة
  /// This Callback will execute when the Countdown Ends.
  final VoidCallback? onComplete;

  /// This Callback will execute when the Countdown Starts.
  final VoidCallback? onStart;

  /// This Callback will execute when the Countdown Changes.
  final ValueChanged<String>? onChange;

  /// Countdown duration in Seconds.
  final int totalDuration;

  /// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
  final CountDownControllers? controller;

  const MyCircularCountDownTimer({
    required this.width,
    required this.height,
    required this.totalDuration,
    required this.fillColor,
    required this.ringColor,
    required this.child,
    this.onComplete,
    this.onStart,
    this.onChange,
    this.strokeWidth = 5.0,
    this.strokeCap = StrokeCap.butt,
    super.key,
    this.controller,
  });

  @override
  MyCircularCountDownTimerState createState() => MyCircularCountDownTimerState();
}

class MyCircularCountDownTimerState extends State<MyCircularCountDownTimer> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _countDownAnimation;
  CountDownControllers? countDownController;

  // الوقت المستخدم بداخل الحلقة
  String get time {
    String timeStamp = "";
    //القيمة الكلية * نسبة المنتهي
    int value = countDownController?.remainingSeconds ?? widget.totalDuration;
    if (countDownController?.remainingSeconds == 999) value = widget.totalDuration;
    if (value < 0) value = 0;
    timeStamp = _getTimeFormatted(value);
    String doneTime = _getTimeFormatted(countDownController?._doneTime ?? 0);

    // Show the current time in on change callback
    if (widget.onChange != null) widget.onChange!(doneTime);

    return timeStamp;
  }

  set time(String value) {
    time = value;
    setState(() {});
  }

  void _setController() {
    countDownController?._timerState = this;
    countDownController?._totalDuration = widget.totalDuration;
    countDownController?.isStarted.value = true;
    countDownController?.start();
  }

  @override
  void initState() {
    countDownController = widget.controller ?? CountDownControllers();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.totalDuration),
    );

    //######################## أجزاء ما تهمني

    _controller!.addStatusListener((AnimationStatus status) {
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
          break;
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

  void _setAnimation() {
    _controller!.reverse(from: 1);
  }

  void _setAnimationDirection() {
    _countDownAnimation = Tween<double>(begin: 0, end: 1).animate(_controller!);
  }

  void _onStart() {
    if (widget.onStart != null) widget.onStart!();
  }

  void _onComplete() {
    if (widget.onComplete != null) widget.onComplete!();
  }

  String _getTimeFormatted(int duration) {
    // For mm:ss format
    return '${(duration ~/ 60).toString().padLeft(2, '0')}:${(duration % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller!.stop();
    _controller!.dispose();
    super.dispose();
  }
}

/// Controls (i.e Start, Pause, Resume) the Countdown Timer.
class CountDownControllers {
  MyCircularCountDownTimerState? _timerState;

  ValueNotifier<bool> isStarted = ValueNotifier<bool>(false), isPaused = ValueNotifier<bool>(false);

  int? _totalDuration;
  int _doneTime = 0, remainingSeconds = 999;

  late DateTime _startTime, _endTime;
  Timer? _timer;

  /// This Method Starts the Countdown Timer
  void start() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reverse(from: 1);
      _startTime = DateTime.now();
      _endTime = _startTime.add(Duration(seconds: _totalDuration!));
      isStarted.value = true;
      calcTime();
    }
  }

  void calcTime({DateTime? startValue, DateTime? endValue}) {
    //هل في توقف ؟
    if (_timerState != null && _timerState?._controller != null && _timer != null && endValue != null && startValue != null) {
      _startTime = startValue;
      _endTime = endValue;
      isStarted.value = true;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      remainingSeconds = _endTime.difference(DateTime.now()).inSeconds;
      _doneTime = DateTime.now().difference(_startTime).inSeconds;
      if (remainingSeconds <= 0) {
        stopTime();
      }
    });
  }

  /// This Method Pauses the Countdown Timer
  void pause() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.stop(canceled: false);
      if (!isPaused.value) {
        _timer?.cancel();
      }
    }

    isPaused.value = true;
  }

  /// This Method Resumes the Countdown Timer
  void resume() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reverse(from: _timerState!._controller!.value);
      if (isPaused.value) {
        calcTime(startValue: DateTime.now().add(Duration(seconds: _doneTime)), endValue: DateTime.now().add(Duration(seconds: remainingSeconds + 1)));
      }
    }

    isPaused.value = false;
  }

  void stopTime() {
    if (_timerState != null && _timerState?._controller != null && _timer != null) {
      _timerState?._controller?.value = 0;
      _timerState?._controller?.duration = const Duration(seconds: 0);
      _timerState?.time = "0:00";
      _timerState?._controller?.stop(canceled: false);
      _timer?.cancel();
      isStarted.value = false;
    }
  }
}
