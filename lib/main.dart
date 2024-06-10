import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/DB/models/object_box.dart';
import 'package:salad_of_achievement/utilities/const.dart';
import 'Pages/test.dart';

/*
ضف خاصة تحويل تحويل الوقت لطريقة الي أبيها مع قابلية للنسخ
تعديل طريقة عرض النجوم
*/

late ObjectBoxState objectBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBoxState.create();

  runApp(ChangeNotifierProvider(create: (_) => objectBox, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale("ar", "SA")],
      locale: const Locale("ar", "SA"),
      theme: myTheme(),
      initialRoute: '/',
      // initialRoute: '/history',
      routes: {
        '/': (context) => const TestPage(),
        // '/': (context) => const MainPage(),
        // '/newSession': (context) => const AddNewSession(),
        // '/history': (context) => const AppHistoryPAge(),
        // '/activity': (context) => const AppActivityPage(),
        // '/settings': (context) => const AppSettingsPage(),
        // '/activeSection': (context) => const ActiveSectionPage(),
      },
    );
  }

  ThemeData myTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: "alfont",
    ).copyWith(
        scaffoldBackgroundColor: kBackGroundColor,
        primaryColor: kBackGroundColor,
        cardColor: kContainerColor,
        canvasColor: kContainerColor,
        primaryColorDark: kBackGroundColor,
        iconTheme: const IconThemeData(color: kActionColor),
        appBarTheme: const AppBarTheme(
            backgroundColor: kContainerColor,
            elevation: 0,
            iconTheme: IconThemeData(color: kActionColor),
            titleTextStyle: TextStyle(color: kActionColor, fontSize: 28)),
        inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            labelStyle: TextStyle(color: Colors.black),
            hintStyle: TextStyle(color: Colors.black),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1))),
        bottomAppBarTheme: const BottomAppBarTheme(color: kContainerColor, elevation: 0, padding: EdgeInsets.all(8)),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: kWhiteColor, fontSize: 28), bodySmall: TextStyle(color: kWhiteColor, fontSize: 18)),
        listTileTheme: const ListTileThemeData(minLeadingWidth: 32, contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 8)),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                foregroundColor: kWhiteColor,
                backgroundColor: kActionColor,
                minimumSize: const Size(88, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))))),
        switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all<Color>(kActionColor),
            trackColor: MaterialStateProperty.all<Color>(kContainerColor),
            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent)),
        dialogTheme: DialogTheme(
            backgroundColor: kBackGroundColor,
            titleTextStyle: const TextStyle(color: kActionColor, fontSize: 32),
            contentTextStyle: const TextStyle(color: kWhiteColor, fontSize: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 0));
  }
}
