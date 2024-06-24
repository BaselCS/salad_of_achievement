import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../DB/models/object_box.dart';
import '../utilities/const.dart';

//ضف إعددات لمتى يحول اليوم
class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kInnerBackGroundColor,
        appBar: AppBar(
            centerTitle: true,
            title: const FittedBox(fit: BoxFit.fill, child: Text('سجل الجلسات')),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: const Body());
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Spacer(),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [Text("حدد عدد الدقائق لكل تقييم"), ReSet()],
      ),
      const Spacer(),
      const MySlider(1),
      const MySlider(2),
      const MySlider(3),
      const Spacer(),
      Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.001, color: Colors.black.withOpacity(0.5)),
      const Spacer(),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("بداية اليوم"), CustomCounter(btnRadius: 10)]),
      ),
      Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.001, color: Colors.black.withOpacity(0.5)),
      const Spacer(),
    ]);
  }
}

class ReSet extends StatelessWidget {
  const ReSet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kBackGroundColor.withOpacity(0.5), borderRadius: BorderRadius.circular(25)),
      child: IconButton(
          onPressed: () {
            final ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context, listen: false);
            dataProvider.setDefaultSettings();
          },
          icon: Icon(Icons.settings_backup_restore, color: kActionColor.withOpacity(0.5))),
    );
  }
}

class Spacer extends StatelessWidget {
  const Spacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.01);
  }
}

class MySlider extends StatelessWidget {
  final double starValue;
  const MySlider(this.starValue, {super.key});

  @override
  Widget build(BuildContext context) {
    final ObjectBoxState dataProvider = Provider.of<ObjectBoxState>(context); // Access the provider

    int currentSliderValue = starValue == 1
        ? dataProvider.star1
        : starValue == 2
            ? dataProvider.star2
            : dataProvider.star3;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      FittedBox(
          child: starValue == 3
              ? const Stars(isStar1: true, isStar2: true, isStar3: true)
              : starValue == 2
                  ? const Stars(isStar1: true, isStar2: true)
                  : const Stars(isStar1: true)),
      Expanded(
        child: Slider(
          inactiveColor: kContainerColor,
          activeColor: kActionColor,
          min: 20,
          max: 480,
          value: (starValue == 1
                  ? dataProvider.star1.toDouble()
                  : starValue == 2
                      ? dataProvider.star2.toDouble()
                      : dataProvider.star3.toDouble())
              .clamp(20.0, 480.0),
          onChanged: (double value) {
            switch (starValue) {
              case 1:
                dataProvider.updateStares(newStar1: value.toInt().clamp(20, 480));
                dataProvider.updateStares(newStar2: max(dataProvider.star2, dataProvider.star1 + 10).clamp(20, 480));
                dataProvider.updateStares(newStar3: max(dataProvider.star3, dataProvider.star2 + 10).clamp(20, 480));
                break;
              case 2:
                dataProvider.updateStares(newStar2: max(value.toInt(), dataProvider.star1).clamp(20, 480));
                break;
              case 3:
                dataProvider.updateStares(newStar3: max(value.toInt(), dataProvider.star2).clamp(20, 480));
                break;
            }
          },
        ),
      ),
      SizedBox(width: MediaQuery.of(context).size.width * 0.15, child: Center(child: Text(currentSliderValue.toString())))
    ]);
  }
}

class CustomCounter extends StatefulWidget {
  final double? btnRadius;
  const CustomCounter({Key? key, this.btnRadius}) : super(key: key);

  @override
  State<CustomCounter> createState() => _CustomCounterState();
}

class _CustomCounterState extends State<CustomCounter> {
  int _counter = 0;
  late ObjectBoxState dataProvider;

  void _incrementCounter() {
    setState(() {
      if (_counter < 23) {
        _counter++;
        dataProvider.setStartOfDay(_counter);
      }
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        dataProvider.setStartOfDay(_counter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dataProvider = Provider.of<ObjectBoxState>(context, listen: false);

    _counter = dataProvider.timeToRest.hour;
    return Tooltip(
      message: "عدد الساعات بعد منتصف الليل",
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: kActionColor), color: kBackGroundColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _decrementCounter,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: kActionColor,
                    borderRadius: BorderRadius.circular(widget.btnRadius ?? 2),
                  ),
                  child: const Icon(Icons.remove, color: kWhiteColor, size: 10),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                _counter < 10 ? "0$_counter" : "$_counter",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 15),
              GestureDetector(
                onTap: _incrementCounter,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: kActionColor,
                    borderRadius: BorderRadius.circular(widget.btnRadius ?? 2),
                  ),
                  child: const Icon(Icons.add, color: kWhiteColor, size: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

