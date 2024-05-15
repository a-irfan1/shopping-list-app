import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'contracts.dart';

class ShoppingListHelper {
  ShoppingListHelper({required this.title});

  int? id;
  String? title;

  ShoppingListHelper.fromMap(Map map) {
    id = map[ShoppingContract.tableListColumnID] as int?;
    title = map[ShoppingContract.tableListColumnTitle] as String;
  }

  Map<String, Object?> toMap() {
    final map = <String, Object?>{ShoppingContract.tableListColumnTitle: title};

    if (id != null) {
      map[ShoppingContract.tableListColumnID] = id;
    }
    return map;
  }
}

class ShoppingItemsHelper {
  ShoppingItemsHelper(
      {required this.title,
      required this.listID,
      required this.quantity,
      required this.isDone});

  int? id;
  int? listID;
  String? title;
  double? quantity;
  bool? isDone;

  ShoppingItemsHelper.fromMap(Map map) {
    id = map[ShoppingContract.tableItemColumnID] as int?;
    title = map[ShoppingContract.tableItemColumnTitle] as String?;
    listID = map[ShoppingContract.tableItemColumnListID] as int?;
    quantity = map[ShoppingContract.tableItemColumnQuantity] as double?;
    isDone = map[ShoppingContract.tableItemColumnIsDone] == 1 ? true : false;
  }

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      ShoppingContract.tableItemColumnTitle: title,
      ShoppingContract.tableItemColumnListID: listID,
      ShoppingContract.tableItemColumnQuantity: quantity,
      ShoppingContract.tableItemColumnIsDone: isDone == true ? 1 : 0,
    };

    if (id != null) {
      map[ShoppingContract.tableItemColumnID] = id;
    }
    return map;
  }
}

class ShoppingProvider {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(
      path,
      version: ShoppingContract.dbVersion,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
      create table ${ShoppingContract.shoppingListTable} (
      ${ShoppingContract.tableListColumnID} integer primary key autoincrement,
      ${ShoppingContract.tableListColumnTitle} text not null)
          ''');

      await txn.execute('''
      create table ${ShoppingContract.shoppingListItemsTable} (
      ${ShoppingContract.tableItemColumnID} integer primary key autoincrement,
      ${ShoppingContract.tableItemColumnTitle} text not null,
      ${ShoppingContract.tableItemColumnListID} integer,
      ${ShoppingContract.tableItemColumnQuantity} double default 0.0 not null,
      ${ShoppingContract.tableItemColumnIsDone} integer not null,)
          ''');
    });
  }

  // void _onUpgrade(Database db, int oldVersion, int newVersion) {}
  // void _onDowngrade(Database db, int oldVersion, int newVersion) {}

  Future<void> insertShoppingList(ShoppingListHelper shoppingList) async {
    shoppingList.id = await db.insert(
        ShoppingContract.shoppingListTable, shoppingList.toMap());

    Batch batch = db.batch();
    batch.insert(
      ShoppingContract.shoppingListItemsTable,
      ShoppingItemsHelper(
              title: "Books",
              listID: shoppingList.id,
              quantity: 3,
              isDone: false)
          .toMap(),
    );
    batch.insert(
      ShoppingContract.shoppingListItemsTable,
      ShoppingItemsHelper(
              title: "Eggs",
              listID: shoppingList.id,
              quantity: 6,
              isDone: false)
          .toMap(),
    );
  }

  Future<ShoppingListHelper?> getShoppingList(int id) async {
    try {
      List<Map> maps = await db.query(ShoppingContract.shoppingListTable,
          columns: [
            ShoppingContract.tableListColumnID,
            ShoppingContract.tableListColumnTitle,
          ],
          where: "${ShoppingContract.tableListColumnID} = ?",
          whereArgs: [id]);
      if (maps.isNotEmpty) {
        return ShoppingListHelper.fromMap(maps.first);
      }
    } on DatabaseException catch (e) {
      return null;
    }
    return null;
  }

  Future<List<ShoppingListHelper>> getShoppingLists() async {
    List<Map> shoppingLists =
        await db.query(ShoppingContract.shoppingListTable);
    List<ShoppingListHelper> lists = [];
    if (shoppingLists.isNotEmpty) {
      for (Map shoppingList in shoppingLists) {
        lists.add(ShoppingListHelper.fromMap(shoppingList));
      }
    }
    return lists;
  }

  Future<int> deleteShoppingList(int id) async {
    final deletedID = await db.delete(
      ShoppingContract.shoppingListTable,
      where: "${ShoppingContract.tableListColumnID} = ?",
      whereArgs: [id],
    );
    await db.delete(
      ShoppingContract.shoppingListItemsTable,
      where: "${ShoppingContract.tableItemColumnListID} = ?",
      whereArgs: [id],
    );
    return deletedID;
  }

  Future<int> updateShoppingList(ShoppingListHelper shoppingList) async {
    return await db.update(
      ShoppingContract.shoppingListTable,
      shoppingList.toMap(),
      where: "${ShoppingContract.tableListColumnID} = ?",
      whereArgs: [shoppingList.id],
    );
  }

  Future<ShoppingItemsHelper> insertListItem(
      ShoppingItemsHelper shoppingItem) async {
    shoppingItem.id = await db.insert(
        ShoppingContract.shoppingListItemsTable, shoppingItem.toMap());
    return shoppingItem;
  }

  Future<ShoppingItemsHelper?> getShoppingItem(int id) async {
    List<Map> maps = await db.query(ShoppingContract.shoppingListItemsTable,
        columns: [
          ShoppingContract.tableItemColumnID,
          ShoppingContract.tableItemColumnTitle,
          ShoppingContract.tableItemColumnListID,
          ShoppingContract.tableItemColumnQuantity,
          ShoppingContract.tableItemColumnIsDone,
        ],
        where: "${ShoppingContract.tableItemColumnID} = ?",
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return ShoppingItemsHelper.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ShoppingItemsHelper>> getShoppingItems(int? listID) async {
    List<Map> shoppingItems =
        await db.query(ShoppingContract.shoppingListItemsTable,
            columns: [
              ShoppingContract.tableItemColumnID,
              ShoppingContract.tableItemColumnTitle,
              ShoppingContract.tableItemColumnListID,
              ShoppingContract.tableItemColumnQuantity,
              ShoppingContract.tableItemColumnIsDone,
            ],
            where: "${ShoppingContract.tableItemColumnListID} = ?",
            whereArgs: [listID]);
    List<ShoppingItemsHelper> items = [];
    if (shoppingItems.isNotEmpty) {
      for (Map shoppingItem in shoppingItems) {
        items.add(ShoppingItemsHelper.fromMap(shoppingItem));
      }
    }
    return items;
  }

  Future<int> deleteShoppingItem(int id) async {
    return await db.delete(
      ShoppingContract.shoppingListItemsTable,
      where: "${ShoppingContract.tableItemColumnID} = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateShoppingItem(ShoppingItemsHelper shoppingItem) async {
    return await db.update(
      ShoppingContract.shoppingListItemsTable,
      shoppingItem.toMap(),
      where: "${ShoppingContract.tableItemColumnID} = ?",
      whereArgs: [shoppingItem.id],
    );
  }

  Future close() async {
    db.close();
  }

  Future<String> initDeleteDB(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    if (await Directory(dirname(path)).exists()) {
      await databaseFactory.deleteDatabase(path);
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return path;
  }
}
