import 'dart:math' show max, min;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';
import '../logical/app_logger.dart';
import '../utilities/const.dart';
import '../utilities/my_circular_count_down_timer.dart';

CountDownControllers controller = CountDownControllers();
Image theImage = tomato;
Color theColor = kTomatoColor;
int sessionTime = 0;
List<Activity> activities = [];
int doneMinutes = 0;
bool isFromNotification = false;
bool isNotified = false;

String? activityName;

class ActiveSectionPage extends StatelessWidget {
  final List<Object?> arguments;
  const ActiveSectionPage({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    final String time = arguments[0]?.toString() ?? "5";
    if (arguments[0] == null) {
      AppLogger.log(
        "No session time provided in arguments, defaulting to 5 minutes.",
        tag: 'active-session',
      );
    }
    isFromNotification = arguments[2] as bool;

    theImage = fruits[time.toString()]![0];
    theColor = fruits[time.toString()]![1];

    if (isFromNotification && !isNotified) {
      isNotified = true;
      TimerLogic.instance.setEndingTime(0);
      activityName = arguments[1] as String?;
      sessionTime = 0;
      doneMinutes = int.parse(time.toString());
    } else {
      isNotified = false;
      sessionTime = int.parse(time.toString());
    }
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(
      context,
      listen: false,
    );
    activities = dataProvider.getActiveActivities();
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (_, _) {
        controller.cancelAllNotifications();
      },
      child: const Scaffold(backgroundColor: kBackGroundColor, body: Body()),
    );
  }
}

//يغير الأيقونة بس
class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with WidgetsBindingObserver {
  IconData theIcon = Icons.pause;
  int remainingAfterStop = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    // DateTime-based remaining time keeps moving in background; sync visuals on resume.
    final int remain = TimerLogic.instance.remainingSeconds;
    controller.correctTime(remain);
    if (remain <= 0) {
      theIcon = Icons.play_arrow;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const CountDownTimer(),
            const ActivityNameMenu(),
            CircleAvatar(
              backgroundColor: theColor,
              radius: 30,
              child: IconButton(
                onPressed: () {
                  if (controller.isPaused.value) {
                    AppLogger.log("تم الاستئناف", tag: 'active-session');
                    TimerLogic.instance.resume();
                    theIcon = Icons.pause;
                    controller.resume();
                    if (TimerLogic.instance.remainingSeconds <= 0) {
                      controller.sendImmediateNotification(
                        activityName: activityName ?? "غير محدد",
                        sessionTime: sessionTime,
                      );
                    } else {
                      controller.setNonfiction(
                        activityName: activityName ?? "غير محدد",
                        sessionTime: sessionTime,
                        seconds: TimerLogic.instance.remainingSeconds,
                      );
                    }
                  } else {
                    AppLogger.log("تم الإيقاف", tag: 'active-session');
                    theIcon = Icons.play_arrow;
                    controller.pause();
                    remainingAfterStop = TimerLogic.instance.remainingSeconds;
                    TimerLogic.instance.pause(remainingAfterStop);
                    controller.cancelAllNotifications();
                  }
                  setState(() {});
                },
                icon: Icon(theIcon, color: Colors.white, size: 30),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [CancelButton(), SaveButton()],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityNameMenu extends StatefulWidget {
  const ActivityNameMenu({super.key});

  @override
  State<ActivityNameMenu> createState() => _ActivityNameMenuState();
}

class _ActivityNameMenuState extends State<ActivityNameMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.05,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: kContainerColor,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: activityName,
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              activityName = newValue!;
            });
            if (!isFromNotification) {
              controller.cancelAllNotifications();
              controller.setNonfiction(
                activityName: newValue ?? "غير محدد",
                sessionTime: sessionTime,
                seconds: TimerLogic.instance.remainingSeconds,
              );
            }
          },
          items: activities.map<DropdownMenuItem<String>>((Activity value) {
            return DropdownMenuItem<String>(
              value: value.name,
              child: Text(value.name, overflow: TextOverflow.clip),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context1) {
            return AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceAround,
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FittedBox(child: Text('هل أنت متأكد من إلغاء الجلسة؟')),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    controller.cancelAllNotifications();
                    Navigator.pop(context);
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(4.0),
                    width: MediaQuery.of(context1).size.width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: kContainerColor,
                    ),
                    child: Center(
                      child: Text(
                        "لا",
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.cancelAllNotifications();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(4.0),
                    width: MediaQuery.of(context1).size.width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.red,
                    ),
                    child: Center(
                      child: Text(
                        "نعم",
                        style: Theme.of(context).textTheme.bodySmall!,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black,
                child: Icon(Icons.cancel, color: Colors.red),
              ),
            ),
            Text(
              'إلغاء الجلسة ',
              style: Theme.of(context).textTheme.bodySmall!,
            ),
          ],
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
      onPressed: () {
        if (activityName == null || activityName!.trim().isEmpty) {
          AppLogger.log(
            "Save blocked: activity is missing.",
            tag: 'active-session',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('اختر نشاطا قبل حفظ الجلسة'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        final int remain = TimerLogic.instance.remainingSeconds;
        final int currentDone = (sessionTime * 60 - remain) ~/ 60;

        if (!fruitsId.contains(currentDone)) {
          AppLogger.log(
            "Save blocked: current completion ($currentDone min) is not a valid milestone.",
            tag: 'active-session',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: theColor,
              content: Text('لا يمكن حفظ الجلسة الآن، أكمل وقتا صالحا أولا'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        addSession(context, currentDone, activityName);
        controller.cancelAllNotifications();
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.black,
                child: Icon(Icons.save, color: theColor),
              ),
            ),
            Text('حفظ الجلسة ', style: Theme.of(context).textTheme.bodySmall!),
          ],
        ),
      ),
    );
  }
}

class CountDownTimer extends StatelessWidget {
  void start() {
    TimerLogic.instance.setEndingTime(sessionTime * 60);
    controller.setNonfiction(
      activityName: activityName ?? "غير محدد",
      sessionTime: sessionTime,
      seconds: sessionTime * 60,
    );
  }

  void onChange(String string) {
    int minutes = int.parse(string.split(":")[0]);
    int seconds = int.parse(string.split(":")[1]);
    int uiRemaining = (minutes * 60) + seconds;
    int remain = TimerLogic.instance.remainingSeconds;
    if (minutes == 0 && seconds == 0) {
      return;
    }
    if ((uiRemaining - remain).abs() > 2) {
      controller.correctTime(remain);
    }

    if (fruitsId.contains(sessionTime - remain)) {
      doneMinutes = sessionTime - remain;
    }
  }

  const CountDownTimer({super.key});
  @override
  Widget build(BuildContext context) {
    if (!isFromNotification) {
      doneMinutes = 0;
    }

    double size = min(
      MediaQuery.of(context).size.width * 0.8,
      MediaQuery.of(context).size.height * 0.8,
    );
    return MyCircularCountDownTimer(
      duration: sessionTime * 60,
      initialDuration: 0,
      fillColor: theColor,
      height: size,
      width: size,
      ringColor: Colors.black.withAlpha(127),
      controller: controller,
      onStart: () {
        start();
      },
      onChange: (string) {
        onChange(string);
      },
      onComplete: () {
        if (isFromNotification) {
          return;
        }
        doneMinutes = sessionTime;
      },
      child: Hero(tag: sessionTime.toString(), child: theImage),
    );
  }
}

void addSession(BuildContext context, int sessionTime, String? activityName) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(
    context,
    listen: false,
  );
  final Activity? activity = activities.firstWhereOrNull(
    (activity) => activity.name == activityName,
  );
  final String activityGroup = activity?.group ?? 'General';

  dataProvider.addSession(
    Session(
      date: dataProvider.getCurrentSessionDate(),
      timeSpent: sessionTime,
      activityName: activityName ?? 'غير محدد',
      group: activityGroup,
    ),
  );
  if (activity != null) {
    activity.timeSpent += sessionTime;
    dataProvider.updateActivity(activity, null, activity.timeSpent);
  } else if (activityName != null) {
    dataProvider.addActivity(
      Activity(
        name: activityName,
        timeSpent: sessionTime,
        group: activityGroup,
      ),
    );
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: kContainerColor,
      duration: const Duration(milliseconds: 500),
      content: Text(
        sessionTime == 0 ? 'تم إلغاء الجلسة' : 'تم حفظ الجلسة',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: theColor),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

class TimerLogic {
  static late DateTime endingTime;
  static bool _isPaused = false;
  static int _remainingSecondsAtPause = 0;

  static final TimerLogic _instance = TimerLogic();

  static TimerLogic get instance => _instance;

  int get remainingSeconds {
    if (_isPaused) {
      return _remainingSecondsAtPause;
    }
    final DateTime dateTimeNow = DateTime.now();
    Duration remainingTime = endingTime.difference(dateTimeNow);
    return max(0, remainingTime.inSeconds);
  }

  void pause(int remaining) {
    _isPaused = true;
    _remainingSecondsAtPause = remaining;
  }

  void resume() {
    _isPaused = false;
    setEndingTime(_remainingSecondsAtPause);
  }

  void setEndingTime(int durationToEnd) {
    _isPaused = false;
    final DateTime dateTimeNow = DateTime.now();
    endingTime = dateTimeNow.add(Duration(seconds: durationToEnd));
    AppLogger.log(
      "TimerLogic setEndingTime = ${endingTime.toLocal().toString()}",
      tag: 'timer',
    );
  }
}
