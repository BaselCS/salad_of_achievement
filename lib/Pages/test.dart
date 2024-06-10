import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/DB/models/object_box.dart';

import '../DB/models/data_model.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(child: Logo()),
            Expanded(child: MyHomePage()),
          ],
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final ObjectBoxState objectBoxState = Provider.of<ObjectBoxState>(context);
    return InkWell(
      onTap: () {
        objectBoxState.deleteAll();
        // addDummyData(objectBoxState);
      },
      child: const FlutterLogo(size: 600),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final objectBoxState = Provider.of<ObjectBoxState>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDataTable(
            'Sessions',
            ['ID', 'Date', 'Time Spent', 'Topic'],
            objectBoxState.getAllSessions().map((session) {
              return DataRow(cells: [
                DataCell(Text(session.id.toString())),
                DataCell(Text(DateFormat('yyyy-MM-dd').format(session.date))),
                DataCell(Text(session.timeSpent.toString())),
                DataCell(Text(session.topic)),
              ]);
            }).toList(),
          ),
          _buildDataTable(
            'Activities',
            ['ID', 'Name', 'Time Spent'],
            objectBoxState.getAllActivities().map((activity) {
              return DataRow(cells: [
                DataCell(Text(activity.id.toString())),
                DataCell(Text(activity.name)),
                DataCell(Text(activity.timeSpent.toString())),
              ]);
            }).toList(),
          ),
          Text(DateFormat('yyyy-MM-dd').format(UserStatistics.mostProductiveDate ?? DateTime.now())),
          Text(UserStatistics.averageDailyProductivity.round().toString()),
          _buildDataTable(
            'Fruit Usage',
            ['ID', 'Fruit Name', 'Time Spent', 'Usage Count'],
            objectBoxState.getAllFruitUsage().map((fruitUsage) {
              return DataRow(cells: [
                DataCell(Text(fruitUsage.id.toString())),
                DataCell(Text(fruitUsage.fruitName)),
                DataCell(Text(fruitUsage.timeSpent.toString())),
                DataCell(Text(fruitUsage.usageCount.toString())),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(String title, List<String> columnNames, List<DataRow> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columnNames.map((name) => DataColumn(label: Text(name))).toList(),
            rows: rows,
          ),
        ),
        const Divider(),
      ],
    );
  }
}

void addDummyData(ObjectBoxState objectBoxState) {
  // Adding dummy sessions
  objectBoxState.addSession(Session(
    date: DateUtils.dateOnly(DateTime.now()),
    timeSpent: 25,
    topic: 'Programming',
  ));

  // Adding dummy activities
  objectBoxState.addActivity(Activity(
    name: 'Coding',
    timeSpent: 60,
  ));
  objectBoxState.addActivity(Activity(
    name: 'Reading',
    timeSpent: 45,
  ));

  // Adding dummy fruit usage
  objectBoxState.addFruitUsage(FruitUsage(
    fruitName: 'Apple',
    timeSpent: 40,
    usageCount: 2,
  ));
  objectBoxState.addFruitUsage(FruitUsage(
    fruitName: 'Banana',
    timeSpent: 60,
    usageCount: 3,
  ));
}
