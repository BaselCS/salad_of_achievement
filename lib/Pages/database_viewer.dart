import 'package:flutter/material.dart';
import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';
import '../utilities/const.dart';
import '../main.dart' show objectBox;

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInnerBackGroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('عارض قاعدة البيانات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الجلسات', icon: Icon(Icons.timer)),
            Tab(text: 'الأنشطة', icon: Icon(Icons.work)),
            Tab(text: 'الفواكه', icon: Icon(Icons.restaurant)),
            Tab(text: 'الإعدادات', icon: Icon(Icons.settings)),
          ],
          labelColor: kActionColor,
          unselectedLabelColor: kWhiteColor,
          indicatorColor: kActionColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const SessionsTab(),
          const ActivitiesTab(),
          const FruitUsageTab(),
          const SettingsTab(),
        ],
      ),
    );
  }
}

class SessionsTab extends StatelessWidget {
  const SessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = objectBox;
    List<Session> sessions = dataProvider.getAllSessions();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'إجمالي الجلسات: ${sessions.length}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: kActionColor),
          ),
        ),
        Expanded(
          child: sessions.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد جلسات',
                    style: TextStyle(color: kWhiteColor, fontSize: 18),
                  ),
                )
              : ListView.separated(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    Session session = sessions[index];
                    return Card(
                      color: kBorderColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ID: ${session.id}',
                                  style: const TextStyle(
                                    color: kActionColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'التاريخ: ${session.date}',
                                  style: const TextStyle(
                                    color: kWhiteColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الموضوع: ${session.activityName}',
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الوقت المستغرق: ${session.timeSpent} دقيقة',
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                ),
        ),
      ],
    );
  }
}

class ActivitiesTab extends StatelessWidget {
  const ActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = objectBox;
    List<Activity> activities = dataProvider.getAllActivities();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'إجمالي الأنشطة: ${activities.length}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: kActionColor),
          ),
        ),
        Expanded(
          child: activities.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد أنشطة',
                    style: TextStyle(color: kWhiteColor, fontSize: 18),
                  ),
                )
              : ListView.separated(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    Activity activity = activities[index];
                    return Card(
                      color: kBorderColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ID: ${activity.id}',
                                  style: const TextStyle(
                                    color: kActionColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.work, color: kActionColor),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الاسم: ${activity.name}',
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إجمالي الوقت: ${activity.timeSpent} دقيقة',
                              style: const TextStyle(
                                color: kWhiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                ),
        ),
      ],
    );
  }
}

class FruitUsageTab extends StatelessWidget {
  const FruitUsageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = objectBox;
    List<FruitUsage> fruitUsages = dataProvider.getAllFruitUsage();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'أنواع الفواكه: ${fruitUsages.length}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: kActionColor),
          ),
        ),
        Expanded(
          child: fruitUsages.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد فواكه مستخدمة',
                    style: TextStyle(color: kWhiteColor, fontSize: 18),
                  ),
                )
              : ListView.separated(
                  itemCount: fruitUsages.length,
                  itemBuilder: (context, index) {
                    FruitUsage fruitUsage = fruitUsages[index];
                    return Card(
                      color: kBorderColor,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kActionColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${fruitUsage.id}',
                                style: const TextStyle(
                                  color: kWhiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مدة الجلسة: ${fruitUsage.id} دقيقة',
                                    style: const TextStyle(
                                      color: kWhiteColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'عدد الاستخدامات: ${fruitUsage.usageCount}',
                                    style: const TextStyle(
                                      color: kActionColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.restaurant, color: kActionColor),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                ),
        ),
      ],
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = objectBox;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات الحالية',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: kActionColor),
          ),
          const SizedBox(height: 20),
          _buildSettingCard(
            icon: Icons.star,
            title: 'النجمة الأولى',
            value: '${dataProvider.star1} دقيقة',
            context: context,
          ),
          _buildSettingCard(
            icon: Icons.star,
            title: 'النجمة الثانية',
            value: '${dataProvider.star2} دقيقة',
            context: context,
          ),
          _buildSettingCard(
            icon: Icons.star,
            title: 'النجمة الثالثة',
            value: '${dataProvider.star3} دقيقة',
            context: context,
          ),
          _buildSettingCard(
            icon: Icons.schedule,
            title: 'وقت بداية اليوم',
            value: '${dataProvider.timeToRest.hour}:00',
            context: context,
          ),
          _buildSettingCard(
            icon: Icons.timer,
            title: 'الدقائق المكتملة اليوم',
            value: '${dataProvider.doneMinutes} دقيقة',
            context: context,
          ),
          _buildSettingCard(
            icon: Icons.calendar_today,
            title: 'تاريخ آخر إعادة تعيين',
            value:
                '${dataProvider.timeToRest.day}/${dataProvider.timeToRest.month}/${dataProvider.timeToRest.year}',
            context: context,
          ),
          const SizedBox(height: 20),
          // Database statistics
          _buildDatabaseStats(context, dataProvider),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Card(
      color: kBorderColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: kActionColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: kWhiteColor, fontSize: 16),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: kActionColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseStats(
    BuildContext context,
    ObjectBoxState dataProvider,
  ) {
    int totalSessions = dataProvider.getAllSessions().length;
    int totalActivities = dataProvider.getAllActivities().length;
    int totalFruits = dataProvider.getAllFruitUsage().length;

    int totalTimeSpent = dataProvider.getAllSessions().fold(
      0,
      (sum, session) => sum + session.timeSpent,
    );

    return Card(
      color: kContainerColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات قاعدة البيانات',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: kActionColor),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('الجلسات', totalSessions.toString()),
                _buildStatItem('الأنشطة', totalActivities.toString()),
                _buildStatItem('الفواكه', totalFruits.toString()),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: _buildStatItem('إجمالي الوقت', '$totalTimeSpent دقيقة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: kActionColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: kWhiteColor, fontSize: 14)),
      ],
    );
  }
}
