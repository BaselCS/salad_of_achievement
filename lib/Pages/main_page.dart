import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/DB/models/data_model.dart';
import 'package:salad_of_achievement/utilities/const.dart';

import '../DB/models/object_box.dart';
import '../logical/notification.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    NotificationHelper.onClickNotification.stream.listen((String event) {
      if (event.contains("save_action") || event.contains("cancel_action")) {
        ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);
        List<String> data = event.split("#");
        if (data[0] == "save_action") {
          data = data[1].split(" ");
          print("data: $data");
          dataProvider.addSession(Session(date: HijriCalendar.now().toString(), topic: data[0], timeSpent: int.tryParse(data[1]) ?? 0));
        }
        Navigator.of(context).pushNamed('/');
        NotificationHelper.onClickNotification.add("");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double progressHight = MediaQuery.of(context).size.height * 0.062;
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: FittedBox(
                child: Text('${HijriCalendar.now().dayWeName} ${HijriCalendar.now().hDay}/${HijriCalendar.now().longMonthName}/${HijriCalendar.now().hYear}')),
            actions: [
              Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: IconButton(
                      icon: const Icon(Icons.add_circle_rounded),
                      onPressed: () {
                        Navigator.pushNamed(context, '/newSession');
                      }))
            ],
            leading: Builder(builder: (BuildContext context) {
              return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  });
            })),
        drawer: const MyDrawer(),
        body: const VisitableButtons(),
        bottomNavigationBar: BottomBar(progressHight: progressHight));
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: kBackGroundColor,
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(decoration: const BoxDecoration(color: kContainerColor), child: appIcon),
          ListTile(
              title: const Text('سجل الجلسات'),
              leading: const MyIcon(Icons.assignment),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              }),
          ListTile(
              title: const Text('أنشطة و مشروعات'),
              leading: const MyIcon(Icons.interests),
              onTap: () {
                Navigator.pushNamed(context, '/activity');
              }),
          ListTile(
              title: const Text('إحصائيات'),
              leading: const MyIcon(Icons.insert_chart),
              onTap: () {
                Navigator.pushNamed(context, '/statistics');
              }),
          ListTile(
              title: const Text('إعدادات'),
              leading: const MyIcon(Icons.settings),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              })
        ]));
  }
}

// الخضروات
class VisitableButtons extends StatelessWidget {
  const VisitableButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            children: fruits.entries.map((entry) {
              return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/activeSection', arguments: entry.key);
                  },
                  child: Column(children: [Expanded(child: entry.value.first), Expanded(child: Text(entry.key, style: TextStyle(color: entry.value.last)))]));
            }).toList()));
  }
}

// الشريط السفلي
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.progressHight});

  final double progressHight;

  @override
  Widget build(BuildContext context) {
    final ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);

    return BottomAppBar(
        height: MediaQuery.of(context).size.height * 0.2,
        padding: const EdgeInsets.fromLTRB(4, 15, 8, 4),
        child: Column(children: [
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(flex: 2, child: FittedBox(child: Text('إنجاز اليوم: ${dataProvider.doneMinutes.toInt()} دقيقة'))),
              Expanded(
                child: Stars(
                    isStar1: dataProvider.doneMinutes >= dataProvider.star1,
                    isStar2: dataProvider.doneMinutes >= dataProvider.star2,
                    isStar3: dataProvider.doneMinutes >= dataProvider.star3),
              )
            ]),
          ),
          Expanded(
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)), child: ProgressBar(dataProvider: dataProvider, progressHight: progressHight))),
          const Expanded(child: FittedBox(fit: BoxFit.contain, child: Text('سألته ما الغاية الكبرى قال رضون من الله أكبر')))
        ]));
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.dataProvider, required this.progressHight});

  final ObjectBoxState dataProvider;
  final double progressHight;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      LinearProgressIndicator(
        value: dataProvider.doneMinutes / dataProvider.star3,
        minHeight: progressHight,
        valueColor: const AlwaysStoppedAnimation<Color>(kActionColor),
      ),
      Row(children: <Widget>[
        //في مشكلة في التحويل
        Spacer(progressHight, (dataProvider.star1 / dataProvider.star3) * MediaQuery.of(context).size.width),
        Spacer(progressHight, (dataProvider.star2 / dataProvider.star3) * MediaQuery.of(context).size.width)
      ])
    ]);
  }
}

// /// مقدار الفراغ بين النجوم
class Spacer extends StatelessWidget {
  final double height;
  final double progress;
  const Spacer(this.height, this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: VerticalDivider(thickness: 2, width: progress, color: Colors.white.withOpacity(0.5)));
  }
}
