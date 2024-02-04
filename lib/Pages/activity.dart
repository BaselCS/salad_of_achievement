import 'package:flutter/material.dart';

import '../utilities/const.dart';

class AppActivityPage extends StatelessWidget {
  const AppActivityPage({super.key});

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
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            tileColor: kBorderColor,
            onTap: () {},
            leading: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onChanged: (String? newValue) {},
                  items: <String>['One', 'Two'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList()),
            ),
            title: Padding(padding: const EdgeInsets.only(right: 8), child: Text('برمجة', style: Theme.of(context).textTheme.bodySmall)),
            trailing: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text('٣أ ،٤ي ، ١٦س ، ٣٠د', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor))));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(color: kWhiteColor.withOpacity(0.5), width: MediaQuery.of(context).size.width, height: 1);
      },
      itemCount: 10,
    );
  }
}
