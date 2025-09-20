import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';
import 'package:salad_of_achievement/utilities/const.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';

int min = 0;
String activity = '';

class AddNewSession extends StatelessWidget {
  const AddNewSession({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FittedBox(fit: BoxFit.cover, child: Text('إضافة جلسة جديدة')),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [DropActivity(), SizedBox(height: 20), DropOfTime()]),
            OkButton(),
          ],
        ),
      ),
    );
  }
}

class DropActivity extends StatelessWidget {
  const DropActivity({super.key});

  @override
  Widget build(BuildContext context) {
    ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);

    return Container(
      color: kContainerColor,
      width: MediaQuery.of(context).size.width * 0.8,
      child: DropdownButtonFormField<String>(
        hint: const Text('اختر نشاط / مشروع', style: TextStyle(fontSize: 16)),
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
        ),
        onChanged: (String? newValue) {
          activity = newValue!;
        },
        items: dataProvider.getAllActivities().map<DropdownMenuItem<String>>((Activity value) {
          return DropdownMenuItem<String>(value: value.name, child: Text(value.name));
        }).toList(),
      ),
    );
  }
}

class DropOfTime extends StatelessWidget {
  const DropOfTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kContainerColor,
      width: MediaQuery.of(context).size.width * 0.8,
      child: DropdownButtonFormField(
        hint: const Text('اختر طول الجلسة', style: TextStyle(fontSize: 16)),
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
        ),
        onChanged: (value) {
          min = int.parse(value!);
        },
        items: fruits.keys.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              children: <Widget>[
                SizedBox(height: 40, width: 40, child: fruits[value]!.first),
                const SizedBox(width: 10),
                Text(HijriLogic.englishToArabicNumber(value)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class OkButton extends StatelessWidget {
  const OkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (activity.isNotEmpty && min != 0) {
          ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);
          dataProvider.addSession(Session(date: HijriCalendar.now().toString(), timeSpent: min, activityName: activity));
          Navigator.pop(context);
        }
      },
      child: Container(
        color: activity.isNotEmpty && min != 0 ? kContainerColor : kActionColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("أضف الجلسة", style: const TextTheme().bodySmall),
            ),
          ),
        ),
      ),
    );
  }
}
