import 'package:flutter/material.dart';
import 'package:flutter_web3/main.dart';
import 'package:flutter_web3/services/smart_contract_utils.dart';

class TotalSupplyProvider extends ChangeNotifier {
  EthereumUtils ethereumUtils = EthereumUtils();
  bool _totalSupplyLoading = false;
  int _totalSupply = 0;

  bool get totalSupplyLoading => _totalSupplyLoading;
  set totalSupplyLoading(bool loading) {
    _totalSupplyLoading = loading;
    notifyListeners();
  }

  int get totalSupply => _totalSupply;
  set totalSuppply(int supply){
    _totalSupply = supply;
    notifyListeners();
  }

  Future<void> fetchTotalSupply() async {
    totalSupplyLoading = true;
    var newSupply = await getIt<EthereumUtils>().totalSupply();

    totalSuppply = newSupply;

    totalSupplyLoading = false;
  }
}
