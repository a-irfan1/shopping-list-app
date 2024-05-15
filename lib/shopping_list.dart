import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/main.dart';
import 'util/sql_helper.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();

  static const routeName = "/shopping_list";
}

class _ShoppingListState extends State<ShoppingList> {
  TextEditingController itemIDController = TextEditingController();
  TextEditingController itemTitleController = TextEditingController();
  TextEditingController itemQuantityController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    itemTitleController.dispose();
    itemQuantityController.dispose();
    itemIDController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ShoppingListArguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.list.title ?? "",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ActionChip(
              label: const Text("Delete List"),
              onPressed: () {
                shoppingProvider!.deleteShoppingList(args.list.id!);
                Navigator.pop(context);
              },
            ),
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<List<ShoppingItemsHelper>>(
            future: shoppingProvider!.getShoppingItems(args.list.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Items: ${snapshot.data!.length}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 15.0),
                    ElevatedButton(
                      onPressed: () {
                        itemTitleController.clear();
                        itemQuantityController.clear();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("New Item"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: itemTitleController,
                                    decoration: const InputDecoration(
                                        hintText: "Item Name"),
                                  ),
                                  TextField(
                                    controller: itemQuantityController,
                                    decoration: const InputDecoration(
                                        hintText: "Quantity"),
                                  ),
                                ],
                              ),
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    shoppingProvider!.insertListItem(
                                      ShoppingItemsHelper(
                                          title: itemTitleController.text,
                                          listID: args.list.id,
                                          quantity: double.parse(
                                              itemQuantityController.text),
                                          isDone: false),
                                    );
                                    itemTitleController.clear();
                                    itemQuantityController.clear();
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text("New Item"),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text("${snapshot.data![index].title}"),
                                const SizedBox(width: 5.0),
                                Text("${snapshot.data![index].quantity}"),
                                const Spacer(),
                                IconButton(
                                  onPressed: () async {
                                    snapshot.data![index].isDone =
                                        !(snapshot.data![index].isDone!);
                                    snapshot.data![index].listID = args.list.id;
                                    await shoppingProvider?.updateShoppingItem(
                                        snapshot.data![index]);
                                    setState(() {});
                                  },
                                  icon: snapshot.data![index].isDone!
                                      ? const Icon(
                                          Icons.check_box,
                                          color: CupertinoColors.activeGreen,
                                        )
                                      : const Icon(
                                          Icons.check_box_outline_blank),
                                ),
                                IconButton(
                                  onPressed: () {
                                    itemTitleController.text =
                                        snapshot.data![index].title.toString();
                                    itemQuantityController.text = snapshot
                                        .data![index].quantity
                                        .toString();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              "${snapshot.data![index].title}"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                controller: itemTitleController,
                                              ),
                                              TextField(
                                                controller:
                                                    itemQuantityController,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                shoppingProvider!
                                                    .updateShoppingItem(
                                                  ShoppingItemsHelper(
                                                      title: itemTitleController
                                                          .text,
                                                      listID: args.list.id,
                                                      quantity: double.parse(
                                                          itemQuantityController
                                                              .text),
                                                      isDone: false),
                                                );
                                                itemQuantityController.clear();
                                                itemTitleController.clear();
                                                setState(() {});
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Save"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    shoppingProvider!.deleteShoppingItem(
                                        snapshot.data![index].id!);
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.delete),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class ShoppingListArguments {
  ShoppingListHelper list;
  ShoppingListArguments({required this.list});
}
