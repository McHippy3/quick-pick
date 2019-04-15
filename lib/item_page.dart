import 'package:flutter/material.dart';
import 'clothes.dart';
import 'dart:io';
import 'add_edit.dart';
import 'main.dart';

class ItemPage extends StatefulWidget {
  final ClothingItem clothingItem;
  final File clothingFile;
  final List<List<ClothingItem>> clothes;

  ItemPage(this.clothingItem, this.clothingFile, this.clothes);

  @override
  State<StatefulWidget> createState() {
    return _ItemPageState(clothingItem, clothingFile, clothes);
  }
}

class _ItemPageState extends State<ItemPage> {
  final ClothingItem clothingItem;
  final File clothingFile;
  final List<List<ClothingItem>> clothes;
  Image clothingImage;
  bool isLoading = false;

  _ItemPageState(this.clothingItem, this.clothingFile, this.clothes);

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  void _loadAssets() async {
    isLoading = true;
    File imageFile = File(clothingItem.imagePath);
    if (clothingItem.imagePath != "n/a") {
      clothingImage = Image.file(imageFile);
    } else {
      clothingImage = Image.asset("assets/no-image.png", scale: 0.5);
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Item Screen"),
        backgroundColor: Colors.cyan,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddEditPage(clothingFile, clothes,
                        editItem: clothingItem))),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteItem(clothingItem),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: deviceInfo.size.width / 20,
                      right: deviceInfo.size.width / 20,
                      top: deviceInfo.size.width / 20),
                  child: Text(
                    clothingItem.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(deviceInfo.size.width / 20),
                  child: clothingImage,
                ),
                _ItemRow("Type of Clothing: ", clothingItem.type),
                _ItemRow("Ideal Temperatures: ", _formattedTemps),
                _ItemRow("Available: ", clothingItem.available.toString()),
                Padding(
                  padding: EdgeInsets.only(bottom: deviceInfo.size.width / 20),
                ),
              ],
            ),
    );
  }

  String get _formattedTemps {
    //Converting to list to add commas between elements
    String formatted = clothingItem.tempsAsString.split(" ").toString();
    //Getting rid of starting and ending square brackets
    formatted = formatted.substring(1, formatted.length - 1);
    return formatted;
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
    Navigator.pop(context);
  }
}

class _ItemRow extends StatelessWidget {
  final String leading, trailing;

  _ItemRow(this.leading, this.trailing);

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);
    return Padding(
        padding: EdgeInsets.only(
            left: deviceInfo.size.width / 20,
            right: deviceInfo.size.width / 20,
            top: deviceInfo.size.width / 20),
        child: RichText(
          text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 20),
              children: <TextSpan>[
                TextSpan(
                    text: leading,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: trailing),
              ]),
        ));
  }
}
