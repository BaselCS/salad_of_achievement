import 'package:circular_countdown_timer/custom_timer_painter.dart';
import 'package:flutter/material.dart';
import 'package:salad_of_achievement/logical/app_logger.dart';
import 'package:salad_of_achievement/logical/notification.dart';
import 'package:salad_of_achievement/utilities/const.dart';

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

  /// Time acceleration factor used for testing.
  final int timeScale;

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
  final CountDownControllers? controller;

  final Widget child;

  const MyCircularCountDownTimer({
    required this.width,
    required this.height,
    required this.duration,
    required this.fillColor,
    required this.ringColor,
    required this.child,
    this.timeScale = kTimeAccelerationFactor,
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
  MyCircularCountDownTimerState createState() =>
      MyCircularCountDownTimerState();
}

class MyCircularCountDownTimerState extends State<MyCircularCountDownTimer>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _countDownAnimation;
  CountDownControllers? countDownController;
  bool _hasStarted = false;

  int get _scaledDurationSeconds {
    if (widget.timeScale <= 1) {
      return widget.duration;
    }
    return widget.duration <= 0
        ? 0
        : (widget.duration / widget.timeScale).ceil();
  }

  String get time {
    String timeStamp = "";
    // If the timer is not started, then show the initial duration
    if (!countDownController!.isStarted.value) {
      timeStamp = _getTimeFormatted(Duration(seconds: widget.duration));
    } else {
      // If the timer is started, then show the current time
      Duration? duration = _controller!.duration! * _controller!.value;
      timeStamp = _getTimeFormatted(duration);
      if (widget.timeScale > 1) {
        timeStamp = _getTimeFormatted(
          Duration(
            milliseconds: (duration.inMilliseconds * widget.timeScale).round(),
          ),
        );
      }
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
    countDownController?._timeScale = widget.timeScale;
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
    countDownController = widget.controller ?? CountDownControllers();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _scaledDurationSeconds),
    );

    _controller!.addStatusListener((status) {
      switch (status) {
        // بدأ الوقت ولكن بالعكس
        case AnimationStatus.reverse:
          if (!_hasStarted) {
            _hasStarted = true;
            _onStart();
          }
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: widget.width / 2, child: widget.child),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black..withAlpha(127),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          width: widget.width / 2,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                time,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(color: widget.fillColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
class CountDownControllers {
  MyCircularCountDownTimerState? _timerState;

  ValueNotifier<bool> isStarted = ValueNotifier<bool>(false),
      isPaused = ValueNotifier<bool>(false),
      isResumed = ValueNotifier<bool>(false),
      isRestarted = ValueNotifier<bool>(false);
  int? _initialDuration, _duration;
  int _timeScale = 1;

  /// This Method Starts the Countdown Timer
  void start() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reverse(
        from: _initialDuration == 0 ? 1 : 1 - (_initialDuration! / _duration!),
      );

      isStarted.value = true;
      isPaused.value = false;
      isResumed.value = false;
      isRestarted.value = false;
    }
  }

  /// This Method Pauses the Countdown Timer
  void pause() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.stop(canceled: false);
      isPaused.value = true;
      isRestarted.value = false;
      isResumed.value = false;
    }
  }

  /// This Method Resumes the Countdown Timer
  void resume() {
    if (_timerState != null && _timerState?._controller != null) {
      _timerState?._controller?.reverse(from: _timerState!._controller!.value);

      isResumed.value = true;
      isRestarted.value = false;
      isPaused.value = false;
    }
  }

  /// This Method Restarts the Countdown Timer,
  /// Here optional int parameter **duration** is the updated duration for countdown timer

  void restart({int? duration}) {
    if (_timerState != null && _timerState?._controller != null) {
      final int virtualDuration =
          duration ??
          _timerState!._controller!.duration!.inSeconds * _timeScale;
      _duration = virtualDuration;
      final int realDuration = virtualDuration <= 0
          ? 0
          : (_timeScale <= 1
                ? virtualDuration
                : (virtualDuration / _timeScale).ceil());
      _timerState?._controller!.duration = Duration(seconds: realDuration);
      _timerState?._controller?.reverse(from: 1);
      isStarted.value = true;
      isRestarted.value = true;
      isPaused.value = false;
      isResumed.value = false;
    }
  }

  void correctTime(int remainingTime) {
    if (_timerState != null && _timerState?._controller != null) {
      final int totalDuration =
          _duration ?? _timerState!._controller!.duration!.inSeconds;
      if (totalDuration <= 0) {
        return;
      }

      final int clampedRemaining = remainingTime.clamp(0, totalDuration);
      final int scaledRemaining = clampedRemaining <= 0
          ? 0
          : (_timeScale <= 1
                ? clampedRemaining
                : (clampedRemaining / _timeScale).ceil());
      final int realTotalDuration =
          _timerState!._controller!.duration!.inSeconds;
      if (realTotalDuration <= 0) {
        return;
      }
      final double from = (scaledRemaining / realTotalDuration).clamp(0.0, 1.0);
      _timerState?._controller?.reverse(from: from);

      AppLogger.log(
        "تصحيح الوقت ليصبح $clampedRemaining أي ${clampedRemaining ~/ 60} دقيقة و ${clampedRemaining % 60} ثانية",
        tag: 'timer',
      );
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
    }
  }

  Future<void> cancelAllNotifications() async {
    await NotificationHelper.cancelAllNotifications();
  }

  void setNonfiction({
    String activityName = "غير محدد",
    int sessionTime = 5,
    int seconds = 5,
  }) async {
    AppLogger.log(
      "setNonfiction called with $activityName, $sessionTime, $seconds",
      tag: 'timer',
    );
    await NotificationHelper.sendScheduledNotification(
      id: 1,
      title: 'أُنجزت الجلسة',
      message: 'عملت على $activityName لمدة $sessionTime دقيقة',
      imagePath: fruitsPath[sessionTime.toString()]![0],
      payload: "$sessionTime#:#$activityName",
      seconds: seconds,
    );
  }

  Future<void> sendImmediateNotification({
    String activityName = "غير محدد",
    int sessionTime = 5,
  }) async {
    await NotificationHelper.sendImmediateNotification(
      id: 1,
      title: 'أُنجزت الجلسة',
      message: 'عملت على $activityName لمدة $sessionTime دقيقة',
      payload: "$sessionTime#:#$activityName",
      imagePath: fruitsPath[sessionTime.toString()]![0],
    );
  }

  /// This Method returns the **Current Time** of Countdown Timer i.e
  /// Time Used in terms of **Forward Countdown** and Time Left in terms of **Reverse Countdown**

  String? getTime() {
    if (_timerState != null && _timerState?._controller != null) {
      final Duration remaining =
          _timerState!._controller!.duration! * _timerState!._controller!.value;
      if (_timeScale <= 1) {
        return _timerState?._getTimeFormatted(remaining);
      }
      return _timerState?._getTimeFormatted(
        Duration(milliseconds: (remaining.inMilliseconds * _timeScale).round()),
      );
    }
    return "";
  }
}
