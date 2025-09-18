import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';
import '../utilities/const.dart';

List<Activity> activities = [];
int newTime = 0;

class AppActivityPage extends StatelessWidget {
  const AppActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kInnerBackGroundColor,
        appBar: AppBar(
            centerTitle: true,
            title: const FittedBox(fit: BoxFit.fill, child: Text('أنشطة و مشروعات')),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: const Body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: const AddActivity());
  }
}

class AddActivity extends StatelessWidget {
  const AddActivity({super.key});
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    TextEditingController controllerMin = TextEditingController();

    return FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
        onPressed: () {
          addActivityMassage(context, controller, controllerMin);
        },
        backgroundColor: kActionColor,
        child: const Icon(Icons.add));
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);
    TextEditingController controllerName = TextEditingController();
    TextEditingController controllerMin = TextEditingController();
    activities = dataProvider.getAllActivities();

    return ListView.separated(
        itemCount: activities.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                showEditMassage(context, controllerName, index, controllerMin);
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 60,
                  color: kBorderColor, // Set tile color here
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: Text(
                        activities[index].name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                        flex: 2,
                        child: Text(
                          textAlign: TextAlign.right,
                          formatDuration(activities[index].timeSpent),
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor),
                        )),
                  ])));
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(color: kWhiteColor..withAlpha(127), height: 1);
        });
  }
}

Future<dynamic> showEditMassage(BuildContext context, TextEditingController controllerName, int index, TextEditingController controllerMin) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      newTime = 0;
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceAround,
        title: const FittedBox(fit: BoxFit.scaleDown, child: Text('تعديل مشروع /  نشاط', style: TextStyle(color: kActionColor))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: controllerName,
              decoration: InputDecoration(
                fillColor: kContainerColor,
                filled: true,
                hintText: 'تعديل اسم المشروع : ${activities[index].name}',
                hintStyle: TextStyle(color: Colors.white..withAlpha(64)),
              ),
            ),
            const SizedBox(height: 16),
            EditTimeFilled(index),
            const SizedBox(height: 16),
            // زر التأكيد و الحذف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (controllerName.text.isEmpty) {
                      controllerName.text = activities[index].name;
                    }
                    if (newTime == 0) {
                      newTime = activities[index].timeSpent;
                    }

                    dataProvider.updateActivity(activities[index], controllerName.text, newTime);
                    controllerName.clear();
                    controllerMin.clear();
                    newTime = 0;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم تعديل المشروع ', style: TextStyle(color: kActionColor, fontSize: 16)),
                          backgroundColor: kContainerColor,
                          duration: Duration(milliseconds: 500)),
                    );
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: 80,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text("تعديل", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    newTime = 0;
                    dataProvider.deleteActivity(activities[index]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم حذف المشروع ', style: TextStyle(color: kTomatoColor, fontSize: 16)),
                          backgroundColor: kContainerColor,
                          duration: Duration(milliseconds: 500)),
                    );

                    Navigator.pop(context);
                  },
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(kTomatoColor)),
                  child: const SizedBox(
                    width: 80,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text("حذف", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class EditTimeFilled extends StatefulWidget {
  final int index;
  const EditTimeFilled(
    this.index, {
    super.key,
  });

  @override
  State<EditTimeFilled> createState() => _EditTimeFilledState();
}

class _EditTimeFilledState extends State<EditTimeFilled> {
  TextEditingController controllerMin = TextEditingController();
  TextEditingController controllerHour = TextEditingController();
  TextEditingController controllerDay = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(activities[widget.index].timeSpent != 0 ? formatDuration(activities[widget.index].timeSpent) : "لم تبدأ بعد",
                style: const TextStyle(color: kActionColor))),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controllerDay,
                decoration: InputDecoration(
                  fillColor: kContainerColor,
                  filled: true,
                  hintText: 'أيام',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int days = int.tryParse(value) ?? 0;
                  int hours = int.tryParse(controllerHour.text) ?? 0;
                  int minutes = int.tryParse(controllerMin.text) ?? 0;
                  newTime = days * 24 * 60 + hours * 60 + minutes;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controllerHour,
                decoration: InputDecoration(
                  fillColor: kContainerColor,
                  filled: true,
                  hintText: 'ساعات',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int days = int.tryParse(controllerDay.text) ?? 0;
                  int hours = int.tryParse(value) ?? 0;
                  int minutes = int.tryParse(controllerMin.text) ?? 0;
                  newTime = days * 24 * 60 + hours * 60 + minutes;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controllerMin,
                decoration: InputDecoration(
                  fillColor: kContainerColor,
                  filled: true,
                  hintText: 'دقائق',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int days = int.tryParse(controllerDay.text) ?? 0;
                  int hours = int.tryParse(controllerHour.text) ?? 0;
                  int minutes = int.tryParse(value) ?? 0;
                  newTime = days * 24 * 60 + hours * 60 + minutes;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<dynamic> addActivityMassage(BuildContext context, TextEditingController controller, TextEditingController controllerMin) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);
  return showDialog(
      context: context,
      builder: (context1) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceAround,
          title: const FittedBox(fit: BoxFit.scaleDown, child: Text('إضافة مشروع /  نشاط', style: TextStyle(color: kActionColor))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // إدخال
              TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                      fillColor: kContainerColor, filled: true, hintText: 'اسم المشروع', hintStyle: TextStyle(color: Colors.white.withAlpha(64)))),
              const SizedBox(height: 16),
              TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: controllerMin,
                  autofocus: true,
                  decoration: InputDecoration(
                      fillColor: kContainerColor, filled: true, hintText: 'الدقائق', hintStyle: TextStyle(color: Colors.white.withAlpha(64)))),
              const SizedBox(height: 16),
              // زر الإضافة
              ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty && controller.text != 'الاسم موجود بالفعل' && controller.text != 'أدخل اسم المشروع') {
                      if (activities.indexWhere((element) => element.name == controller.text) == -1) {
                        int duration = int.tryParse(controllerMin.text) ?? 0;
                        dataProvider.addActivity(Activity(name: controller.text, timeSpent: duration));
                        controller.clear();
                        controllerMin.clear();
                        Navigator.pop(context1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('تمت إضافة المشروع بنجاح', style: TextStyle(color: kActionColor, fontSize: 16)),
                              backgroundColor: kContainerColor,
                              duration: Duration(milliseconds: 500)),
                        );
                      } else {
                        controller.text = 'الاسم موجود بالفعل';
                      }
                    } else {
                      controller.text = 'أدخل اسم المشروع';
                    }
                  },
                  child: const SizedBox(
                      width: 80,
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text("إضافة", style: TextStyle(fontSize: 16)),
                      ))))
            ],
          ),
        );
      });
}

String formatDuration(int durationInMinutes) {
  final int days = durationInMinutes ~/ (24 * 60);
  final int hours = (durationInMinutes % (24 * 60)) ~/ 60;
  final int minutes = durationInMinutes % 60;
  String formattedDuration = '';

  if (durationInMinutes == 0) {
    formattedDuration = 'اعقِلْها وتوكَّلْ';
  }

  if (days > 0) {
    formattedDuration += '$days يوم ';
  }
  if (hours > 0) {
    formattedDuration += '$hours ساعات ';
  }
  if (minutes > 0) {
    formattedDuration += '$minutes دقائق ';
  }

  return formattedDuration.trim();
}
