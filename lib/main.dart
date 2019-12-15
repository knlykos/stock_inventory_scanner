import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_inventory_scanner/provider/server_provider.dart';
import 'package:stock_inventory_scanner/provider/stock_inventory_line_state.dart';
import 'package:stock_inventory_scanner/screens/login.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: ServerProvider(),
      ),
      ChangeNotifierProvider.value(
        value: StockInventoryLineState(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/',
        routes: {
//          '/stockInventoryLine': (context) => StockInventoryLineScreen(),
          // '/': (context) => StockInventoryScreen(),
          '/': (context) => LoginScreen(),
//          '/stockInventory': (context) => StockInventoryScreen(),
//          '/addProduct': (context) => AddProductScreen(),
        },
        theme: ThemeData(primarySwatch: Colors.indigo));
  }
}
