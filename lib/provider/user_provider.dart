import 'package:flutter/material.dart';
import 'package:flutter_web3/model/user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/output.dart';

class UserProvider extends ChangeNotifier {
  late UserInfo _userInfo;
  late bool _isUserLoggedIn;

  UserInfo get userInfo => _userInfo;
  set userInfo(UserInfo torusUserInfo) {
    _userInfo = torusUserInfo;
    _isUserLoggedIn = true;
    notifyListeners();
  }

  bool get isUserLoggedIn => _isUserLoggedIn;
  set isUserLoggedIn(bool loggedIn) {
    _isUserLoggedIn = loggedIn;
    notifyListeners();
  }

  Future<void> checkIfUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('privateKey') != '') {
      isUserLoggedIn = true;
    } else {
      isUserLoggedIn = false;
    }
  }

  Future<void> setUserInfor() async {
    final prefs = await SharedPreferences.getInstance();
    var newUserInfo = UserInfo(
        name: prefs.getString('name').toString(),
        email: prefs.getString('email').toString(),
        profileImage: prefs.getString('profilePic').toString());

    userInfo = newUserInfo;
  }
}
