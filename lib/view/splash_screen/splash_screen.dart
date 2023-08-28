import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web3/main.dart';
import 'package:flutter_web3/provider/user_provider.dart';
import 'package:flutter_web3/view/login/login.dart';
import 'package:flutter_web3/view/wallet/wallet_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/smart_contract_utils.dart';
import 'logo.dart';

class AnimatedLogo extends AnimatedWidget {
  AnimatedLogo({Key? key, required Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[200]!,
                  Colors.blue[50]!,
                ],
                begin: const FractionalOffset(1.0, 1.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          Center(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                height: animation.value,
                width: animation.value,
                child: Stack(children: [
                  SvgPicture.asset(
                    'assets/images/eth_wallet.svg',
                    color: Colors.white.withOpacity(0.8),
                    matchTextDirection: true,
                    height: size.height * 0.6,
                  ),
                  Logo(width: animation.value * 0.65),
                ])),
          ),
        ],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  _SplashScreenState createState() => _SplashScreenState();
}

// #docregion  -state
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  late bool condition;
  late EthereumUtils ethereumUtils;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 1800), vsync: this);
    animation = Tween<double>(begin: 320, end: 350).animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      })
      ..addStatusListener((state) => ('$state'));
    controller.forward();
    ethereumUtils = EthereumUtils();
    initEth();
    Future.delayed(const Duration(milliseconds: 3500), () {
      getUserStatus();
    });
  }

  initEth() async {
    await getIt<EthereumUtils>().init();
  }

  Future<void> getUserStatus() async {
    var _prefs = await SharedPreferences.getInstance();
    print("Prevs : $_prefs");
    if (_prefs.getString('privateKey') == '' ||
        _prefs.getString('privateKey') == '0') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => (LoginPage())));
    } else {
      await context.read<UserProvider>().setUserInfor();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => (WalletPage())));
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedLogo(animation: animation);
  }
}
