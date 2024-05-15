class ShoppingContract {
  ShoppingContract._();

  static const String dbName = "shoppingList.db";
  static const int dbVersion = 1;

  static const String shoppingListTable = "shoppingList";
  static const String tableListColumnID = "id";
  static const String tableListColumnTitle = "title";

  static const String shoppingListItemsTable = "shoppingItems";
  static const String tableItemColumnID = "id";
  static const String tableItemColumnListID = "listID";
  static const String tableItemColumnTitle = "title";
  static const String tableItemColumnQuantity = "quantity";
  static const String tableItemColumnIsDone = "done";
}
