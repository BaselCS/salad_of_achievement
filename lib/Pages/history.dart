// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:salad_of_achievement/logical/provider/provider.dart';

// import '../utilities/const.dart';

// class AppHistoryPAge extends StatelessWidget {
//   const AppHistoryPAge({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: kInnerBackGroundColor,
//         appBar: AppBar(
//             centerTitle: true,
//             title: const FittedBox(fit: BoxFit.fill, child: Text('سجل الجلسات')),
//             leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 })),
//         body: const Body());
//   }
// }

// class Body extends StatelessWidget {
//   const Body({super.key});

//   @override
//   Widget build(BuildContext context) {
//     DataProvider dataProvider = Provider.of<DataProvider>(context);
//     return ListView.separated(
//       itemCount: dataProvider.history.length,
//       itemBuilder: (BuildContext context, int index) {
//         return ListTile(
//             tileColor: kBorderColor,
//             onTap: () {
//               print(dataProvider.history.elementAt(index));
//             },
//             leading: Expanded(
//               child: Container(
//                   decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(10))),
//                   width: 120,
//                   height: 40,
//                   padding: const EdgeInsets.all(5),
//                   child: Stars(
//                       isStar1: dataProvider.star1 < dataProvider.history.elementAt(index).todayTime!,
//                       isStar2: dataProvider.star2 < dataProvider.history.elementAt(index).todayTime!,
//                       isStar3: dataProvider.star3 < dataProvider.history.elementAt(index).todayTime!)),
//             ),
//             title: Text(dataProvider.history.elementAt(index).date!, style: Theme.of(context).textTheme.bodySmall),
//             trailing: Text("${dataProvider.history.elementAt(index).todayTime.toString()} دقيقة",
//                 style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor)));
//       },
//       separatorBuilder: (BuildContext context, int index) {
//         return Container(color: kWhiteColor.withOpacity(0.5), width: MediaQuery.of(context).size.width, height: 1);
//       },
//     );
//   }
// }
