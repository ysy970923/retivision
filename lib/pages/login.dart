import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:retivision_v2/widgets/platform_alert_dialog.dart';

import '../models/auth.dart';

Widget _buildTextInput(
  String title,
  String hintText,
  TextEditingController _controller,
) {
  return Row(
    children: [
      Expanded(
        flex: 2,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: TextField(
          controller: _controller,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
      ),
    ],
  );
}

Future<void> submit(
    Auth auth, String username, String birthday, BuildContext context) async {
  var url = Uri.parse('https://yusangyoon.com/login');

  try {
    var response = await http
        .post(url, body: {'username': username, 'birthday': birthday});
    var res = jsonDecode(response.body);
    if (res['success']) {
      auth.logIn(res['userid'], res['username'], res['birthday']);
    } else {
      PlatformAlertDialog(
        title: '로그인에 실패했습니다.',
        content: '로그인 서버에 문제가 발생했습니다.',
        defaultActionText: '네',
      ).show(context);
    }
  } catch (e) {
    PlatformAlertDialog(
      title: '로그인에 실패했습니다.',
      content: '인터넷 연결에 문제가 있습니다.',
      defaultActionText: '네',
    ).show(context);
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final nameController = TextEditingController();
  final birthdayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Auth auth = Provider.of<Auth>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Retivision'),
          elevation: 2.0,
        ),
        body: Center(
          child: SizedBox(
            height: height * 0.4,
            width: width * 0.5,
            child: Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTextInput('이름', 'ex) 홍길동', nameController),
                    _buildTextInput('생년월일', 'ex) 000000', birthdayController),
                    ElevatedButton(
                      onPressed: () => submit(auth, nameController.text,
                          birthdayController.text, context),
                      child: const Text('시작'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
