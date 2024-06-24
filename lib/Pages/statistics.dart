import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

import 'package:provider/provider.dart';
import 'package:salad_of_achievement/utilities/const.dart';

import '../DB/models/data_model.dart';
import '../DB/models/object_box.dart';

List<GroupedSessions> lastWeek = [];
bool isSwitched = true;
int maxValue = 1;

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  void getMax(List<GroupedSessions> lastWeek, int maxStar) {
    for (int i = 0; i < lastWeek.length; i++) {
      if (lastWeek[i].totalMinutes > maxValue) {
        maxValue = lastWeek[i].totalMinutes;
      }
    }

    if (maxStar > maxValue) {
      maxValue = maxStar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context);

    lastWeek = dataProvider.getLastWeek();
    dataProvider.getUserStatistics();

    getMax(lastWeek, dataProvider.star3);
    int averageWeek = dataProvider.averageForWeek(lastWeek);
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text('إحصائيات الاستخدام'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: SingleChildScrollView(
          child: Column(
            children: [
              MostActiveDay(height * 0.1359375, UserStatistics.mostProductiveDate, UserStatistics.mostProductiveDay),
              AverageProductivity(height * 0.26328125, UserStatistics.averageDailyProductivity.toInt(), averageWeek),
              AverageGraph(height * 0.4203125, lastWeek),
              FavoriteFruit(height * 0.7171875, dataProvider.getAllFruitUsage()),
            ],
          ),
        ));
  }
}

class MostActiveDay extends StatelessWidget {
  final double height;
  final String date;
  final int minutes;
  const MostActiveDay(this.height, this.date, this.minutes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBorderColor,
            borderRadius: BorderRadius.circular(10),
          ),
          height: height,
          width: double.infinity,
          child: minutes != 0
              ? Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('اليوم الأكثر إنجازاً', style: Theme.of(context).textTheme.bodyMedium!),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(date, style: Theme.of(context).textTheme.bodySmall!),
                    Text('$minutes دقيقة', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor))
                  ])
                ])
              : FittedBox(child: Text(date, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: kActionColor))),
        ));
  }
}

class AverageProductivity extends StatelessWidget {
  final double height;
  final int overAllAverage;
  final int averageWeek;

  const AverageProductivity(this.height, this.overAllAverage, this.averageWeek, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kBorderColor,
            borderRadius: BorderRadius.circular(10),
          ),
          height: height,
          width: double.infinity,
          child: overAllAverage != 0
              ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  //النصوص
                  Text('متوسط إنجازك اليومي', style: Theme.of(context).textTheme.bodyMedium!),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("منذ بدء استخدام التطبيق", style: Theme.of(context).textTheme.bodySmall!),
                    Text('$overAllAverage دقيقة', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor))
                  ]),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text("خلال آخر 7 أيام عمل", style: Theme.of(context).textTheme.bodySmall!),
                    Text('$averageWeek دقيقة', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor))
                  ]),

                  FittedBox(
                      child: Text('المتوسط لا يشمل الأيام التي لم تستخدم فيها التطبيق',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.5)))),
                ])
              : Center(
                  child: Flexible(
                      child: Text(
                          "لا تَزُولُ قَدَمَا عَبْدٍ يَوْمَ القِيَامَةِ حَتَّى يُسْأَلَ عَنْ عُمُرِهِ فِيمَا أَفْنَاهُ، وَعَنْ عِلْمِهِ فِيمَ فَعَلَ، وَعَنْ مَالِهِ مِنْ أَيْنَ اكْتَسَبَهُ وَفِيمَ أَنْفَقَهُ، وَعَنْ جِسْمِهِ فِيمَ أَبْلَاهُ",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor))),
                ),
        ));
  }
}

class AverageGraph extends StatelessWidget {
  const AverageGraph(this.height, this.lastWeek, {super.key});
  final double height;
  final List<GroupedSessions> lastWeek;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBorderColor,
              borderRadius: BorderRadius.circular(10),
            ),
            height: height,
            width: double.infinity,
            child: lastWeek.isNotEmpty
                ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    //النصوص
                    Expanded(child: FittedBox(child: Text('معدل الإنجاز خلال آخر 7 أيام', style: Theme.of(context).textTheme.bodyMedium!))),
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                          itemCount: lastWeek.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: width / (lastWeek.length + 1),
                              child: Column(
                                children: [
                                  FittedBox(child: Text(lastWeek[index].totalMinutes.toString(), style: Theme.of(context).textTheme.bodySmall!)),
                                  SizedBox(width: min(width / (lastWeek.length + 1), 60), height: height * 0.5, child: NewWidget(lastWeek[index].totalMinutes)),
                                  FittedBox(
                                      child: FittedBox(
                                    child: Text(" ${lastWeek[index].date.split("/")[2]}/${lastWeek[index].date.split("/")[1]} ",
                                        style: Theme.of(context).textTheme.bodySmall!),
                                  )),
                                  FittedBox(child: Text(" ${lastWeek[index].dayName} ", style: Theme.of(context).textTheme.bodySmall!)),
                                ],
                              ),
                            );
                          }),
                    )
                  ])
                : Center(
                    child: Flexible(
                        child: Text("اقْتَرَبَ لِلنَّاسِ حِسَابُهُمْ وَهُمْ فِي غَفْلَةٍ مُعْرِضُونَ",
                            textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor))))));
  }
}

class NewWidget extends StatelessWidget {
  const NewWidget(this.value, {super.key});
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FAProgressBar(
          direction: Axis.vertical,
          verticalDirection: VerticalDirection.up,
          currentValue: value.toDouble(),
          progressColor: kActionColor,
          backgroundColor: kBackGroundColor,
          maxValue: maxValue.toDouble()),
    );
  }
}

bool condtion = true;

double count = 1;

class FavoriteFruit extends StatelessWidget {
  const FavoriteFruit(this.height, this.list, {super.key});
  final double height;
  final List<FruitUsage> list;

  void getCount(List<FruitUsage> list) {
    count = 0;
    for (int i = 0; i < list.length; i++) {
      count += list[i].usageCount;
    }
  }

  void sortList(List<FruitUsage> list) {
    list.sort((a, b) => b.usageCount.compareTo(a.usageCount));
  }

  @override
  Widget build(BuildContext context) {
    getCount(list);
    sortList(list);
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kBorderColor,
              borderRadius: BorderRadius.circular(10),
            ),
            height: height,
            width: double.infinity,
            child: condtion
                ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    //النصوص
                    FittedBox(child: Text('خضرواتك المفضلة', style: Theme.of(context).textTheme.bodyMedium!)),
                    FittedBox(
                        child: Text('ترتيب انواع الجلسات حسب عدد مرات الاستخدام',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.5)))),
                    Expanded(
                        child: ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: SizedBox(height: 50, width: 50, child: fruits[list[index].id.toString()]!.first)),
                                Expanded(
                                    child: LinearProgressIndicator(
                                        value: list[index].usageCount / count, minHeight: 20, valueColor: const AlwaysStoppedAnimation<Color>(kActionColor))),
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(list[index].usageCount.toString(), style: Theme.of(context).textTheme.bodySmall!))
                              ]);
                            })),
                    FittedBox(
                        child: Text(count == 0 ? "لم تستخدم الخضروات بعد" : "المجموع: ${count.toInt()} مرات",
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white.withOpacity(0.5)))),
                  ])
                : Center(
                    child: Flexible(
                        child: Text(
                            "إنَّما الأعمالُ بالنِّيَّاتِ وإنَّما لِكلِّ امرئٍ ما نوى فمن كانت هجرتُهُ إلى اللَّهِ ورسولِهِ فَهجرتُهُ إلى اللَّهِ ورسولِهِ ومن كانت هجرتُهُ إلى دنيا يصيبُها أو امرأةٍ ينْكحُها فَهجرتُهُ إلى ما هاجرَ إليْهِ",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor))))));
  }
}
