import 'dart:developer' show log;
import 'dart:math' show min, max;

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';
import '../utilities/const.dart';
import '../utilities/my_circular_count_down_timer.dart';

CountDownControllers controller = CountDownControllers();
Image theImage = tomato;
Color theColor = kTomatoColor;
int sessionTime = 0;
List<Activity> activities = [];
int doneMinutes = 0;

class ActiveSectionPage extends StatelessWidget {
  const ActiveSectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? time = ModalRoute.of(context)!.settings.arguments;
    theImage = fruits[time.toString()]![0];
    theColor = fruits[time.toString()]![1];
    sessionTime = int.parse(time.toString());
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);
    activities = dataProvider.getAllActivities();
    return const Scaffold(backgroundColor: kBackGroundColor, body: Body());
  }
}

//يغير الأيقونة بس
class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  IconData theIcon = Icons.pause;
  int remainingAfterStop = 0;
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
                    log("تم الاستئناف");
                    TimerLogic.instance.setEndingTime(remainingAfterStop);
                    theIcon = Icons.pause;
                    controller.resume();
                    if (TimerLogic.instance.remainingSeconds <= 0) {
                      controller.sendImmediateNotification(activityName: activityName ?? "غير محدد", sessionTime: sessionTime);
                    } else {
                      controller.setNonfiction(
                        activityName: activityName ?? "غير محدد",
                        sessionTime: sessionTime,
                        seconds: TimerLogic.instance.remainingSeconds,
                      );
                    }
                  } else {
                    log("تم الإيقاف");
                    theIcon = Icons.play_arrow;
                    controller.pause();
                    remainingAfterStop = TimerLogic.instance.remainingSeconds;
                    controller.cancelAllNotifications();
                  }
                  setState(() {});
                },
                icon: Icon(theIcon, color: Colors.white, size: 30),
              ),
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [CancelButton(), SaveButton()]),
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

String? activityName;

class _ActivityNameMenuState extends State<ActivityNameMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.05,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), color: kContainerColor),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: activityName,
          onChanged: (String? newValue) {
            setState(() {
              activityName = newValue!;
            });
          },
          items: activities.map<DropdownMenuItem<String>>((Activity value) {
            return DropdownMenuItem<String>(
              value: value.name,
              child: Text(value.name, style: Theme.of(context).textTheme.bodySmall),
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
                    Navigator.pop(context1);
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(4.0),
                    width: MediaQuery.of(context1).size.width * 0.15,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: kContainerColor),
                    child: Center(child: Text("لا", style: Theme.of(context).textTheme.bodySmall!)),
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
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.red),
                    child: Center(child: Text("نعم", style: Theme.of(context).textTheme.bodySmall!)),
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
            Text('إلغاء الجلسة ', style: Theme.of(context).textTheme.bodySmall!),
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
        if (doneMinutes != 0 && fruitsId.contains(doneMinutes)) {
          addSession(context, doneMinutes, activityName);
          controller.cancelAllNotifications();
        }
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
    controller.setNonfiction(activityName: activityName ?? "غير محدد", sessionTime: sessionTime, seconds: sessionTime * 60);
  }

  void onChange(String string) {
    int minutes = int.parse(string.split(":")[0]);
    int seconds = int.parse(string.split(":")[1]);
    int remain = TimerLogic.instance.remainingSeconds;
    if (minutes == 0 && seconds == 0) {
      return;
    }
    if ((minutes + seconds) - remain > 10) {
      controller.correctTime(remain);
    }

    if (fruitsId.contains(remain)) {
      doneMinutes = remain;
    }
  }

  const CountDownTimer({super.key});
  @override
  Widget build(BuildContext context) {
    doneMinutes = 0;
    double size = min(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.8);
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
        doneMinutes = sessionTime;
      },
      child: theImage,
    );
  }
}

void addSession(BuildContext context, int sessionTime, String? activityName) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);

  dataProvider.addSession(Session(date: HijriCalendar.now().toString(), timeSpent: sessionTime, topic: activityName ?? 'غير محدد'));
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

  Navigator.pop(context);
}

class TimerLogic {
  static late DateTime endingTime;

  static final TimerLogic _instance = TimerLogic();

  static TimerLogic get instance => _instance;

  int get remainingSeconds {
    final DateTime dateTimeNow = DateTime.now();
    Duration remainingTime = endingTime.difference(dateTimeNow);
    return max(0, remainingTime.inSeconds);
  }

  void setEndingTime(int durationToEnd) {
    final DateTime dateTimeNow = DateTime.now();
    endingTime = dateTimeNow.add(Duration(seconds: durationToEnd));
    log("TimerLogic  -setEndingTime = ${endingTime.toLocal().toString()}");
  }
}
