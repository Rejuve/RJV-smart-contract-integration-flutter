import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/output.dart';

class Service {
  Future<void> clearPreferenceValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, ''); // Set the value to null
  }

  Future<void> setUserInfo(Web3AuthResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('privateKey', response.privKey.toString());
    await prefs.setString(
        'profilePic', response.userInfo!.profileImage.toString());
    await prefs.setString('name', response.userInfo!.name.toString());
    await prefs.setString('email', response.userInfo!.email.toString());
  }
}
