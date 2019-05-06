import 'package:flutter/material.dart';
import 'clothes.dart';
import 'dart:io';
import 'item_page.dart';
import 'weather.dart';
import 'custom_icons.dart';

/// Displays all items in the users 'wardrobe', allows deletion or modification of items
class WardrobePage extends StatefulWidget {
  final List<List<ClothingItem>> clothes;
  final File clothingFile;
  final Weather weather;

  WardrobePage(this.clothes, this.clothingFile, this.weather);

  @override
  State<StatefulWidget> createState() {
    return _WardrobePageState(this.clothes, this.clothingFile, this.weather);
  }
}

class _WardrobePageState extends State<WardrobePage> {
  final List<List<ClothingItem>> clothes;
  final File clothingFile;
  final Weather weather;

  _WardrobePageState(this.clothes, this.clothingFile, this.weather);

  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("All Clothing Items"),
        backgroundColor: Colors.cyan,
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
                              ItemPage(item, clothingFile, clothes, weather)));
                },
                leading: item.icon,
                title: Text(item.name),
                subtitle: Text(item.type),
                trailing: IconButton(
                  icon: item.available
                      ? Icon(CustomIcons.basket)
                      : Icon(CustomIcons.clean),
                  onPressed: () => ClothingItem.changeLaundryState(item, clothingFile, clothes, setStateMethod),
                ),
              ),
            ),
          ),
        );
      }
    }
    return allItems;
  }

  void _deleteAll() {
    //Completely clearing out file
    clothingFile.writeAsStringSync("");
    for (List<ClothingItem> list in clothes) {
      list.clear();
    }
    setState(() {});
  }

  //Used as a callback 
  void setStateMethod(){
    setState(() { 
    });
  }
}
