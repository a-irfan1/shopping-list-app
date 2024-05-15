import 'package:flutter/material.dart';
import 'package:flutter_lorem/flutter_lorem.dart';
import 'package:shopping_list/main.dart';
import 'package:shopping_list/shopping_list.dart';

import 'util/sql_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  List<ShoppingListHelper> shoppingLists = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Shopping List",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Text(lorem(paragraphs: 1, words: 10)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(MediaQuery.sizeOf(context).width, 50),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("New list"),
                          content: TextField(
                            controller: nameController,
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
                                if (nameController.text.isNotEmpty) {
                                  shoppingProvider?.insertShoppingList(
                                      ShoppingListHelper(
                                          title: nameController.text));
                                }
                                setState(() {});
                                nameController.clear();
                                Navigator.pop(context);
                              },
                              child: const Text("Save"),
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Create new list"),
                ),
              ),
              FutureBuilder<List<ShoppingListHelper>>(
                future: shoppingProvider?.getShoppingLists(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: Row(
                            children: [
                              ListTile(
                                title: Text(snapshot.data![index].title ?? ""),
                                subtitle: const Text(""),
                                trailing:
                                    const Icon(Icons.keyboard_arrow_right),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ShoppingList.routeName,
                                      arguments: ShoppingListArguments(
                                          list: snapshot.data![index]));
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  nameController.text =
                                      snapshot.data![index].title!;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Edit list"),
                                        content: TextField(
                                          controller: nameController,
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
                                              if (nameController
                                                  .text.isNotEmpty) {
                                                shoppingProvider
                                                    ?.updateShoppingList(
                                                        ShoppingListHelper(
                                                            title:
                                                                nameController
                                                                    .text));
                                              }
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Save"),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
