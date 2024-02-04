import 'package:flutter/material.dart';

import '../logic/simple_data.dart';
import '../utilities/const.dart';

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

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
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

class MySlider extends StatefulWidget {
  final int startValue;
  const MySlider(this.startValue, {super.key});

  @override
  State<MySlider> createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  @override
  Widget build(BuildContext context) {
    int currentSliderValue = widget.startValue == 1
        ? SimpleData.star1.toInt()
        : widget.startValue == 2
            ? SimpleData.star2.toInt()
            : SimpleData.tootleMinutes.toInt();

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          FittedBox(
              child: widget.startValue == 3
                  ? const Stars(isStar1: true, isStar2: true, isStar3: true)
                  : widget.startValue == 2
                      ? const Stars(isStar1: true, isStar2: true)
                      : const Stars(isStar1: true)),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.60,
              child: Slider(
                  inactiveColor: kContainerColor,
                  activeColor: kActionColor,
                  min: 20,
                  max: 480,
                  value: widget.startValue == 1
                      ? SimpleData.star1
                      : widget.startValue == 2
                          ? SimpleData.star2
                          : SimpleData.tootleMinutes,
                  divisions: 48,
                  onChanged: (value) {
                    setState(() {
                      switch (widget.startValue) {
                        case 1:
                          SimpleData.star1 = value;
                          break;
                        case 2:
                          SimpleData.star2 = value;
                          break;
                        case 3:
                          SimpleData.tootleMinutes = value;
                          break;
                      }
                    });
                  })),
          SizedBox(width: MediaQuery.of(context).size.width * 0.15, child: Center(child: Text(currentSliderValue.toString())))
        ]));
  }
}
