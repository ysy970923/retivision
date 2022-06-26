import 'package:flutter/material.dart';

class Auth extends ChangeNotifier {
  int? userid;
  String? username;
  String? birthday;
  bool login = false;

  Auth();

  void logIn(int userid, String username, String birthday) {
    this.userid = userid;
    this.username = username;
    this.birthday = birthday;
    login = true;
    notifyListeners();
  }

  void logOut() {
    login = false;
    notifyListeners();
  }
}
