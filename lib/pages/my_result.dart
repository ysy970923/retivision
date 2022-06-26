import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/result.dart';
import '/models/auth.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();
  return directory!.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/result.txt');
}

class MyResult extends StatefulWidget {
  static const routeName = 'my-result-page';
  const MyResult({Key? key}) : super(key: key);

  @override
  _MyResultState createState() => _MyResultState();
}

class _MyResultState extends State<MyResult> {
  Widget buildResultBox(Result result, width) {
    return Card(
      child: ListTile(
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(result.timerecord!
                      .substring(0, 19)
                      .replaceFirst('T', ' ')),
                  const SizedBox(height: 20),
                  Text('정답률: ${accRate(result)}%'),
                  const SizedBox(height: 20),
                  _buildSmallGrids(result, width * 0.1),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                      const SizedBox(height: 20),
                      Text('색각 테스트 점수 (빨강): ${result.huePoints![0]} (/100)'),
                      const SizedBox(height: 20),
                      Text('색각 테스트 점수 (초록): ${result.huePoints![1]} (/100)'),
                      const SizedBox(height: 20),
                      Text('색각 테스트 점수 (파랑): ${result.huePoints![2]} (/100)'),
                      const SizedBox(height: 20),
                      Text('읽기 테스트 소요 시간: ${result.readDuration}'),
                      const SizedBox(height: 20),
                      const Text('추가적인 증상'),
                      const SizedBox(height: 10),
                    ] +
                    result.notes!.map((note) => Text('  ' + note)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Result>> getResults(int userid) async {
    var url = Uri.parse('https://yusangyoon.com/result');
    if (userid == 138) {
      url = Uri.parse('https://yusangyoon.com/all-result');
    }
    var headers = {'userid': userid.toString()};
    var response = await http.get(url, headers: headers);
    var res = jsonDecode(response.body);
    List resultJsons = res['result'];
    if (res['success']) {
      if (userid == 138) {
        String resultText = '';
        resultJsons.map((e) {
          resultText += e.toString() + '\n';
        }).toList();
        final file = await _localFile;
        debugPrint(resultText);
        file.writeAsString(resultText).then(
              (value) => print(value),
            );
      }
      return resultJsons.map((e) {
        var result = Result.fromMap(jsonDecode(e['resultdata']));
        result.timerecord = e['timerecord'];
        return result;
      }).toList();
    }
    return [];
  }

  int accRate(Result result) {
    int nCorrect = 0;
    for (int i = 0;
        i < min(result.actualDistorted!.length, result.selectDistorted!.length);
        i++) {
      if (result.actualDistorted![i] == result.selectDistorted![i]) {
        nCorrect++;
      }
    }
    return ((nCorrect / result.actualDistorted!.length) * 100).toInt();
  }

  Widget _buildSmallGrids(Result result, double size) {
    int nGrids = result.actualDistorted!.length;
    var list = List<Widget>.generate(
      nGrids,
      (i) => Text(
        '실제 정답: ${result.actualDistorted} 선택 정답: ${result.selectDistorted}',
        style: TextStyle(fontSize: 25),
      ),
    );

    return Column(
      children: list,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userid = Provider.of<Auth>(context).userid;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retivision'),
      ),
      body: FutureBuilder(
        future: getResults(userid!),
        builder: (context, AsyncSnapshot<List<Result>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) =>
                  buildResultBox(snapshot.data![i], width),
            );
          } else {
            return const SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            );
          }
        },
      ),
    );
  }
}
