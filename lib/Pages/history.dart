import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';
import '../utilities/const.dart';

List<Activity> activities = [];

class AppHistoryPage extends StatelessWidget {
  const AppHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInnerBackGroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const FittedBox(fit: BoxFit.cover, child: Text('سجل الجلسات')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);
    List<GroupedSessions> groupedSessions = dataProvider.groupSessionsByDay(dataProvider.getAllSessions());
    activities = dataProvider.getAllActivities();
    return ListView.separated(
      reverse: true,
      shrinkWrap: true,
      itemCount: groupedSessions.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          tileColor: kBorderColor,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SessionDetails("${groupedSessions[index].dayName} ${groupedSessions[index].date}هـ", groupedSessions[index].sessions),
              ),
            );
          },
          leading: Container(
            decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(10))),
            width: 80,
            height: 40,
            padding: const EdgeInsets.all(5),
            child: StarsShower(groupedSessions[index].totalMinutes, dataProvider.star1, dataProvider.star2, dataProvider.star3),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${groupedSessions[index].dayName} ${HijriLogic.englishToArabicNumber(groupedSessions[index].date)}هـ",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor),
            ),
          ),
          trailing: FittedBox(
            child: Text(
              "دقيقة ${HijriLogic.englishToArabicNumber(groupedSessions[index].totalMinutes.toString())}",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(color: kWhiteColor..withAlpha(127), width: MediaQuery.of(context).size.width, height: 1);
      },
    );
  }
}

class StarsShower extends StatelessWidget {
  final int totalTime;
  final int star1;
  final int star2;
  final int star3;
  const StarsShower(this.totalTime, this.star1, this.star2, this.star3, {super.key});

  @override
  Widget build(BuildContext context) {
    if (totalTime >= star3) {
      return const Stars(isStar1: true, isStar2: true, isStar3: true, size: 20);
    } else if (totalTime >= star2) {
      return const Stars(isStar1: true, isStar2: true, size: 20);
    } else if (totalTime >= star1) {
      return const Stars(isStar1: true, size: 20);
    }
    return const Stars(size: 20);
  }
}

class SessionDetails extends StatefulWidget {
  const SessionDetails(this.title, this.sessions, {super.key});
  final List<Session> sessions;
  final String title;

  @override
  State<SessionDetails> createState() => _SessionDetailsState();
}

String? activityName;

class _SessionDetailsState extends State<SessionDetails> {
  @override
  Widget build(BuildContext context) {
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);
    return Scaffold(
      backgroundColor: kInnerBackGroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: FittedBox(fit: BoxFit.fill, child: Text(HijriLogic.englishToArabicNumber(widget.title))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.separated(
        itemCount: widget.sessions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            tileColor: kBorderColor,
            leading: Container(
              //الفاكهة
              decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(10))),
              width: 75,
              height: 60,
              padding: const EdgeInsets.all(5),
              child: fruits[widget.sessions[index].timeSpent.toString()]![0],
            ), //الفاكهة ثم اللون
            //الأيقونة
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: kStrawberryColor),
              onPressed: () {
                Provider.of<ObjectBoxState>(context, listen: false).deleteSession(widget.sessions[index].id);
                setState(() => widget.sessions.removeAt(index));
              },
            ),

            //النص كقائمة
            title: activities.isNotEmpty
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: () {
                        String currentactivityName = widget.sessions[index].activityName;
                        bool activityNameExists = activities.any((activity) => activity.name == currentactivityName);
                        if (!activityNameExists && activities.isNotEmpty) {
                          return activities.first.name;
                        }
                        return currentactivityName;
                      }(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            widget.sessions[index].activityName = newValue;
                            dataProvider.updateSession(widget.sessions[index]);
                          }
                        });
                      },
                      items: activities.map<DropdownMenuItem<String>>((Activity value) {
                        return DropdownMenuItem<String>(
                          value: value.name,
                          child: Text(value.name, style: Theme.of(context).textTheme.bodySmall),
                        );
                      }).toList(),
                    ),
                  )
                : Text(widget.sessions[index].activityName, style: Theme.of(context).textTheme.bodySmall),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(color: kWhiteColor..withAlpha(127), width: MediaQuery.of(context).size.width, height: 1);
        },
      ),
    );
  }
}
