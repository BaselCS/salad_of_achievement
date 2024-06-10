// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:salad_of_achievement/logical/models/data_model.dart';

// import '../logical/provider/provider.dart';
// import '../utilities/const.dart';
// import '../utilities/my_circular_count_down_timer.dart';

// CountDownController controller = CountDownController();
// Image theImage = tomato;
// Color theColor = kTomatoColor;
// int theTime = 0;
// int saveTime = 0;

// class ActiveSectionPage extends StatelessWidget {
//   const ActiveSectionPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Object? time = ModalRoute.of(context)!.settings.arguments;
//     theImage = fruits[time.toString()]![0];
//     theColor = fruits[time.toString()]![1];
//     theTime = int.parse(time.toString());
//     return const Scaffold(backgroundColor: kBackGroundColor, body: Body());
//   }
// }

// //يغير الأيقونة بس
// class Body extends StatefulWidget {
//   const Body({super.key});

//   @override
//   State<Body> createState() => _BodyState();
// }

// class _BodyState extends State<Body> {
//   IconData theIcon = Icons.pause;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child:
//             Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//           const CountDownTimer(),
//           const ActivityNameMenu(),
//           CircleAvatar(
//               backgroundColor: theColor,
//               radius: 30,
//               child: IconButton(
//                   onPressed: () {
//                     if (controller.isPaused) {
//                       theIcon = Icons.pause;
//                       controller.resume();
//                     } else {
//                       theIcon = Icons.play_arrow;
//                       controller.pause();
//                     }
//                     setState(() {});
//                   },
//                   icon: Icon(theIcon, color: Colors.white, size: 30))),
//           Container(
//               clipBehavior: Clip.antiAlias,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16.0),
//                   color: Colors.black),
//               child: const CancelButton()),
//         ]));
//   }
// }

// class ActivityNameMenu extends StatefulWidget {
//   const ActivityNameMenu({
//     super.key,
//   });

//   @override
//   State<ActivityNameMenu> createState() => _ActivityNameMenuState();
// }

// String? activityName;

// class _ActivityNameMenuState extends State<ActivityNameMenu> {
//   @override
//   Widget build(BuildContext context) {
//     DataProvider dataProvider = Provider.of<DataProvider>(context);
//     // dataProvider.activity.isNotEmpty
//     //     ? activityName = dataProvider.activity.firstOrNull!.name!
//     //     : '';
//     return Container(
//         padding: const EdgeInsets.all(4.0),
//         width: MediaQuery.of(context).size.width * 0.4,
//         height: MediaQuery.of(context).size.height * 0.05,
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16.0), color: kContainerColor),
//         child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//                 value: activityName,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     activityName = newValue!;
//                   });
//                 },
//                 items: dataProvider.activity
//                     .map<DropdownMenuItem<String>>((Activity value) {
//                   return DropdownMenuItem<String>(
//                     value: value.name!,
//                     child: Text(value.name!,
//                         style: Theme.of(context).textTheme.bodySmall),
//                   );
//                 }).toList())));
//   }
// }

// class CancelButton extends StatelessWidget {
//   const CancelButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//         onPressed: () {
//           showDialog(
//               context: context,
//               builder: (context1) {
//                 return AlertDialog(
//                     actionsAlignment: MainAxisAlignment.spaceAround,
//                     content: const Text('هل أنت متأكد من إلغاء الجلسة؟'),
//                     actions: [
//                       InkWell(
//                           onTap: () {
//                             Navigator.pop(context1);
//                           },
//                           child: Container(
//                               clipBehavior: Clip.antiAlias,
//                               padding: const EdgeInsets.all(4.0),
//                               width: MediaQuery.of(context1).size.width * 0.15,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(4.0),
//                                   color: kContainerColor),
//                               child: Center(
//                                   child: Text("لا",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!)))),
//                       InkWell(
//                           onTap: () {
//                             Navigator.pop(context);
//                             Navigator.pop(context);
//                           },
//                           child: Container(
//                               clipBehavior: Clip.antiAlias,
//                               padding: const EdgeInsets.all(4.0),
//                               width: MediaQuery.of(context1).size.width * 0.15,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(4.0),
//                                   color: Colors.red),
//                               child: Center(
//                                   child: Text("نعم",
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodySmall!)))),
//                     ]);
//               });
//         },
//         child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   GestureDetector(
//                       child: const CircleAvatar(
//                           radius: 15,
//                           backgroundColor: Colors.black,
//                           child: Icon(Icons.cancel, color: Colors.red))),
//                   Text('إلغاء الجلسة ',
//                       style: Theme.of(context).textTheme.bodySmall!)
//                 ])));
//   }
// }

// // class SaveButton extends StatelessWidget {
// //   const SaveButton({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return ElevatedButton(
// //       onPressed: () {},
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 4),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text('حفظ الجلسة ', style: Theme.of(context).textTheme.bodySmall!),
// //             CircleAvatar(radius: 15, backgroundColor: Colors.black.withOpacity(0.5), child: Text(saveTime.toString())),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// class CountDownTimer extends StatelessWidget {
//   const CountDownTimer({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     DataProvider dataProvider =
//         Provider.of<DataProvider>(context, listen: false);

//     double size = min(MediaQuery.of(context).size.width * 0.8,
//         MediaQuery.of(context).size.height * 0.8);
//     return MyCircularCountDownTimer(
//       // duration: theTime * 60,
//       duration: theTime,
//       isReverse: true,
//       fillColor: theColor, //لون الحلقة
//       height: size,
//       width: size,
//       strokeWidth: 10, //عرض الحلقة
//       ringColor: Colors.black.withOpacity(0.5),
//       autoStart: true,
//       controller: controller,
//       onComplete: () {
//         dataProvider.setDoneMinutes(theTime, activityName);
//         Navigator.pop(context);
//       },
//       onChange: (string) {
//         if (string != "$theTime:00") {
//           switch (string) {
//             case '50:00':
//               saveTime = 50;
//             case '40:00':
//               saveTime = 40;
//             case '30:00':
//               saveTime = 30;
//             case '25:00':
//               saveTime = 25;
//             case '20:00':
//               saveTime = 20;
//             case '10:00':
//               saveTime = 10;
//             case '05:00':
//               saveTime = 5;
//           }
//         }
//       },
//       child: theImage,
//     );
//   }
// }
