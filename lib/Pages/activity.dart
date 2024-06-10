// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// import '../logical/provider/provider.dart';
// import '../utilities/const.dart';

// class AppActivityPage extends StatelessWidget {
//   const AppActivityPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: kInnerBackGroundColor,
//         appBar: AppBar(
//             centerTitle: true,
//             title: const FittedBox(fit: BoxFit.fill, child: Text('أنشطة و مشروعات')),
//             leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 })),
//         body: const Body(),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//         floatingActionButton: const AddActivity());
//   }
// }

// class AddActivity extends StatelessWidget {
//   const AddActivity({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     DataProvider dataProvider = Provider.of<DataProvider>(context);
//     TextEditingController controller = TextEditingController();
//     TextEditingController controllerMin = TextEditingController();
//     return FloatingActionButton(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
//         onPressed: () {
//           showDialog(
//               context: context,
//               builder: (context1) {
//                 return AlertDialog(
//                   actionsAlignment: MainAxisAlignment.spaceAround,
//                   title: const FittedBox(child: Text('إضافة مشروع /  نشاط', style: TextStyle(color: kActionColor))),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       TextField(
//                           controller: controller,
//                           autofocus: true,
//                           decoration: InputDecoration(
//                               fillColor: kContainerColor, filled: true, hintText: 'اسم المشروع', hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)))),
//                       const SizedBox(width: 16),
//                       TextField(
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                           controller: controllerMin,
//                           autofocus: true,
//                           decoration: InputDecoration(
//                               fillColor: kContainerColor, filled: true, hintText: 'الدقائق', hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)))),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                           onPressed: () {
//                             int duration = int.tryParse(controllerMin.text) ?? 0;
//                             dataProvider.addActivity(controller.text, duration);
//                             controller.clear();
//                             controllerMin.clear();
//                             Navigator.pop(context1);
//                           },
//                           child: const SizedBox(
//                               width: 80,
//                               child: Center(
//                                   child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 child: Text("إضافة", style: TextStyle(fontSize: 16)),
//                               ))))
//                     ],
//                   ),
//                 );
//               });
//         },
//         backgroundColor: kActionColor,
//         child: const Icon(Icons.add));
//   }
// }

// class Body extends StatelessWidget {
//   const Body({super.key});

//   String formatDuration(int durationInMinutes) {
//     final int days = durationInMinutes ~/ (24 * 60);
//     final int hours = (durationInMinutes % (24 * 60)) ~/ 60;
//     final int minutes = durationInMinutes % 60;

//     String formattedDuration = '';

//     if (minutes > 0) {
//       formattedDuration += '$minutes د ';
//     }
//     if (hours > 0) {
//       formattedDuration += '$hours س ';
//     }
//     if (days > 0) {
//       formattedDuration += '$days أ ';
//     }

//     return formattedDuration.trim();
//   }

//   @override
//   Widget build(BuildContext context) {
//     DataProvider dataProvider = Provider.of<DataProvider>(context);
//     TextEditingController controllerName = TextEditingController();
//     TextEditingController controllerMin = TextEditingController();

//     return ListView.separated(
//       itemCount: dataProvider.activity.length,
//       itemBuilder: (BuildContext context, int index) {
//         return InkWell(
//             onTap: () {
//               //delete activity
//               // dataProvider.deleteActivity(dataProvider.activity[index]);
//               showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       actionsAlignment: MainAxisAlignment.spaceAround,
//                       content: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           TextField(
//                               autofocus: true,
//                               controller: controllerName,
//                               decoration: InputDecoration(
//                                   fillColor: kContainerColor,
//                                   filled: true,
//                                   hintText: 'تعديل اسم المشروع : ${dataProvider.activity[index].name}',
//                                   hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)))),
//                           const SizedBox(height: 32),
//                           TextField(
//                               controller: controllerMin,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                               autofocus: true,
//                               decoration: InputDecoration(
//                                   fillColor: kContainerColor,
//                                   filled: true,
//                                   hintText: 'تعديل الوقت : ${dataProvider.activity[index].totalTime} دقيقة',
//                                   hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)))),
//                           const SizedBox(height: 32),
//                           ElevatedButton(
//                               onPressed: () {
//                                 int duration = int.tryParse(controllerMin.text) ?? 0;
//                                 dataProvider.editActivity(dataProvider.activity[index].name!, dataProvider.activity[index].totalTime!,
//                                     name: controllerName.text, newDuration: duration);
//                                 controllerName.clear();
//                                 controllerMin.clear();
//                                 Navigator.pop(context);
//                               },
//                               child: const SizedBox(
//                                   width: 80,
//                                   child: Center(
//                                       child: Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                     child: Text("تأكيد", style: TextStyle(fontSize: 16)),
//                                   )))),
//                           const SizedBox(height: 32),
//                           ElevatedButton(
//                               onPressed: () {
//                                 dataProvider.deleteActivity(dataProvider.activity[index]);
//                                 Navigator.pop(context);
//                               },
//                               style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(kDragonColor)),
//                               child: const SizedBox(
//                                   width: 80,
//                                   child: Center(
//                                       child: Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                     child: Text("حذف", style: TextStyle(fontSize: 16)),
//                                   ))))
//                         ],
//                       ),
//                     );
//                   });
//             },
//             child: Container(
//                 color: kBorderColor, // Set tile color here
//                 child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                   Padding(
//                     padding: const EdgeInsets.only(right: 16),
//                     child: Text(
//                       dataProvider.activity[index].name!,
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                   ),
//                   SizedBox(
//                       width: 150,
//                       child: Padding(
//                           padding: const EdgeInsets.only(left: 8),
//                           child: Text(
//                             textAlign: TextAlign.end,
//                             formatDuration(dataProvider.activity[index].totalTime!),
//                             style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kActionColor),
//                           )))
//                 ])));
//       },
//       separatorBuilder: (BuildContext context, int index) {
//         return Divider(
//           color: kWhiteColor.withOpacity(0.5),
//           height: 1,
//         );
//       },
//     );
//   }
// }
