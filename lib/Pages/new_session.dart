import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';
import 'package:salad_of_achievement/utilities/const.dart';

import '../DB/models/data_model.dart';
import '../main.dart' show objectBox;

final ValueNotifier<int> timeValue = ValueNotifier(0);
final ValueNotifier<String> activityLabel = ValueNotifier('');

class AddNewSession extends StatelessWidget {
  const AddNewSession({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FittedBox(
          fit: BoxFit.cover,
          child: Text('إضافة جلسة جديدة'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            timeValue.value = 0; // Reset time value when going back
            activityLabel.value = ''; // Reset activity label when going back
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
            Column(
              children: [DropActivity(), SizedBox(height: 20), DropOfTime()],
            ),
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
    final dataProvider = objectBox;

    return Container(
      color: kContainerColor,
      width: MediaQuery.of(context).size.width * 0.8,
      child: DropdownButtonFormField<String>(
        hint: const Text('اختر نشاط / مشروع', style: TextStyle(fontSize: 16)),
        decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
        ),
        onChanged: (String? newValue) {
          activityLabel.value = newValue!;
        },
        items: dataProvider.getActiveActivities().map<DropdownMenuItem<String>>(
          (Activity value) {
            return DropdownMenuItem<String>(
              value: value.name,
              child: Text(value.name),
            );
          },
        ).toList(),
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
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
        ),
        onChanged: (value) {
          timeValue.value = int.parse(value!);
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
    // Wrap with AnimatedBuilder
    return AnimatedBuilder(
      animation: Listenable.merge([timeValue, activityLabel]),
      builder: (context, child) {
        // Check values using .value
        bool isEnabled = activityLabel.value.isNotEmpty && timeValue.value != 0;

        return GestureDetector(
          onTap: () {
            // Update logic to use .value
            if (isEnabled) {
              final dataProvider = objectBox;
              final Activity? activity = dataProvider
                  .getAllActivities()
                  .firstWhereOrNull(
                    (activity) => activity.name == activityLabel.value,
                  );
              final String activityGroup = activity?.group ?? 'مرجأة';

              dataProvider.addSession(
                Session(
                  date: dataProvider.getCurrentSessionDate(),
                  timeSpent: timeValue.value,
                  activityName: activityLabel.value,
                  group: activityGroup,
                ),
              );

              if (activity != null) {
                activity.timeSpent += timeValue.value;
                dataProvider.updateActivity(activity, null, activity.timeSpent);
              } else {
                dataProvider.addActivity(
                  Activity(
                    name: activityLabel.value,
                    timeSpent: timeValue.value,
                    group: activityGroup,
                  ),
                );
              }
              Navigator.pop(context);
              timeValue.value = 0; // Reset time value after adding session
              activityLabel.value =
                  ''; // Reset activity label after adding session
            }
          },
          child: Container(
            // Use the isEnabled flag for color
            color: isEnabled ? kActionColor : kContainerColor,
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
      },
    );
  }
}
