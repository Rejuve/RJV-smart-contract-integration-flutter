import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_web3/main.dart';
import 'package:flutter_web3/provider/user_provider.dart';
import 'package:flutter_web3/view/splash_screen/logo.dart';
import 'package:flutter_web3/view/wallet/wallet_page.dart';
import 'package:provider/provider.dart';
import 'package:web3auth_flutter/enums.dart' as Enum;
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

import '../../services/service.dart';
import '../../services/smart_contract_utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String rpcUrl = 'https://rpc.ankr.com/eth_goerli';
  String privateeKey = '';
  @override
  void initState() {
    super.initState();
    initPlatformState();
    //
  }

  Future<void> initPlatformState() async {
    Uri redirectUrl;
    if (Platform.isAndroid) {
      redirectUrl =
          Uri.parse('appyarednewweb3://com.flutter.web3.example/auth');
      // w3a://com.example.w3aflutter/auth
    } else if (Platform.isIOS) {
      redirectUrl = Uri.parse('{bundleId}://openlogin');
      // com.example.w3aflutter://openlogin
    } else {
      throw UnKnownException('Unknown platform');
    }

    await Web3AuthFlutter.init(Web3AuthOptions(
        clientId:
            'BMIo9TXmlLOmox9XAuJ0qKs8SBV36hzwSAMrQAIEZUYbFfH7pik30lpN2unjyo81RW2DbasjUCNya55me2BVo7o',
        network: Enum.Network.testnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(dark: true, name: "Web3Auth Flutter App")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 300,
                  width: 200,
                  child: Stack(children: [
                    SvgPicture.asset(
                      'assets/images/eth_wallet.svg',
                      color: Colors.white.withOpacity(0.8),
                      matchTextDirection: true,
                      height: MediaQuery.of(context).size.height * 0.8,
                    ),
                    Logo(width: 200),
                  ])),
            ),
            ElevatedButton(
                onPressed: () async {
                  // Upon login gets the uer infor along with private key
                  print("Login button clicked");
                  final response = await Web3AuthFlutter.login(
                      LoginParams(loginProvider: Enum.Provider.google));

                  await getIt<Service>().setUserInfo(response);
                  await context.read<UserProvider>().setUserInfor();
                  await getIt<EthereumUtils>().init();
                  if (response.privKey != '') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => (WalletPage())));

                    print("userInfo , ${response.userInfo!.toJson()}");
                  }
                },
                child: const FittedBox(
                  child: const Row(
                    children: [
                      Icon(Icons.login_sharp),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Login with Google'),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
