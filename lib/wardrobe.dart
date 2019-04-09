import 'package:flutter/material.dart';
import 'clothes.dart';
import 'dart:io';
import 'item_page.dart';
import 'custom_icons.dart';

/// Displays all items in the users 'wardrobe', allows deletion or modification of items
class WardrobePage extends StatefulWidget {
  final List<List<ClothingItem>> clothes;
  final File clothingFile;

  WardrobePage(this.clothes, this.clothingFile);

  @override
  State<StatefulWidget> createState() {
    return _WardrobePageState(this.clothes, this.clothingFile);
  }
}

class _WardrobePageState extends State<WardrobePage> {
  final List<List<ClothingItem>> clothes;
  final File clothingFile;

  _WardrobePageState(this.clothes, this.clothingFile);

  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("All Clothing Items"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _deleteAll,
          ),
        ],
      ),
      body: ListView(
          children:
              _getAllItems(deviceInfo.size.width / 20, context, deviceInfo)),
    );
  }

  //Returns a list of cards containing all the clothing items
  List<Widget> _getAllItems(
      double paddingValue, BuildContext context, MediaQueryData deviceInfo) {
    List<Widget> allItems = [];
    for (List<ClothingItem> list in clothes) {
      for (ClothingItem item in list) {
        allItems.add(
          Padding(
            padding: EdgeInsets.only(
                left: paddingValue, right: paddingValue, top: paddingValue),
            child: Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ItemPage(item, clothingFile, clothes)));
                },
                leading: item.icon,
                title: Text(item.name),
                subtitle: Text(item.type),
                trailing: Container(
                  width: deviceInfo.size.width / 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(
                        icon: item.available
                            ? Icon(CustomIcons.laundry_basket)
                            : Icon(Icons.ac_unit),
                        onPressed: () => _changeLaundryState(item),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteItem(item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return allItems;
  }

  void _deleteItem(ClothingItem toDeleteItem) async {
    for (List<ClothingItem> list in clothes) {
      for (ClothingItem item in list) {
        if (item == toDeleteItem) {
          list.remove(item);
          break;
        }
      }
    }
    clothingFile.writeAsStringSync("");
    if (File(toDeleteItem.imagePath).existsSync()) {
      imageCache.clear();
      File(toDeleteItem.imagePath).deleteSync();
    }
    for (List<ClothingItem> list in clothes) {
      for (ClothingItem item in list) {
        clothingFile.writeAsStringSync(
            "#${item.id}\n${item.name}\n${item.type}\n${item.available.toString()}\n${item.tempsAsString}\n",
            mode: FileMode.writeOnlyAppend);
      }
    }
    setState(() {});
  }

  void _deleteAll() {
    //Completely clearing out file
    clothingFile.writeAsStringSync("");
    for (List<ClothingItem> list in clothes) {
      list.clear();
    }
    setState(() {});
  }

  void _changeLaundryState(ClothingItem toChangeItem) async {
    toChangeItem.available = !toChangeItem.available;
    for (List<ClothingItem> list in clothes) {
      for (ClothingItem item in list) {
        clothingFile.writeAsString(
            "#${item.id}\n${item.name}\n${item.type}\n${item.available.toString()}\n${item.tempsAsString}\n",
            mode: FileMode.writeOnlyAppend);
      }
    }
    setState(() {});
  }
}
