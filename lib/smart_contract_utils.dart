import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

const String savedBalance = "savedBalance";

enum SCEvents {
  Balance,
}

class EthereumUtils {
  late http.Client _httpClient;
  late Web3Client _web3cient;
  final String _rpcUrl = 'https://rpc.ankr.com/eth_goerli';
  late String _privateKey;
  late Credentials credentials;
  late SharedPreferences _prefs;
  late DeployedContract _deployedContract;
  late String abi;
  late EthereumAddress _contractAddress;
  late DeployedContract contract;
  late ContractAbi _abiCode;
  late Credentials _creds;
  List? decoded;
  // late WalletModel wallet;
  late ContractFunction _addDepositAmount;
  late ContractFunction _withdrawAmount;
  late ContractFunction _getWallet;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _privateKey = _prefs.getString('privateKey') ?? '0';
    _httpClient = http.Client();
    _web3cient = Web3Client(_rpcUrl, _httpClient);

    // await getABI();
    await getCredentials();
    await getDeployedContract();
  }

  //  ABI is applicaiton binary interface it is a way to interact with smart contracts.
  Future<void> getABI() async {
    String abiFile =
        await rootBundle.loadString('assets/contracts_abis/Investment.json');

    var jsonABI = jsonDecode(abiFile);

    _abiCode =
        ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'NotesContract');
    _contractAddress =
        EthereumAddress.fromHex(jsonABI['networks']['5777']['address']);
  }

  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privateKey);

    print("Cred : ${_creds.address}");
  }

  // Future listenContract() async {
  //   contract = await _getContract();
  //   listenEvent();
  //   return decoded;
  // }

  // StreamSubscription listenEvent() {
  //   var events = _ethClient.events(FilterOptions.events(
  //     contract: contract,
  //     event: contract.event('BalanceChange'),
  //   ));
  //   return events.listen((FilterEvent event) {
  //     if (event.topics == null || event.data == null) {
  //       return;
  //     }
  //     decoded = contract
  //         .event('BalanceChange')
  //         .decodeResults(event.topics!, event.data!);
  //     print("Listen Event: $decoded");

  //     List<String> balanceList =
  //         decoded!.map((e) => e.toInt().toString()).toList();

  //     _prefs.setStringList(savedBalance, balanceList);
  //   });
  // }

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(_abiCode, _contractAddress);
    _addDepositAmount = _deployedContract.function('addDepositAmount');
    _withdrawAmount = _deployedContract.function('withdrawAmount');
    _getWallet = _deployedContract.function('getWallet');
    await readContract();
    await writeToContract(34);
  }

  Future<void> readContract() async {
    var queryResult = await _web3cient.call(
      contract: _deployedContract,
      function: _getWallet,
      params: [],
    );

    print("queryResult $queryResult");
    // return queryResult;
  }

  Future<void> writeToContract(int amount) async {
    await _web3cient.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _withdrawAmount,
        parameters: [BigInt.from(10)],
      ),
    );
    readContract();
  }

  // Future<void> writeToContract(
  //   String functionName,
  //   List<dynamic> functionArgs,
  // ) async {
  //   try {
  //     credentials = EthPrivateKey.fromHex(privateKey!);

  //     print("Credentials : $credentials");
  //     DeployedContract contract = await _getContract();

  //     await _ethClient.sendTransaction(
  //       credentials,
  //       Transaction.callContract(
  //         contract: contract,
  //         function: contract.function(functionName),
  //         parameters: functionArgs,
  //       ),
  //     );
  //   } catch (e) {
  //     print("Something wrong happened! $e");
  //   }
  // }

  // Future<void> dispose() async {
  //   await _ethClient.dispose();
  //   await listenEvent().cancel();
  // }
}
