import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:flutter_web3/model/test_contract.dart';
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
  late ContractFunction _balanceOf;
  late ContractFunction _mint;
  late ContractFunction _totalSupply;
  late ContractFunction _setMinterRole;
  late ContractFunction _transferFrom;

  EthereumAddress get address => _creds.address;
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _privateKey = _prefs.getString('privateKey') ?? '';

    print("Private Key $_privateKey");
    _httpClient = http.Client();
    _web3cient = Web3Client(_rpcUrl, _httpClient);

    await getABI();
    await getCredentials();
    await getDeployedContract();
  }

  //  ABI is applicaiton binary interface it is a way to interact with smart contracts.
  
  Future<void> getABI() async {
    String abiFile =
        await rootBundle.loadString('assets/contracts_abis/RejuveToken.json');

    var jsonABI = jsonDecode(abiFile);

    _abiCode =
        ContractAbi.fromJson(jsonEncode(jsonABI[0]['abi']), 'RejuveToken');
    _contractAddress = TestContract.deployedAddress;

    print("Abi Code $_abiCode");
  }

  Future<EthereumAddress> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privateKey);

    print("Cred : ${_creds.address}");

    return _creds.address;
  }

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(_abiCode, _contractAddress);

    print("Deployed Contract $_deployedContract");

    _balanceOf = _deployedContract.function('balanceOf');
    _mint = _deployedContract.function('mint');
    _totalSupply = _deployedContract.function('totalSupply');
    _setMinterRole = _deployedContract.function('MINTER_ROLE');
    _transferFrom = _deployedContract.function('transfer');

    print("_balanceOf $_balanceOf");
    // _withdrawAmount = _deployedContract.function('withdrawAmount');
    // _getWallet = _deployedContract.function('getWallet');
    // await balanceOf();
    // await totalSupply();
    // await transferFrom();
    // await getMintRole();
    // await mint(100000);
  }

  Future<int> balanceOf() async {
    final address = _creds.address;

    print("ADDRESS : $address");
    var queryResult = await _web3cient.call(
      contract: _deployedContract,
      function: _balanceOf,
      params: [address],
    );

    print("Balance ${queryResult.first}");

    return queryResult.first.toInt();
    // return queryResult;
  }

  Future<int> totalSupply() async {
    var queryResult = await _web3cient.call(
      contract: _deployedContract,
      function: _totalSupply,
      params: [],
    );

    print("TotalSupply $queryResult");
    return queryResult.first.toInt();
  }

  Future<void> getMintRole() async {
    // final address = _creds.address;
    var queryResult = await _web3cient.call(
      contract: _deployedContract,
      function: _setMinterRole,
      params: [],
    );

    print("TotalSupply ${queryResult.first.to()}");
    // return queryResult;
  }

  Future<void> mint(int amount) async {
    final address = _creds.address;
    print("chain ID: ${await _web3cient.getNetworkId()}");
    await _web3cient.sendTransaction(
        _creds,
        Transaction.callContract(
          contract: _deployedContract,
          function: _mint,
          parameters: [address, BigInt.from(amount)],
        ),
        fetchChainIdFromNetworkId: true);

    // readContract();
  }

  Future<void> transfer(String transferTo, int amount) async {
    final toAddress = EthereumAddress.fromHex(transferTo);
    final resp = await _web3cient.sendTransaction(
        _creds,
        Transaction.callContract(
          contract: _deployedContract,
          function: _transferFrom,
          parameters: [toAddress, BigInt.from(amount)],
        ),
        chainId: 5);

    print("Response; $resp");

  }

}
