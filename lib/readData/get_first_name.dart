import 'package:flutter/material.dart';
import 'package:msg_app/model/user_data.dart';


class UserDataProvider extends ChangeNotifier {
  UserData? _userData;

  UserData? get userData => _userData;

  void setUserData(UserData userData) {
    _userData = userData;
    notifyListeners();
  }
}