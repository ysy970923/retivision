import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retivision_v2/components/camera_box.dart';
import 'package:retivision_v2/pages/home.dart';
import 'package:retivision_v2/pages/test_landolt.dart';

import 'login.dart';
// import '../homePage.dart';
import '../../models/auth.dart';

class Landing extends StatefulWidget {
  static const routeName = 'landing';
  const Landing({Key? key}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    // if (auth.login) {
    //   print("login");
    //   setState(() {});
    // }
    // return const CameraBox();
    if (auth.login) {
      return const Home();
    } else {
      return const Login();
    }
  }
}
