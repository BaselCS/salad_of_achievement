import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logical/provider/provider.dart';
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
      const Text("حدد عدد الدقائق لكل تقييم"),
      const Spacer(),
      const MySlider(1),
      const MySlider(2),
      const MySlider(3),
      const Spacer(),
      Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.001, color: Colors.black.withOpacity(0.5)),
      const Spacer(),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text("تشغيل تلقائي"), MySwitch()]),
      const Spacer(),
      Container(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.001, color: Colors.black.withOpacity(0.5)),
    ]);
  }
}

//يغير لون زر
class MySwitch extends StatefulWidget {
  const MySwitch({
    super.key,
  });

  @override
  State<MySwitch> createState() => _MySwitchState();
}

class _MySwitchState extends State<MySwitch> {
  bool isSwitched = true;
  @override
  Widget build(BuildContext context) {
    return Switch(
        value: isSwitched,
        trackOutlineColor: isSwitched ? MaterialStateProperty.all<Color>(kActionColor) : MaterialStateProperty.all<Color>(kContainerColor),
        onChanged: (value) {
          setState(() {
            isSwitched = value;
          });
        });
  }
}

class Spacer extends StatelessWidget {
  const Spacer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.01);
  }
}

class MySlider extends StatelessWidget {
  final double startValue;
  const MySlider(this.startValue, {super.key});

  @override
  Widget build(BuildContext context) {
    final DataProvider dataProvider = Provider.of<DataProvider>(context); // Access the provider

    int currentSliderValue = startValue == 1
        ? dataProvider.star1
        : startValue == 2
            ? dataProvider.star2
            : dataProvider.star3;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          FittedBox(
              child: startValue == 3
                  ? const Stars(isStar1: true, isStar2: true, isStar3: true)
                  : startValue == 2
                      ? const Stars(isStar1: true, isStar2: true)
                      : const Stars(isStar1: true)),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.60,
              child: Slider(
                  inactiveColor: kContainerColor,
                  activeColor: kActionColor,
                  min: 20,
                  max: 480,
                  value: startValue == 1
                      ? dataProvider.star1.toDouble()
                      : startValue == 2
                          ? dataProvider.star2.toDouble()
                          : dataProvider.star3.toDouble(),
                  divisions: 48,
                  onChanged: (double value) {
                    switch (startValue) {
                      case 1:
                        dataProvider.setStar1(value.toInt());
                        break;
                      case 2:
                        dataProvider.setStar2(value.toInt());
                        break;
                      case 3:
                        dataProvider.setStar3(value.toInt());
                        break;
                    }
                  })),
          SizedBox(width: MediaQuery.of(context).size.width * 0.15, child: Center(child: Text(currentSliderValue.toString())))
        ]));
  }
}
