import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:salad_of_achievement/Pages/active_session.dart';
import 'package:salad_of_achievement/Pages/activity.dart';
import 'package:salad_of_achievement/Pages/history.dart' hide activityName;
import 'package:salad_of_achievement/Pages/new_session.dart';
import 'package:salad_of_achievement/Pages/settings.dart';
import 'package:salad_of_achievement/Pages/statistics.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';
import 'package:salad_of_achievement/utilities/const.dart';
import 'package:salad_of_achievement/utilities/page_animation.dart';

import '../DB/models/object_box.dart';
import '../main.dart' show objectBox;

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double progressHight = MediaQuery.of(context).size.height * 0.062;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(
          child: Text(
            '${HijriCalendar.now().dayWeName} ${HijriLogic.englishToArabicNumber(HijriCalendar.now().hDay.toString())}/${HijriCalendar.now().longMonthName}/${HijriLogic.englishToArabicNumber(HijriCalendar.now().hYear.toString())}',
          ),
        ),
        actions: [
          // Debug button for generating fake data (remove in production)
          // IconButton(
          //   icon: const Icon(Icons.bug_report, color: Colors.orange),
          //   tooltip: 'Generate Test Data',
          //   onPressed: () => showFakeDataDialog(context),
          // ),
          // Database viewer button (for debugging)
          // IconButton(
          //   icon: const Icon(Icons.storage, color: Colors.blue),
          //   tooltip: 'View Database',
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/databaseViewer');
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: () {
                Navigator.push(context, comeFromUpRoute(const AddNewSession()));
              },
            ),
          ),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const MyDrawer(),
      body: const VisitableButtons(),
      bottomNavigationBar: BottomBar(progressHight: progressHight),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kBackGroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: kContainerColor),
            child: appIcon,
          ),
          ListTile(
            title: const Text('سجل الجلسات'),
            leading: const MyIcon(Icons.assignment),
            onTap: () {
              pushWithName(context, const AppHistoryPage());
            },
          ),
          ListTile(
            title: const Text('أنشطة و مشروعات'),
            leading: const MyIcon(Icons.interests),
            onTap: () {
              pushWithName(context, const AppActivityPage());
            },
          ),
          ListTile(
            title: const Text('إحصائيات'),
            leading: const MyIcon(Icons.insert_chart),
            onTap: () {
              pushWithName(context, const StatisticsPage());
            },
          ),
          // ListTile(
          //   title: const Text('اختبار الإشعارات'),
          //   leading: const MyIcon(Icons.notifications_active),
          //   onTap: () {
          //     pushWithName(context, const NotificationTestPage());
          //   },
          // ),
          ListTile(
            title: const Text('إعدادات'),
            leading: const MyIcon(Icons.settings),
            onTap: () {
              pushWithName(context, const AppSettingsPage());
            },
          ),
        ],
      ),
    );
  }
}

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
              Navigator.push(
                context,
                comeFromDownRoute(
                  ActiveSectionPage(
                    arguments: [entry.key, activityName, false],
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: Hero(
                    tag: entry.key,
                    child: Image.asset(
                      fruitsPath[entry.key]!,
                      width: 64,
                      height: 64,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    HijriLogic.englishToArabicNumber(entry.key),
                    style: TextStyle(color: entry.value.last),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomBar extends StatefulWidget {
  const BottomBar({super.key, required this.progressHight});

  final double progressHight;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..forward();

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.18),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = objectBox;
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: dataProvider,
          builder: (context, child) {
            return BottomAppBar(
              height: MediaQuery.of(context).size.height * 0.15,
              padding: const EdgeInsets.fromLTRB(4, 15, 8, 4),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Image.asset(
                                  '$iconPath/appIcon.png',
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                              const Text(
                                'إنجاز اليوم: ',
                                style: TextStyle(color: kActionColor, fontSize: 24),
                              ),
                              FittedBox(
                                child: Text(
                                  HijriLogic.englishToArabicNumber(
                                    dataProvider.doneMinutes.toString(),
                                  ),
                                  style: const TextStyle(
                                    color: kActionColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Text(
                                ' دقيقة',
                                style: TextStyle(color: kActionColor, fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Stars(
                            isStar1: dataProvider.doneMinutes >= dataProvider.star1,
                            isStar2: dataProvider.doneMinutes >= dataProvider.star2,
                            isStar3: dataProvider.doneMinutes >= dataProvider.star3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: ProgressBar(
                          dataProvider: dataProvider,
                          progressHight: widget.progressHight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.dataProvider,
    required this.progressHight,
  });

  final ObjectBoxState dataProvider;
  final double progressHight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LinearProgressIndicator(
          value: dataProvider.doneMinutes / dataProvider.star3,
          minHeight: progressHight,
          valueColor: const AlwaysStoppedAnimation<Color>(kActionColor),
        ),
        Row(
          children: <Widget>[
            Spacer(
              progressHight,
              (dataProvider.star1 / dataProvider.star3) * MediaQuery.of(context).size.width,
            ),
            Spacer(
              progressHight,
              (dataProvider.star2 / dataProvider.star3) * MediaQuery.of(context).size.width,
            ),
          ],
        ),
        if (dataProvider.doneMinutes > dataProvider.star3)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                "${HijriLogic.englishToArabicNumber((dataProvider.doneMinutes - dataProvider.star3).toString())}+",
                style: const TextStyle(
                  color: kWhiteColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class Spacer extends StatelessWidget {
  final double height;
  final double progress;
  const Spacer(this.height, this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: VerticalDivider(
        thickness: 2,
        width: progress,
        color: Colors.white.withAlpha(127),
      ),
    );
  }
}
