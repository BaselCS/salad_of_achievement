import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salad_of_achievement/logical/hijri_logic.dart';

import '../DB/models/data_model.dart';
import '../utilities/const.dart';
import '../main.dart' show objectBox;

String formatDuration(int durationInMinutes) {
  if (durationInMinutes == 0) return 'اعقِلْها وتوكَّلْ';

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

List<String> _getAvailableGroups(
  List<Activity> activities, {
  String? currentGroup,
}) {
  final Set<String> groups = activities
      .map((activity) => activity.group.trim())
      .where((group) => group.isNotEmpty)
      .toSet();

  if (currentGroup != null && currentGroup.trim().isNotEmpty) {
    groups.add(currentGroup.trim());
  }

  final List<String> sortedGroups = groups.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  return sortedGroups.isEmpty ? ['مرجأة'] : sortedGroups;
}

class GroupAutocompleteField extends StatelessWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final List<Activity> activities;

  const GroupAutocompleteField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (TextEditingValue value) {
        final String query = value.text.trim().toLowerCase();
        final List<String> groups = _getAvailableGroups(
          activities,
          currentGroup: initialValue,
        );

        if (query.isEmpty) return groups;

        final List<String> matches = groups
            .where((group) => group.toLowerCase().contains(query))
            .toList();

        return matches.isNotEmpty ? matches : <String>[value.text.trim()];
      },
      onSelected: onChanged,
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: kInnerBackGroundColor,
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180, maxWidth: 320),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onSubmitted: (_) => onFieldSubmitted(),
          style: const TextStyle(color: Colors.white),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const ActivityListBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
        backgroundColor: kActionColor,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddActivityDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ActivityListBody extends StatelessWidget {
  const ActivityListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: objectBox,
      builder: (context, _) {
        final dataProvider = objectBox;
        final activities = dataProvider.getAllActivities()
          ..sortBy((activity) => activity.isArchived ? 1 : 0);

        return ActiveActivitiesGroups(activities: activities);
      },
    );
  }
}

class ActiveActivitiesGroups extends StatefulWidget {
  final List<Activity> activities;

  const ActiveActivitiesGroups({super.key, required this.activities});

  @override
  State<ActiveActivitiesGroups> createState() => _ActiveActivitiesGroupsState();
}

class _ActiveActivitiesGroupsState extends State<ActiveActivitiesGroups> {
  final List<String> _groupOrder = [];

  @override
  void initState() {
    super.initState();
    _updateGroupOrder();
  }

  @override
  void didUpdateWidget(covariant ActiveActivitiesGroups oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGroupOrder();
  }

  // تحديث ترتيب المجموعات في حال إضافة مجموعة جديدة أو حذف واحدة
  void _updateGroupOrder() {
    final Map<String, List<Activity>> grouped = _getGroupedActivities();

    // إضافة المجموعات الجديدة التي لم تكن موجودة في الترتيب
    for (String groupName in grouped.keys) {
      if (!_groupOrder.contains(groupName)) {
        _groupOrder.add(groupName);
      }
    }

    // إزالة المجموعات التي لم تعد موجودة
    _groupOrder.removeWhere((groupName) => !grouped.containsKey(groupName));
  }

  Map<String, List<Activity>> _getGroupedActivities() {
    return groupBy(
      widget.activities,
      (Activity a) => a.group.trim().isEmpty ? 'مرجأة' : a.group.trim(),
    );
  }

  Color _getGroupAccentColor(String groupName) {
    final List<Color> colors = const [
      Color(0xFF00E676),
      Color(0xFF29B6F6),
      Color(0xFFFFCA28),
      Color(0xFFF06292),
      Color(0xFFAB47BC),
      Color(0xFF26A69A),
    ];
    return colors[groupName.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Activity>> groupedActivities =
        _getGroupedActivities();

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 16),
      itemCount: _groupOrder.length,
      // تعطيل مقابض السحب الافتراضية لمنع التعارض مع سحب الأنشطة
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final String item = _groupOrder.removeAt(oldIndex);
          _groupOrder.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final String groupName = _groupOrder[index];
        final List<Activity> groupItems = groupedActivities[groupName]!;
        final Color accentColor = _getGroupAccentColor(groupName);

        // تم فصل تصميم البطاقة لتسهيل إدارة حالة الطي
        return CollapsibleGroupCard(
          key: ValueKey(groupName), // مفتاح ضروري لـ ReorderableListView
          index: index,
          groupName: groupName,
          groupItems: groupItems,
          allActivities: widget.activities,
          accentColor: accentColor,
        );
      },
    );
  }
}

// عنصر جديد يمثل بطاقة المجموعة قابلة للطي والتوسيع
class CollapsibleGroupCard extends StatefulWidget {
  final int index;
  final String groupName;
  final List<Activity> groupItems;
  final List<Activity> allActivities;
  final Color accentColor;

  const CollapsibleGroupCard({
    super.key,
    required this.index,
    required this.groupName,
    required this.groupItems,
    required this.allActivities,
    required this.accentColor,
  });

  @override
  State<CollapsibleGroupCard> createState() => _CollapsibleGroupCardState();
}

class _CollapsibleGroupCardState extends State<CollapsibleGroupCard> {
  bool _isExpanded = true; // حالة الطي والتوسيع
  static const Color _separatorColor = Color(0xFF383B42);

  @override
  Widget build(BuildContext context) {
    final int totalGroupTime = widget.groupItems.fold(
      0,
      (sum, item) => sum + item.timeSpent,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DragTarget<Activity>(
        onWillAcceptWithDetails: (details) =>
            details.data.group != widget.groupName,
        onAcceptWithDetails: (details) {
          final dataProvider = objectBox;
          dataProvider.updateActivity(
            details.data,
            details.data.name,
            details.data.timeSpent,
            widget.groupName,
          );
          // توسيع المجموعة تلقائياً عند إفلات عنصر بداخلها
          setState(() {
            _isExpanded = true;
          });
        },
        builder: (context, candidateData, rejectedData) {
          final bool isHovered = candidateData.isNotEmpty;

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              //255*0.7 = 178.5 ≈ 179
              color: isHovered ? kBorderColor.withAlpha(179) : kBorderColor,
              borderRadius: BorderRadius.circular(10),
              border: isHovered
                  ? Border.all(color: kActionColor, width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ترويسة المجموعة
                Row(
                  children: [
                    // مقبض سحب المجموعة (Drag Handle)
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.drag_indicator,
                          //225 * 0.5 = 112.5 ≈ 113
                          color: widget.accentColor.withAlpha(113),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        onLongPress: () {
                          if (widget.groupName != 'مرجأة') {
                            showDialog(
                              context: context,
                              builder: (_) => RenameGroupDialog(
                                currentGroupName: widget.groupName,
                                groupActivities: widget.groupItems,
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.groupName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: widget.accentColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    formatDuration(totalGroupTime),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: widget.accentColor),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: widget.accentColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // المحتوى القابل للطي مع حركة ناعمة
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: !_isExpanded
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            const Divider(
                              color: _separatorColor,
                              height: 16,
                              thickness: 1,
                              indent: 8,
                              endIndent: 8,
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.groupItems.length,
                              separatorBuilder: (_, _) => const Divider(
                                color: _separatorColor,
                                height: 1,
                                indent: 8,
                                endIndent: 8,
                              ),
                              itemBuilder: (context, itemIndex) {
                                final Activity currentActivity =
                                    widget.groupItems[itemIndex];

                                return LongPressDraggable<Activity>(
                                  data: currentActivity,
                                  delay: const Duration(milliseconds: 200),
                                  feedback: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Material(
                                      elevation: 8,
                                      color: Colors.transparent,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.85,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: kBorderColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: kActionColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          currentActivity.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: ActivityTile(
                                      activity: currentActivity,
                                      allActivities: widget.allActivities,
                                    ),
                                  ),
                                  child: ActivityTile(
                                    activity: currentActivity,
                                    allActivities: widget.allActivities,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final List<Activity> allActivities;

  const ActivityTile({
    super.key,
    required this.activity,
    required this.allActivities,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArchived = activity.isArchived;

    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (_) => EditActivityDialog(
          activity: activity,
          allActivities: allActivities,
        ),
      ),
      onDoubleTap: () => showDialog(
        context: context,
        builder: (_) => ConfirmationMessageDialog(
          title: activity.isArchived
              ? 'تنشيط المشروع / النشاط'
              : 'تربيد مشروع / نشاط',
          actionText: activity.isArchived ? 'تنشيط' : 'تربيد',
          onAction: () {
            final dataProvider = objectBox;
            if (activity.isArchived) {
              dataProvider.unarchiveActivity(activity);
            } else {
              dataProvider.archiveActivity(activity);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  activity.isArchived ? 'نُشط المشروع' : 'تُربد المشروع بنجاح',
                  style: const TextStyle(color: kActionColor, fontSize: 16),
                ),
                backgroundColor: kContainerColor,
                duration: const Duration(milliseconds: 500),
              ),
            );
            Navigator.pop(context);
          },
        ),
      ),
      child: Opacity(
        opacity: isArchived ? 0.45 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  activity.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: isArchived ? TextDecoration.lineThrough : null,
                    color: isArchived ? Colors.grey : Colors.white,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  formatDuration(activity.timeSpent),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isArchived ? Colors.grey : kActionColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RenameGroupDialog extends StatefulWidget {
  final String currentGroupName;
  final List<Activity> groupActivities;

  const RenameGroupDialog({
    super.key,
    required this.currentGroupName,
    required this.groupActivities,
  });

  @override
  State<RenameGroupDialog> createState() => _RenameGroupDialogState();
}

class _RenameGroupDialogState extends State<RenameGroupDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentGroupName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.currentGroupName) {
      Navigator.pop(context);
      return;
    }

    final dataProvider = objectBox;
    for (var activity in widget.groupActivities) {
      dataProvider.updateActivity(
        activity,
        activity.name,
        activity.timeSpent,
        newName,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تغيير اسم المجموعة بنجاح',
          style: TextStyle(color: kActionColor, fontSize: 16),
        ),
        backgroundColor: kContainerColor,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kContainerColor,
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'تغيير اسم المجموعة',
          style: TextStyle(color: kActionColor),
        ),
      ),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          fillColor: kInnerBackGroundColor,
          filled: true,
          hintText: 'اسم المجموعة الجديد',
          hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        ElevatedButton(
          onPressed: _saveChanges,
          child: const SizedBox(
            width: 80,
            child: Center(child: Text("حفظ", style: TextStyle(fontSize: 16))),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(kTomatoColor),
          ),
          child: const SizedBox(
            width: 80,
            child: Center(child: Text("إلغاء", style: TextStyle(fontSize: 16))),
          ),
        ),
      ],
    );
  }
}

class AddActivityDialog extends StatefulWidget {
  const AddActivityDialog({super.key});

  @override
  State<AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<AddActivityDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  String _selectedGroup = 'مرجأة';

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    super.dispose();
  }

  void _addActivity() {
    final dataProvider = objectBox;
    final activities = dataProvider.getAllActivities();
    final name = _nameController.text.trim();

    if (name.isEmpty ||
        name == 'الاسم موجود بالفعل' ||
        name == 'أدخل اسم المشروع') {
      _nameController.text = 'أدخل اسم المشروع';
      return;
    }

    final bool nameExists = activities.any((a) => a.name == name);
    if (nameExists) {
      _nameController.text = 'الاسم موجود بالفعل';
      return;
    }

    final int duration = int.tryParse(_minController.text) ?? 0;
    dataProvider.addActivity(
      Activity(
        name: name,
        timeSpent: duration,
        group: _selectedGroup.trim().isEmpty ? 'مرجأة' : _selectedGroup.trim(),
      ),
    );

    Navigator.pop(context);
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
  }

  @override
  Widget build(BuildContext context) {
    final activities = objectBox.getAllActivities();

    return AlertDialog(
      backgroundColor: kContainerColor,
      actionsAlignment: MainAxisAlignment.spaceAround,
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'إضافة مشروع /  نشاط',
          style: TextStyle(color: kActionColor),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: kInnerBackGroundColor,
                filled: true,
                hintText: 'اسم المشروع',
                hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
              ),
            ),
            const SizedBox(height: 16),
            GroupAutocompleteField(
              initialValue: _selectedGroup,
              activities: activities,
              onChanged: (value) => _selectedGroup = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _minController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: kInnerBackGroundColor,
                filled: true,
                hintText: 'الدقائق',
                hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addActivity,
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
      ),
    );
  }
}

class EditActivityDialog extends StatefulWidget {
  final Activity activity;
  final List<Activity> allActivities;

  const EditActivityDialog({
    super.key,
    required this.activity,
    required this.allActivities,
  });

  @override
  State<EditActivityDialog> createState() => _EditActivityDialogState();
}

class _EditActivityDialogState extends State<EditActivityDialog> {
  late TextEditingController _nameController;
  late TextEditingController _minController;
  late TextEditingController _hourController;
  late TextEditingController _dayController;
  late String _selectedGroup;
  late int _newTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity.name);
    _minController = TextEditingController();
    _hourController = TextEditingController();
    _dayController = TextEditingController();
    _selectedGroup = widget.activity.group;
    _newTime = widget.activity.timeSpent;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minController.dispose();
    _hourController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final int days = int.tryParse(_dayController.text) ?? 0;
    final int hours = int.tryParse(_hourController.text) ?? 0;
    final int minutes = int.tryParse(_minController.text) ?? 0;
    _newTime = (days * 24 * 60) + (hours * 60) + minutes;
    if (_newTime == 0) _newTime = widget.activity.timeSpent;
  }

  void _saveChanges() {
    final dataProvider = objectBox;
    String newName = _nameController.text.trim();
    if (newName.isEmpty) newName = widget.activity.name;

    final bool nameExists = widget.allActivities.any(
      (a) =>
          a.name.toLowerCase() == newName.toLowerCase() &&
          a.id != widget.activity.id,
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

    _updateTime();

    dataProvider.updateActivity(
      widget.activity,
      newName,
      _newTime,
      _selectedGroup.trim().isEmpty ? 'مرجأة' : _selectedGroup.trim(),
    );

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
  }

  void _deleteActivity() {
    final dataProvider = objectBox;
    dataProvider.deleteActivity(widget.activity);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'حُذف المشروع',
          style: TextStyle(color: kTomatoColor, fontSize: 16),
        ),
        backgroundColor: kContainerColor,
        duration: Duration(milliseconds: 500),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kInnerBackGroundColor, // حل مشكلة الألوان
      actionsAlignment: MainAxisAlignment.spaceAround,
      title: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'تعديل مشروع /  نشاط',
          style: TextStyle(color: kActionColor),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              cursorColor: kActionColor,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: kContainerColor,
                filled: true,
                hintText: widget.activity.name,
                hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
              ),
            ),
            const SizedBox(height: 16),
            GroupAutocompleteField(
              initialValue: _selectedGroup,
              activities: widget.allActivities,
              onChanged: (value) => _selectedGroup = value,
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.activity.timeSpent != 0
                    ? formatDuration(widget.activity.timeSpent)
                    : "لم تبدأ بعد",
                style: const TextStyle(color: kActionColor),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: kContainerColor,
                      filled: true,
                      hintText: 'أيام',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _hourController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: kContainerColor,
                      filled: true,
                      hintText: 'ساعات',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: kContainerColor,
                      filled: true,
                      hintText: 'دقائق',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(64)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const SizedBox(
                    width: 80,
                    child: Center(
                      child: Text("تعديل", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _deleteActivity,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      kTomatoColor,
                    ),
                  ),
                  child: const SizedBox(
                    width: 80,
                    child: Center(
                      child: Text("حذف", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationMessageDialog extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const ConfirmationMessageDialog({
    super.key,
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kContainerColor, // حل مشكلة الألوان
      actionsAlignment: MainAxisAlignment.spaceAround,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(title, style: const TextStyle(color: kActionColor)),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: onAction,
              child: SizedBox(
                width: 80,
                child: Center(
                  child: Text(actionText, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(kTomatoColor),
              ),
              child: const SizedBox(
                width: 80,
                child: Center(
                  child: Text("إلغاء", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
