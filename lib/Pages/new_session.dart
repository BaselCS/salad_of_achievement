import 'package:flutter/material.dart';
import 'package:salad_of_achievement/utilities/const.dart';

class AddNewSession extends StatelessWidget {
  const AddNewSession({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const FittedBox(fit: BoxFit.fill, child: Text('إضافة جلسة جديدة')),
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
    return const Center(
        child: Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
          children: [
            DropActivity(),
            SizedBox(height: 20),
            DropOfTime(),
          ],
        ),
        OkButton()
      ]),
    ));
  }
}

class DropActivity extends StatelessWidget {
  const DropActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: kContainerColor,
        width: MediaQuery.of(context).size.width * 0.8,
        child: DropdownButtonFormField<String>(
          hint: const FittedBox(fit: BoxFit.fill, child: Text('اختر نشاط / مشروع')),
          decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1))),
          onChanged: (String? newValue) {},
          items: listActivity.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ));
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
            hint: const FittedBox(fit: BoxFit.fill, child: Text('اختر طول الجلسة')),
            decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1))),
            onChanged: (value) {},
            items: fruits.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                  value: value,
                  child: Row(children: <Widget>[SizedBox(height: 60, width: 60, child: fruits[value]!.first), const SizedBox(width: 10), Text(value)]));
            }).toList()));
  }
}

class OkButton extends StatelessWidget {
  const OkButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
          color: kContainerColor,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text("أضف الجلسة", style: const TextTheme().bodySmall),
            ),
          ))),
    );
  }
}
