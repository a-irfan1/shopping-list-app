import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:shopping_list/shopping_list.dart';
import 'package:shopping_list/util/contracts.dart';
import 'package:shopping_list/util/sql_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'home.dart';

ShoppingProvider? shoppingProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  shoppingProvider = ShoppingProvider();

  String databasePath = await getDatabasesPath();
  String path = join(databasePath, ShoppingContract.dbName);

  await shoppingProvider!.open(path);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const Home(),
        ShoppingList.routeName: (context) => const ShoppingList(),
      },
    );
  }
}
