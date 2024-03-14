import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../logical/provider/provider.dart';
import '../utilities/const.dart';

class AppActivityPage extends StatelessWidget {
  const AppActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kInnerBackGroundColor,
        appBar: AppBar(
            centerTitle: true,
            title: const FittedBox(
                fit: BoxFit.fill, child: Text('أنشطة و مشروعات')),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: const Body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: const AddActivity());
  }
}

class AddActivity extends StatelessWidget {
  const AddActivity({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    TextEditingController controller = TextEditingController();
    TextEditingController controllerMin = TextEditingController();
    return FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context1) {
                return AlertDialog(
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  title: const Text('إضافة مشروع /  نشاط',
                      style: TextStyle(color: kActionColor)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: TextField(
                                  controller: controller,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                      fillColor: kContainerColor,
                                      filled: true,
                                      hintText: 'اسم المشروع / النشاط',
                                      hintStyle: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.25))))),
                          const SizedBox(width: 15),
                          Expanded(
                              child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: controllerMin,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                      fillColor: kContainerColor,
                                      filled: true,
                                      hintText: 'الدقائق',
                                      hintStyle: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.25))))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () {
                            int duration =
                                int.tryParse(controllerMin.text) ?? 0;
                            dataProvider.addActivity(controller.text, duration);
                            controller.clear();
                            controllerMin.clear();
                            Navigator.pop(context1);
                          },
                          child: const SizedBox(
                              width: 80,
                              child: Center(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text("إضافة",
                                    style: TextStyle(fontSize: 16)),
                              ))))
                    ],
                  ),
                );
              });
        },
        backgroundColor: kActionColor,
        child: const Icon(Icons.add));
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    DataProvider dataProvider = Provider.of<DataProvider>(context);
    return ListView.separated(
      itemCount: dataProvider.activity.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            tileColor: kBorderColor,
            onTap: () {
              //يمين حذف يسار تعديل
              // print("");
            },
            title: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(dataProvider.activity[index].name!,
                    style: Theme.of(context).textTheme.bodySmall)),
            trailing: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('${dataProvider.activity[index].totalTime!} دقيقة',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: kActionColor))));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
            color: kWhiteColor.withOpacity(0.5),
            width: MediaQuery.of(context).size.width,
            height: 1);
      },
    );
  }
}
