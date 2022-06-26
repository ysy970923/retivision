import 'dart:math';

import 'package:flutter/material.dart';
import 'package:retivision_v2/models/result.dart';
import '../components/test_template.dart';
import 'test_reading.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../widgets/platform_alert_dialog.dart';

class TestHuePage extends StatelessWidget {
  const TestHuePage({Key? key}) : super(key: key);
  static const routeName = 'test-hue-page';

  @override
  Widget build(BuildContext context) {
    return const TestTemplate(
      testName: 'hue',
    );
  }
}

class TestHue extends StatefulWidget {
  final int distanceLevel;
  final Function nextPage;
  final int randSeed;

  TestHue({
    Key? key,
    required this.distanceLevel,
    required this.nextPage,
    required this.randSeed,
  }) : super(key: key);

  @override
  State<TestHue> createState() => _TestHueState();
}

class _TestHueState extends State<TestHue> {
  late Result result;

  String currentColor = 'red';
  final Map<String, Map<String, Color>> colors = {
    'red': {
      'red10': const Color(0xFFFF1206),
      'red20': const Color(0xFFF40C00),
      'red40': const Color(0xFFe40B00),
      'red50': const Color(0xFFd40A00),
      'red70': const Color(0xFFC30900),
      'red80': const Color(0xFFB30900),
    },
    'green': {
      'green10': const Color(0xFF5DCF1D),
      'green20': const Color(0xFF57C11B),
      'green40': const Color(0xFF50B219),
      'green50': const Color(0xFF4AA417),
      'green70': const Color(0xFF439615),
      'green80': const Color(0xFF3D8713),
    },
    'blue': {
      'blue10': const Color(0xFF1E4BD6),
      'blue20': const Color(0xFF1C46C8),
      'blue40': const Color(0xFF1A41B9),
      'blue50': const Color(0xFF183CAB),
      'blue70': const Color(0xFF16379D),
      'blue80': const Color(0xFF14328E),
    }
  };
  final Map<String, List<String>> colorOrders = {};
  final Map<String, List<String>> selectedOrders = {};
  @override
  void initState() {
    super.initState();
    colorOrders['red'] = colors['red']!.keys.toList();
    colorOrders['red']!.shuffle(Random(widget.randSeed));

    colorOrders['blue'] = colors['blue']!.keys.toList();
    colorOrders['blue']!.shuffle(Random(widget.randSeed + 1));

    colorOrders['green'] = colors['green']!.keys.toList();
    colorOrders['green']!.shuffle(Random(widget.randSeed + 2));

    colorOrders.forEach((key, value) {
      selectedOrders[key] = List.filled(value.length, "");
    });
  }

  int point(List<String> order, List<String> answer) {
    int acc = 100;
    for (int i = 0; i < answer.length; i++) {
      acc -= (order.indexOf(answer[i]) - i).abs();
    }
    return acc;
  }

  void nextPage() async {
    if (selectedOrders[currentColor]!.contains("")) {
      await PlatformAlertDialog(
        title: "정답이 선택되지 않았습니다",
        content: "정답을 선택해주셔야 넘어갈 수 있습니다",
        defaultActionText: "네",
      ).show(context);
      return;
    }
    if (currentColor == 'red') {
      setState(() {
        currentColor = 'green';
      });
    } else if (currentColor == 'green') {
      setState(() {
        currentColor = 'blue';
      });
    } else if (currentColor == 'blue') {
      result.huePoints = [
        point(selectedOrders['red']!, colors['red']!.keys.toList()),
        point(selectedOrders['green']!, colors['green']!.keys.toList()),
        point(selectedOrders['blue']!, colors['blue']!.keys.toList()),
      ];
      widget.nextPage();
    }
  }

  void beforePage() {
    if (currentColor == 'green') {
      setState(() {
        currentColor = 'red';
      });
    } else if (currentColor == 'blue') {
      setState(() {
        currentColor = 'green';
      });
    }
  }

  Widget makeColorBox(
      int index, String colordata, List<String> order1, List<String?> order2) {
    return GestureDetector(
      onTap: (() {
        setState(() {
          int i = order2.indexOf("");
          order2[i] = colordata;
          order1[index] = "";
        });
      }),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(),
            color: (colordata != "") ? colors[currentColor]![colordata] : null),
        width: 150,
        height: 120,
      ),
    );
  }

  Widget makeBar(List<String> order1, List<String> order2) {
    int i = 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: order1.map(
        (e) {
          return makeColorBox(i++, e, order1, order2);
        },
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    result = Provider.of<Result>(context);

    return Row(
      children: [
        Expanded(
          child: currentColor == 'red'
              ? Container()
              : TextButton.icon(
                  icon: const Icon(
                    Icons.arrow_left,
                    size: 50,
                  ),
                  label: const Text(
                    '이전',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => beforePage(),
                ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('보기에서 제일 연한 색상부터 골리주세요'),
            makeBar(selectedOrders[currentColor]!, colorOrders[currentColor]!),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('보기:'),
                const SizedBox(width: 50),
                makeBar(
                    colorOrders[currentColor]!, selectedOrders[currentColor]!),
              ],
            ),
          ],
        ),
        Expanded(
          child: TextButton.icon(
            icon: const Icon(
              Icons.arrow_right,
              size: 50,
            ),
            label: Text(
              currentColor == 'blue' ? '완료' : '다음',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => nextPage(),
          ),
        ),
      ],
    );
  }
}
