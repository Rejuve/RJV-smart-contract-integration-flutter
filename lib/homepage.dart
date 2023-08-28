import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web3/view/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import 'services/smart_contract_utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String rpcUrl = 'https://rpc.ankr.com/eth_goerli';
  String privateeKey = '';
  @override
  void initState() {
    super.initState();
    initPlatformState();
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
        network: Network.testnet,
        redirectUrl: redirectUrl,
        whiteLabel: WhiteLabelData(dark: true, name: "Web3Auth Flutter App")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
          onPressed: () async {
            // Upon login gets the uer infor along with private key
            final response = await Web3AuthFlutter.login(
                LoginParams(loginProvider: Provider.google));
            setState(() {
              privateeKey = response.privKey.toString();
            });
            print("privateKey , ${response.privKey.toString()}");
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('privateKey', response.privKey.toString());
          },
          child: const Text('Login')),
      ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final privateKey = prefs.getString('privateKey') ?? '0';
          final credentials = EthPrivateKey.fromHex(privateKey);
          final address = credentials.address;
          debugPrint("Account, ${address.hexEip55}");
        },
        child: const Text('Get Address'),
      ),
      ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final privateKey = prefs.getString('privateKey') ?? '0';
          final credentials = EthPrivateKey.fromHex(privateKey);
          final client = Web3Client(rpcUrl, http.Client());
          final address = credentials.address;
          final balance = await client.getBalance(address);
          debugPrint("Balance, ${balance}");
        },
        child: const Text('Get Balance'),
      ),
      ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final privateKey = prefs.getString('privateKey') ?? '0';
          final client = Web3Client(rpcUrl, http.Client());
          final credentials = EthPrivateKey.fromHex(privateKey);
          final address = credentials.address;
          final receipt = await client.sendTransaction(
              credentials,
              Transaction(
                from: address,
                to: EthereumAddress.fromHex(
                    '0x0AFA40756121419231848bf8C97DE6c191f70FE8'),
                value: EtherAmount.fromUnitAndValue(
                    EtherUnit.gwei, 50000000), // 0.05 ETH
              ),
              chainId: 5); // change chainId as per your chain.
          debugPrint("Receipt, ${receipt}");
        },
        child: const Text('Send Transaction'),
      ),
      ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final privateKey = prefs.getString('privateKey') ?? '0';
          final client = Web3Client(rpcUrl, http.Client());
          final credentials = EthPrivateKey.fromHex(privateKey);
          final address = credentials.address;
          final receipt = await client.signTransaction(
              credentials,
              Transaction(
                from: address,
                to: EthereumAddress.fromHex(
                    '0x809D4310d578649D8539e718030EE11e603Ee8f3'),
                value: EtherAmount.fromUnitAndValue(
                    EtherUnit.gwei, 50000000), // 0.05 ETH
              ),
              chainId: 5); // change chainId as per your chain.
          debugPrint("Receipt, ${receipt}");
        },
        child: const Text('Sign Transaction'),
      ),
      ElevatedButton(
          onPressed: () {
            EthereumUtils ethereumUtils = EthereumUtils();
            ethereumUtils.init();
          },
          child: const Text('Initialize Smart Contract'))
    ])));
  }

 
}
