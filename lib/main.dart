import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retivision_v2/global.dart';
import 'package:retivision_v2/pages/calibration.dart';
import 'package:retivision_v2/pages/home.dart';
import 'package:retivision_v2/models/result.dart';
import 'package:retivision_v2/pages/mchart.dart';
import 'package:retivision_v2/pages/my_result.dart';
import 'package:retivision_v2/pages/test_landolt.dart';
import 'pages/test_grid.dart';

import 'pages/landing.dart';
import 'pages/home.dart';
import 'pages/note.dart';
import 'pages/test_hue.dart';
import 'models/auth.dart';
import 'pages/test_reading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(
          create: (_) => Auth(),
        ),
        Provider<Result>(
          create: (_) => Result(),
        ),
      ],
      child: MaterialApp(
        title: 'Retivision',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: Theme.of(context).textTheme.apply(
                fontSizeFactor: 2.0,
                fontSizeDelta: 2.0,
              ),
        ),
        home: const Landing(),
        routes: {
          Calibration.routeName: (context) => const Calibration(),
          TestGridPage.routeName: (context) => const TestGridPage(),
          Home.routeName: (context) => const Home(),
          Note.routeName: (context) => const Note(),
          TestHuePage.routeName: (context) => const TestHuePage(),
          TestReadingPage.routeName: (context) => const TestReadingPage(),
          MyResult.routeName: (context) => const MyResult(),
          TestLandoltPage.routeName: (context) => const TestLandoltPage(),
          TestMChartPage.routeName: (context) => const TestMChartPage(),
        },
      ),
    );
  }
}
