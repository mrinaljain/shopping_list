import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  Future<void> _loadItems() async {
    final baseUrl = Uri.https(
      'shopping-list-cb115-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    // print(response.body);

    // 1. from the whole response only body contains the kaam ka saaman so we will focus on the response.body
    // 2. now response.body looks like json but actualy its not so we will use jsonDecode to make it as a json because jasondecode converts string to json.
    // 3. now we will loop through the  json which is a map {}, so we will use for loop to iterate through each entry of map
    // 4. asign the first key as id and rest key ki value dena hogi as per map ka structure

    try {
      final response = await http.get(baseUrl);
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> listData = json.decode(response.body);
        final List<GroceryItem> loadedItems = [];
        for (var item in listData.entries) {
          /// we will use .value here because in objects/maps we need to specifi valuesnot keys
          final category = categories.entries
              .firstWhere(
                (catItem) => catItem.value.title == item.value['category'],
              )
              .value;
          loadedItems.add(
            GroceryItem(
              id: item.key,
              name: item.value['name'],
              category: category,
              quantity: item.value['quantity'],
            ),
          );
        }
        print(loadedItems);
        setState(() {
          _groceryItems.clear();
          _groceryItems.addAll(loadedItems);
          _isLoading = false;
        });
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Something went wrong"),
              actions: [
                TextButton(
                  onPressed: () {
                    _loadItems();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Reload"),
                ),
              ],
            );
          });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) {
      return;
    }
    _groceryItems.add(newItem);
    setState(() {});
  }

  void _removeItem(GroceryItem groceryItem) async {
    final index = groceryItems.indexOf(groceryItem);
    setState(() {
      _groceryItems.remove(groceryItem);
    });
    print('Item DEleted');

    /// Delet needs a specific URL which includes the id of the node which needs to be deleted
    final baseUrl = Uri.https(
      'shopping-list-cb115-default-rtdb.firebaseio.com',
      'shopping-list/${groceryItem.id}.json',
    );
    final response = await http.delete(
      baseUrl,
    );
    if (response.statusCode >= 400) {
      print('Inable to Deleat');
      setState(() {
        groceryItems.insert(index, groceryItem);
      });
      print('Item Re added');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _groceryItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text("Opps you have not added any Items..")],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    return _loadItems();
                  },
                  child: ListView.builder(
                      itemCount: _groceryItems.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: ValueKey(_groceryItems[index].id),
                          background: Container(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          onDismissed: (DismissDirection dismissDirection) =>
                              _removeItem(_groceryItems[index]),
                          child: ListTile(
                            leading: Icon(
                              Icons.add_box,
                              color: _groceryItems[index].category.color,
                            ),
                            title: Text(_groceryItems[index].name),
                            trailing: Text("${_groceryItems[index].quantity}"),
                          ),
                        );
                      }),
                ),
    );
  }
}
