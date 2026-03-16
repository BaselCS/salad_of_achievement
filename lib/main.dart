import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:salad_of_achievement/DB/models/object_box.dart';
import 'package:salad_of_achievement/utilities/const.dart';
import 'package:salad_of_achievement/logical/notification.dart';
import 'Pages/active_session.dart';
import 'Pages/activity.dart';
import 'Pages/database_viewer.dart';

import 'Pages/history.dart';
import 'Pages/main_page.dart';
import 'Pages/new_session.dart';
import 'Pages/notification_test.dart';
import 'Pages/settings.dart';
import 'Pages/statistics.dart';

// flutter emulators --launch Pixel_API_35

// طريقة حفظ البيانات
late ObjectBoxState objectBox;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications (permissions will be handled when app starts)
  await NotificationHelper.initializeNotifications();

  objectBox = await ObjectBoxState.create();
  //عشان أخلي التقويم الهجري و بأرقام عربية
  HijriCalendar.setLocal('ar');

  //دمجة مع الجالب
  //provider
  runApp(ChangeNotifierProvider(create: (_) => objectBox, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,

      ///[قسم اللغة]
      localizationsDelegates: const [GlobalCupertinoLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
      supportedLocales: const [Locale("ar", "SA")],
      locale: const Locale("ar", "SA"),

      ///[قسم الألوان]
      theme: myTheme(),

      ///[قسم الصفحات]
      initialRoute: '/',
      routes: {
        '/': (_) => const MainPage(),
        '/statistics': (_) => const Statistics(),
        '/history': (_) => const AppHistoryPage(),
        '/activity': (_) => const AppActivityPage(),
        '/newSession': (_) => const AddNewSession(),
        '/notificationTest': (_) => const NotificationTestPage(),
        '/settings': (_) => const AppSettingsPage(),
        '/activeSection': (_) => const ActiveSectionPage(),
        '/databaseViewer': (_) => const DatabaseViewerPage(),
      },
    );
  }

  //للأمانة عفسه ما أنصح تسويها مره ثانية إلا لو تعلمت لها زين
  ThemeData myTheme() {
    return ThemeData(brightness: Brightness.dark, fontFamily: "alfont").copyWith(
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
        titleTextStyle: TextStyle(color: kActionColor, fontSize: 28),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 1)),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(color: kContainerColor, elevation: 0, padding: EdgeInsets.all(8)),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: kWhiteColor, fontSize: 28),
        bodySmall: TextStyle(color: kWhiteColor, fontSize: 18),
      ),
      listTileTheme: const ListTileThemeData(minLeadingWidth: 32, contentPadding: EdgeInsets.fromLTRB(8, 4, 8, 8)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: kWhiteColor,
          backgroundColor: kActionColor,
          minimumSize: const Size(88, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all<Color>(kActionColor),
        trackColor: WidgetStateProperty.all<Color>(kContainerColor),
        overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: kBackGroundColor,
        titleTextStyle: const TextStyle(color: kActionColor, fontSize: 32),
        contentTextStyle: const TextStyle(color: kWhiteColor, fontSize: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0,
      ),
    );
  }
}
