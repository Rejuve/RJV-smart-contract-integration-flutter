import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web3/main.dart';
import 'package:flutter_web3/provider/balance_provider.dart';
import 'package:flutter_web3/provider/total_supply_provider.dart';
import 'package:flutter_web3/provider/user_provider.dart';
import 'package:flutter_web3/services/smart_contract_utils.dart';
import 'package:flutter_web3/view/login/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late SharedPreferences prefs;

  @override
  TextEditingController _addressController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<TotalSupplyProvider>().fetchTotalSupply();
    context.read<BalanceProvider>().fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    final balanceLoading = context.watch<BalanceProvider>().balanceLoading;
    final balance = context.watch<BalanceProvider>().balance;
    final totalSupplyLoading =
        context.watch<TotalSupplyProvider>().totalSupplyLoading;
    final totalSupply = context.watch<TotalSupplyProvider>().totalSupply;
    final userInfo = context.watch<UserProvider>().userInfo;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Simple Rjv Wallet"),
        ),
        drawer: Drawer(
            child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userInfo.name),
              accountEmail: Text(userInfo.email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(userInfo.profileImage),
              ),
              decoration: const BoxDecoration(color: Colors.purpleAccent),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                  onPressed: () {
                    getIt<Service>().clearPreferenceValue('privateKey');

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => (const LoginPage())));
                  },
                  child: const Text("Log Out")),
            )
          ],
        )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      balanceLoading
                          ? const CircularProgressIndicator()
                          : Padding(
                            padding: const EdgeInsets.only(right:30.0),
                            child: GestureDetector(
                                onTap: () async {
                                  await getIt<EthereumUtils>().init();
                                  await context
                                      .read<BalanceProvider>()
                                      .fetchBalance();
                                },
                                child: const Icon(Icons.refresh)),
                          )
                    ],
                  ),
                  Card(
                    elevation: 2,
                    color: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Customize the border radius here
                    ),
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        child: Column(
                          children: [
                            totalSupplyLoading
                                ? const CircularProgressIndicator()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Total Supply: ",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "$totalSupply RJV",
                                        style: const TextStyle(
                                            color: Colors.amberAccent,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                            const SizedBox(height: 50),
                            balanceLoading
                                ? const CircularProgressIndicator()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Balance: ",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )),
                                      Text("$balance RJV",
                                          style: const TextStyle(
                                              color: Colors.amberAccent,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600))
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  ElevatedButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content: SizedBox(
                                  height: 400,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          const Text("Enter Address"),
                                          TextField(
                                            controller: _addressController,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text("Enter Amount"),
                                          TextField(
                                            controller: _amountController,
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            context
                                                .read<BalanceProvider>()
                                                .transferBalance(
                                                    _addressController.text,
                                                    int.parse(_amountController
                                                        .text));

                                            _addressController.clear();
                                            _amountController.clear();
                                            Navigator.pop(context);
                                          },
                                          child: balanceLoading
                                              ? const CircularProgressIndicator()
                                              : const Text('Send'))
                                    ],
                                  ),
                                ),
                              )),
                      child: const Text('Transfer Tokens')),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    var address = getIt<EthereumUtils>().address;
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: SizedBox(
                                height: 200,
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        const Text("Address of this Account"),
                                        Text("$address"),
                                        ElevatedButton(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                    text: address.toString()))
                                                .then((_) {
                                              // controller.clear();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Copied to your clipboard !')));
                                              Navigator.pop(context);
                                            });
                                          },
                                          child: const Text('Copy'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ));
                  },
                  child: const Text("Get Wallet address"))
            ],
          ),
        ));
  }
}
