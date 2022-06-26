import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Result {
  String? leftRight;
  int? testLevel;
  int? visionTestResult;
  List<dynamic>? actualDistorted;
  List<dynamic>? selectDistorted;
  List<dynamic>? dPoints;
  List<dynamic>? dLevels;
  List<dynamic>? huePoints;
  String? readDuration;
  List<dynamic>? notes;
  String? timerecord;

  Result({
    this.actualDistorted,
    this.selectDistorted,
    this.dPoints,
    this.dLevels,
    this.notes,
  });

  factory Result.fromMap(Map<String, dynamic> data) {
    final result = Result();
    result.leftRight = data['leftRight'] ?? 'no data';
    result.testLevel = data['testLevel'] ?? 0;
    result.visionTestResult = data['visionTestResult'] ?? 0;
    result.actualDistorted = data['actualDistorted'] ?? [];
    result.selectDistorted = data['selectDistorted'] ?? [];
    result.dPoints = data['dPoints']
        .map((offsetMap) => Offset(offsetMap['x'], offsetMap['y']))
        .toList();
    result.dLevels = data['dLevels'] ?? [];
    result.huePoints = data['huePoints'] ?? [];
    result.readDuration = data['readDuration'] ?? "0";
    result.notes = data['notes'] ?? "";
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      'leftRight': leftRight,
      'testLevel': testLevel,
      'visionTestResult': visionTestResult,
      'actualDistorted': actualDistorted,
      'selectDistorted': selectDistorted,
      'dPoints': dPoints!
          .map((point) => (point != null)
              ? {'x': point.dx, 'y': point.dy}
              : {'x': 0.0, 'y': 0.0})
          .toList(),
      'dLevels': dLevels,
      'huePoints': huePoints,
      'readDuration': readDuration,
      'notes': notes,
    };
  }

  Future<bool> submit(int userid) async {
    var url = Uri.parse('https://yusangyoon.com/result');
    var body = {
      'userid': userid.toString(),
      'timerecord': DateTime.now()
          .subtract(const Duration(days: 0))
          .toString()
          .substring(0, 19),
      'resultdata': jsonEncode(toMap()),
    };
    var response = await http.post(url, body: body);
    var res = jsonDecode(response.body);
    return res['success'];
  }
}
