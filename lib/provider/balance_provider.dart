import 'package:flutter/material.dart';
import 'package:flutter_web3/main.dart';
import 'package:flutter_web3/services/smart_contract_utils.dart';

class BalanceProvider extends ChangeNotifier {
  EthereumUtils ethereumUtils = EthereumUtils();
  bool _balanceLoading = false;
  int _balance = 0;

  bool get balanceLoading => _balanceLoading;
  set balanceLoading(bool loading) {
    _balanceLoading = loading;
    notifyListeners();
  }

  int get balance => _balance;
  set balance(int balance) {
    _balance = balance;
    notifyListeners();
  }

  Future<void> fetchBalance() async {
    print("fetch balance on provider");
    balanceLoading = true;
    notifyListeners();
    await ethereumUtils.init();
    var newBalance = await getIt<EthereumUtils>().balanceOf();
    balance = newBalance;
    balanceLoading = false;
    notifyListeners();
  }

  Future<void> transferBalance(String address, int amount) async {
    balanceLoading = true;
    notifyListeners();

    await getIt<EthereumUtils>().transfer(address, amount);
    await fetchBalance();
  }
}
