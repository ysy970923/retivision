import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:retivision_v2/pages/calibration.dart';
import 'package:retivision_v2/pages/my_result.dart';
import 'package:retivision_v2/global.dart';
import '../models/result.dart';
import '../tts.dart';

import '../models/auth.dart';

class Home extends StatefulWidget {
  static const routeName = 'home-page';
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TTS tts = TTS(() {});

  Text _buildInfoText(String info) {
    return Text(
      info,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final result = Provider.of<Result>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retivision'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.file_copy,
                size: 30,
              ),
              title: const Text(
                '기록 보기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onTap: () => Navigator.of(context).pushNamed(MyResult.routeName),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                size: 30,
              ),
              title: const Text(
                '로그아웃',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onTap: () => auth.logOut(),
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('현재 사용자: ${auth.username}'),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo[600],
                    fixedSize: const Size(200, 100),
                    textStyle: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('왼쪽 검사'),
                  onPressed: () {
                    result.leftRight = 'left';
                    Navigator.of(context).pushNamed(Calibration.routeName);
                  },
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo[600],
                    fixedSize: const Size(200, 100),
                    textStyle: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('오른쪽 검사'),
                  onPressed: () {
                    result.leftRight = 'right';
                    Navigator.of(context).pushNamed(Calibration.routeName);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
