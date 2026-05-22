import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';
import '../utilities/const.dart';

List<Activity> activities = [];
int newTime = 0;

List<String> _availableGroups({String? currentGroup}) {
  final Set<String> groups = activities
      .map((activity) => activity.group.trim())
      .where((group) => group.isNotEmpty)
      .toSet();
  if (currentGroup != null && currentGroup.trim().isNotEmpty) {
    groups.add(currentGroup.trim());
  }

  final List<String> sortedGroups = groups.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return sortedGroups.isEmpty ? ['General'] : sortedGroups;
}

Widget _groupAutocompleteField({
  required String initialValue,
  required ValueChanged<String> onChanged,
}) {
  return Autocomplete<String>(
    initialValue: TextEditingValue(text: initialValue),
    optionsBuilder: (TextEditingValue value) {
      final String query = value.text.trim().toLowerCase();
      final List<String> groups = _availableGroups(currentGroup: initialValue);

      if (query.isEmpty) {
        return groups;
      }

      final List<String> matches = groups
          .where((group) => group.toLowerCase().contains(query))
          .toList();
      if (matches.isNotEmpty) {
        return matches;
      }

      return <String>[value.text.trim()];
    },
    onSelected: (String selection) {
      onChanged(selection);
    },
    optionsViewBuilder:
        (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: kContainerColor,
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 180,
                  maxWidth: 320,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          option,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
    fieldViewBuilder:
        (
          BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted,
        ) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: (_) => onFieldSubmitted(),
            decoration: InputDecoration(
              fillColor: kContainerColor,
              filled: true,
              hintText: 'المجموعة',
              hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
            ),
          );
        },
  );
}

class AppActivityPage extends StatelessWidget {
  const AppActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInnerBackGroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const FittedBox(
          fit: BoxFit.fill,
          child: Text('أنشطة و مشروعات'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const AddActivity(),
    );
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
      child: const Icon(Icons.add),
    );
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
    activities.sortBy((activity) => activity.isArchived ? 1 : 0);

    return ActiveActivities(
      controllerName: controllerName,
      controllerMin: controllerMin,
    );
  }
}

class ActiveActivities extends StatelessWidget {
  const ActiveActivities({
    super.key,
    required this.controllerName,
    required this.controllerMin,
  });

  final TextEditingController controllerName;
  final TextEditingController controllerMin;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: activities.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () =>
              showEditMassage(context, controllerName, index, controllerMin),
          onLongPress: () {
            if (!activities[index].isArchived) {
              showArchiveMassage(context, index);
            } else {
              unarchiveActivityMassage(context, index);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 60,
            color: kBorderColor, // Set tile color here
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    activities[index].name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    formatDuration(activities[index].timeSpent),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: kActionColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        if (index < activities.length - 1 &&
            activities[index].isArchived != activities[index + 1].isArchived) {
          return Container(height: 5, color: kActionColor);
        }
        return Divider(color: kWhiteColor..withAlpha(127), height: 1);
      },
    );
  }
}

Future<dynamic> showEditMassage(
  BuildContext context,
  TextEditingController controllerName,
  int index,
  TextEditingController controllerMin,
) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(
    context,
    listen: false,
  );
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      newTime = 0;
      // Set the current activity name as initial value
      controllerName.text = activities[index].name;
      String selectedGroup = activities[index].group;

      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceAround,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'تعديل مشروع /  نشاط',
            style: TextStyle(color: kActionColor),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: controllerName,
              cursorColor: kActionColor,
              decoration: InputDecoration(
                fillColor: kContainerColor,
                filled: true,
                hintText: activities[index].name,
                hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
              ),
            ),
            const SizedBox(height: 16),
            _groupAutocompleteField(
              initialValue: selectedGroup,
              onChanged: (String value) {
                selectedGroup = value;
              },
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
                    String newName = controllerName.text.trim();
                    if (newName.isEmpty) {
                      newName = activities[index].name;
                    }
                    if (newTime == 0) {
                      newTime = activities[index].timeSpent;
                    }

                    // Check if the new name already exists (but not for the current activity)
                    bool nameExists = activities.any(
                      (activity) =>
                          activity.name.toLowerCase() ==
                              newName.toLowerCase() &&
                          activity.id != activities[index].id,
                    );

                    if (nameExists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'اسم المشروع موجود بالفعل',
                            style: TextStyle(color: kTomatoColor, fontSize: 16),
                          ),
                          backgroundColor: kContainerColor,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // Update the activity name and time in the database
                    dataProvider.updateActivity(
                      activities[index],
                      newName,
                      newTime,
                      selectedGroup.trim().isEmpty
                          ? 'General'
                          : selectedGroup.trim(),
                    );
                    controllerName.clear();
                    controllerMin.clear();
                    newTime = 0;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'عُدل المشروع بنجاح',
                          style: TextStyle(color: kActionColor, fontSize: 16),
                        ),
                        backgroundColor: kContainerColor,
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: 80,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text("تعديل", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    newTime = 0;
                    dataProvider.deleteActivity(activities[index]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'حُذف المشروع ',
                          style: TextStyle(color: kTomatoColor, fontSize: 16),
                        ),
                        backgroundColor: kContainerColor,
                        duration: Duration(milliseconds: 500),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      kTomatoColor,
                    ),
                  ),
                  child: const SizedBox(
                    width: 80,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
  const EditTimeFilled(this.index, {super.key});

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
          child: Text(
            activities[widget.index].timeSpent != 0
                ? formatDuration(activities[widget.index].timeSpent)
                : "لم تبدأ بعد",
            style: const TextStyle(color: kActionColor),
          ),
        ),
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
                  newTime = (days * 24 * 60) + (hours * 60) + minutes;
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
                  newTime = (days * 24 * 60) + (hours * 60) + minutes;
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
                  newTime = (days * 24 * 60) + (hours * 60) + minutes;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<dynamic> addActivityMassage(
  BuildContext context,
  TextEditingController controller,
  TextEditingController controllerMin,
) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(
    context,
    listen: false,
  );
  return showDialog(
    context: context,
    builder: (context1) {
      String selectedGroup = 'General';
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceAround,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'إضافة مشروع /  نشاط',
            style: TextStyle(color: kActionColor),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // إدخال
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                fillColor: kContainerColor,
                filled: true,
                hintText: 'اسم المشروع',
                hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
              ),
            ),
            const SizedBox(height: 16),
            _groupAutocompleteField(
              initialValue: selectedGroup,
              onChanged: (String value) {
                selectedGroup = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: controllerMin,
              autofocus: true,
              decoration: InputDecoration(
                fillColor: kContainerColor,
                filled: true,
                hintText: 'الدقائق',
                hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
              ),
            ),
            const SizedBox(height: 16),
            // زر الإضافة
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty &&
                    controller.text != 'الاسم موجود بالفعل' &&
                    controller.text != 'أدخل اسم المشروع') {
                  if (activities.indexWhere(
                        (element) => element.name == controller.text,
                      ) ==
                      -1) {
                    int duration = int.tryParse(controllerMin.text) ?? 0;
                    dataProvider.addActivity(
                      Activity(
                        name: controller.text,
                        timeSpent: duration,
                        group: selectedGroup.trim().isEmpty
                            ? 'General'
                            : selectedGroup.trim(),
                      ),
                    );
                    controller.clear();
                    controllerMin.clear();
                    Navigator.pop(context1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'أُضيف المشروع بنجاح',
                          style: TextStyle(color: kActionColor, fontSize: 16),
                        ),
                        backgroundColor: kContainerColor,
                        duration: Duration(milliseconds: 500),
                      ),
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
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String formatDuration(int durationInMinutes) {
  if (durationInMinutes == 0) {
    return 'اعقِلْها وتوكَّلْ';
  }

  final int days = durationInMinutes ~/ (24 * 60);
  final int hours = (durationInMinutes % (24 * 60)) ~/ 60;
  final int minutes = durationInMinutes % 60;

  String formattedDuration = '';

  if (days > 0) {
    if (days == 1) {
      formattedDuration += 'يوم ';
    } else if (days == 2) {
      formattedDuration += 'يومان ';
    } else if (days >= 3 && days <= 10) {
      formattedDuration += '$days أيام ';
    } else {
      formattedDuration += '$days يوما ';
    }
  }

  if (hours > 0) {
    if (hours == 1) {
      formattedDuration += 'ساعة ';
    } else if (hours == 2) {
      formattedDuration += 'ساعتان ';
    } else if (hours >= 3 && hours <= 10) {
      formattedDuration += '$hours ساعات ';
    } else {
      formattedDuration += '$hours ساعة ';
    }
  }

  if (minutes > 0) {
    if (minutes == 1) {
      formattedDuration += 'دقيقة ';
    } else if (minutes == 2) {
      formattedDuration += 'دقيقتان ';
    } else if (minutes >= 3 && minutes <= 10) {
      formattedDuration += '$minutes دقائق ';
    } else {
      formattedDuration += '$minutes دقيقة ';
    }
  }

  return HijriLogic.englishToArabicNumber(formattedDuration.trim());
}

// showArchiveMassage

Future<dynamic> showArchiveMassage(BuildContext context, int index) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(
    context,
    listen: false,
  );
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      newTime = 0;
      // Set the current activity name as initial value

      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceAround,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'تربيد مشروع /  نشاط',
            style: TextStyle(color: kActionColor),
          ),
        ),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  dataProvider.archiveActivity(activities[index]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تُربد المشروع بنجاح',
                        style: TextStyle(color: kActionColor, fontSize: 16),
                      ),
                      backgroundColor: kContainerColor,
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const SizedBox(
                  width: 80,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("تربيد", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(kTomatoColor),
                ),
                child: const SizedBox(
                  width: 80,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("إلغاء", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<dynamic> unarchiveActivityMassage(BuildContext context, int index) {
  ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(
    context,
    listen: false,
  );
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      newTime = 0;
      // Set the current activity name as initial value

      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceAround,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'تنشيط المشروع  النشاط',
            style: TextStyle(color: kActionColor),
          ),
        ),
        content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  dataProvider.unarchiveActivity(activities[index]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'نُشط المشروع',
                        style: TextStyle(color: kActionColor, fontSize: 16),
                      ),
                      backgroundColor: kContainerColor,
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const SizedBox(
                  width: 80,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("تنشيط", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(kTomatoColor),
                ),
                child: const SizedBox(
                  width: 80,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("إلغاء", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
