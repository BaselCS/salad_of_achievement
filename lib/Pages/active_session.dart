import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/logical/notification.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';
import '../utilities/const.dart';
import '../utilities/log.dart';
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
    sessionTime = int.parse(time.toString());
    theImage = fruits[time.toString()]![0];
    theColor = fruits[time.toString()]![1];
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

  @override
  Widget build(BuildContext context) {
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);

    return SizedBox(
      width: double.infinity,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            const CountDownTimer(),
            const ActivityNameMenu(),
            CircleAvatar(
                backgroundColor: theColor,
                radius: 30,
                child: IconButton(
                    onPressed: () {
                      if (controller.isPaused.value) {
                        // MyLogger.log("تم الاستئناف");
                        theIcon = Icons.pause;
                        controller.resume();
                        // MyLogger.log("بعد الاستئناف controller.remainingSeconds = ${controller.remainingSeconds}");
                        // MyLogger.log("بعد الاستئناف controller.isPaused.value = ${controller.isPaused.value}");
                        // MyLogger.log("بعد الاستئناف sessionTime = $sessionTime");
                        // MyLogger.log("بعد الاستئناف activityName = $activityName");
                        // MyLogger.log("بعد الاستئناف doneMinutes = $doneMinutes");
                        if (controller.remainingSeconds > sessionTime * 60) {
                          NotificationHelper.textNotification("تم إنهاء الجلسة", "جلست $activityName استمرت $sessionTime", timeInSecond: sessionTime * 60);
                        } else {
                          NotificationHelper.textNotification("تم إنهاء الجلسة", "جلست $activityName استمرت $sessionTime",
                              timeInSecond: controller.remainingSeconds);
                        }
                      } else {
                        // MyLogger.log("تم الإيقاف");
                        theIcon = Icons.play_arrow;
                        controller.pause();

                        NotificationHelper.cancelNotification();
                      }
                      setState(() {});
                    },
                    icon: Icon(theIcon, color: Colors.white, size: 30))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.45, child: const CancelButton()),
              if (dataProvider.getDoneMinutesOfSession != 0) SizedBox(width: MediaQuery.of(context).size.width * 0.45, child: const SaveButton()),
            ])
          ])),
    );
  }
}

class ActivityNameMenu extends StatefulWidget {
  const ActivityNameMenu({
    super.key,
  });

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

                    NotificationHelper.cancelNotification();
                    if (controller.remainingSeconds > sessionTime * 60) {
                      NotificationHelper.textNotification("تم إنهاء الجلسة", "جلست $activityName استمرت $sessionTime", timeInSecond: sessionTime * 60);
                    } else {
                      NotificationHelper.textNotification("تم إنهاء الجلسة", "جلست $activityName استمرت $sessionTime",
                          timeInSecond: controller.remainingSeconds);
                    }
                  });
                },
                items: activities.map<DropdownMenuItem<String>>((Activity value) {
                  return DropdownMenuItem<String>(
                    value: value.name,
                    child: Text(value.name, style: Theme.of(context).textTheme.bodySmall),
                  );
                }).toList())));
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
                    content: const Padding(
                      padding: EdgeInsets.all(8.0),
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
                              child: Center(child: Text("لا", style: Theme.of(context).textTheme.bodySmall!)))),
                      InkWell(
                          onTap: () {
                            NotificationHelper.cancelNotification();
                            Navigator.pop(context);
                            controller.stopTime();
                            Navigator.pop(context);
                          },
                          child: Container(
                              clipBehavior: Clip.antiAlias,
                              padding: const EdgeInsets.all(4.0),
                              width: MediaQuery.of(context1).size.width * 0.15,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.red),
                              child: Center(child: Text("نعم", style: Theme.of(context).textTheme.bodySmall!)))),
                    ]);
              });
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.center, children: [
              GestureDetector(child: const CircleAvatar(radius: 20, backgroundColor: Colors.black, child: Icon(Icons.cancel, color: Colors.red))),
              Text('إلغاء الجلسة ', style: Theme.of(context).textTheme.labelLarge!)
            ])));
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  void showMsg(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: kContainerColor,
        duration: const Duration(milliseconds: 250),
        content: Text(
          "لم تبلغ أقل حد للجلسة",
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: theColor),
          textAlign: TextAlign.center,
        )));
  }

  @override
  Widget build(BuildContext context) {
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);

    return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        onPressed: () {
          if (doneMinutes != 0) {
            addSession(context, doneMinutes, activityName);
            doneMinutes = 0;
          } else {
            showMsg(context);
          }
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.center, children: [
              GestureDetector(child: CircleAvatar(radius: 20, backgroundColor: Colors.black, child: Icon(Icons.save, color: theColor))),
              Text('حفظ الجلسة   ${dataProvider.getDoneMinutesOfSession}', style: Theme.of(context).textTheme.labelLarge!)
            ])));
  }
}

class CountDownTimer extends StatelessWidget {
  const CountDownTimer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MyLogger.log("CountDownTimer rebuild");
    doneMinutes = 0;
    double size = min(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.8);
    return MyCircularCountDownTimer(
      totalDuration: sessionTime * 60,
      initDuration: sessionTime * 60,
      fillColor: theColor,
      height: size,
      width: size,
      ringColor: Colors.black.withOpacity(0.5),
      controller: controller,
      onStart: () {
        NotificationHelper.textNotification("تم إنهاء الجلسة", "جلست $activityName استمرت $sessionTime", timeInSecond: sessionTime * 60);
      },
      onChange: (int doneTime) {
        int minutes = doneTime ~/ 60;
        if (doneTime >= 0) {
          int? closest = fruitsId.where((id) => id <= minutes).reduce((a, b) => a > b ? a : b);
          doneMinutes = closest;
          Provider.of<ObjectBoxState>(context, listen: false).setDoneMinutesOfSession = doneMinutes;
        } else {
          MyLogger.log("Done Time is NEGATIVE  $doneTime");
        }
      },
      onComplete: () {
        doneMinutes = sessionTime;
        controller.stopTime();
      },
      child: theImage,
    );
  }
}

void addSession(BuildContext context, int sessionTime, String? activityName) {
  MyLogger.log("The session is Saved with $sessionTime minutes");
  NotificationHelper.cancelNotification();

  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);
  controller.stopTime();

  dataProvider.addSession(Session(
    date: HijriCalendar.now().toString(),
    timeSpent: sessionTime,
    topic: activityName ?? 'غير محدد',
  ));

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: kContainerColor,
      duration: const Duration(milliseconds: 500),
      content: Text(
        sessionTime == 0 ? 'تم إلغاء الجلسة' : 'تم حفظ الجلسة',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: theColor),
        textAlign: TextAlign.center,
      )));

  Navigator.pop(context);
}
