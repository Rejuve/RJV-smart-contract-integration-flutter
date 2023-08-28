import 'package:flutter/material.dart';
import 'package:flutter_web3/provider/balance_provider.dart';
import 'package:flutter_web3/provider/total_supply_provider.dart';
import 'package:flutter_web3/provider/user_provider.dart';
import 'package:flutter_web3/view/splash_screen/splash_screen.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'services/service.dart';
import 'services/smart_contract_utils.dart';

// This is our global ServiceLocator
GetIt getIt = GetIt.instance;

Future<void> main() async {
  getIt.registerSingleton<EthereumUtils>(EthereumUtils(), signalsReady: true);
  getIt.registerSingleton<Service>(Service(), signalsReady: true);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TotalSupplyProvider>(
          create: (_) => TotalSupplyProvider(),
        ),
        ChangeNotifierProvider<BalanceProvider>(
          create: (_) => BalanceProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rejuve Longevity App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    ),
  );
}
