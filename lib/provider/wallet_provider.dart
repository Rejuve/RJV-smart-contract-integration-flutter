// import 'package:flutter/foundation.dart';

// import '../services/smart_contract_utils.dart';

// class WalletProvider extends ChangeNotifier {
//   int _totalSupply = 0;
//   int _balance = 0;
//   bool _loading = false;
//   EthereumUtils ethereumUtils = EthereumUtils();

//   int get totalSupply => _totalSupply;
//   set totalSupply(int totalSupply) {
//     _totalSupply = totalSupply;
//     notifyListeners();
//   }

//   int get balance => _balance;
//   set balance(int balance) {
//     _balance = balance;
//     notifyListeners();
//   }

//   bool get loading => _loading;
//   set loading(bool loading) {
//     _loading = loading;
//     notifyListeners();
//   }

//   Future<void> fetchAccountInformation() async {
//     loading = true;
//     var newBalance = await ethereumUtils.balanceOf();
//     var newTotalSupply = await 
//     balance = newBalance;
//     loading = false;
//   }

//   Future<void> transfer() async {
//     ethereumUtils.transfer('0x0438C1104c48E4c921d04FfA1F7a90ED4754C9A1');
//   }
// }
