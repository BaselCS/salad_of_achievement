import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/main.dart';
import 'package:salad_of_achievement/utilities/const.dart';

import '../logic/simple_data.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    double progressHight = MediaQuery.of(context).size.height * 0.062;
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text('الأحد، ١٢ رجب ١٤٤٥'),
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
  const MyDrawer({
    super.key,
  });

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
          ListTile(title: const Text('إحصائيات'), leading: const MyIcon(Icons.insert_chart), onTap: () {}),
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
            child: Column(
              children: [Expanded(child: entry.value.first), Expanded(child: Text(entry.key, style: TextStyle(color: entry.value.last)))],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// الشريط السفلي
class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.progressHight});

  final double progressHight;

  @override
  Widget build(BuildContext context) {
    final doneMinutesProvider = Provider.of<DoneMinutesProvider>(context); // Access the provider

    return BottomAppBar(
        height: MediaQuery.of(context).size.height * 0.25,
        padding: const EdgeInsets.fromLTRB(8, 35, 8, 8),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            FittedBox(fit: BoxFit.fill, child: Text('إنجاز اليوم : ${doneMinutesProvider.doneMinutes} دقيقة')),
            Stars(
                isStar1: doneMinutesProvider.doneMinutes >= SimpleData.star1,
                isStar2: doneMinutesProvider.doneMinutes >= SimpleData.star2,
                isStar3: doneMinutesProvider.doneMinutes >= SimpleData.tootleMinutes),
          ]),
          ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Stack(children: [
                LinearProgressIndicator(
                  value: doneMinutesProvider.doneMinutes / SimpleData.tootleMinutes,
                  minHeight: progressHight,
                  valueColor: const AlwaysStoppedAnimation<Color>(kActionColor),
                ),
                Row(children: <Widget>[
                  Spacer(progressHight, SimpleData.star1 / SimpleData.tootleMinutes * MediaQuery.of(context).size.width),
                  Spacer(progressHight, SimpleData.star2 / SimpleData.tootleMinutes * MediaQuery.of(context).size.width),
                ])
              ])),
          const FittedBox(fit: BoxFit.fill, child: Text('سألته ما الغاية الكبرى قال رضون من الله أكبر')),
        ]));
  }
}

/// مقدار الفراغ بين النجوم
class Spacer extends StatelessWidget {
  final double height;
  final double progress;
  const Spacer(this.height, this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: VerticalDivider(thickness: 2, width: progress, color: Colors.white.withOpacity(0.5)));
  }
}
