import 'dart:io';
import 'package:flutter/material.dart';
import 'custom_icons.dart';

enum Temperatures { hot, warm, cool, cold }

class ClothingItem {
  int id;
  String name, type, tempsAsString = "", imagePath;
  bool available;
  List<Temperatures> temps = [];
  double lowTemp, highTemp;
  Icon icon;

  //Pass in information from file
  ClothingItem(
    this.id,
    this.name,
    this.type,
    String available,
    List<String> temperatures,
    this.imagePath,
  ) {
    if (available == "true") {
      this.available = true;
    } else {
      this.available = false;
    }
    for (String s in temperatures) {
      switch (s) {
        case "hot":
          temps.add(Temperatures.hot);
          tempsAsString = tempsAsString + "hot ";
          break;
        case "warm":
          temps.add(Temperatures.warm);
          tempsAsString = tempsAsString + "warm ";
          break;
        case "cool":
          temps.add(Temperatures.cool);
          tempsAsString = tempsAsString + "cool ";
          break;
        case "cold":
          temps.add(Temperatures.cold);
          tempsAsString = tempsAsString + "cold ";
          break;
        default:
      }
    }
    tempsAsString = tempsAsString.trim();

    //Icon
    switch (type) {
      case "top":
        icon = Icon(CustomIcons.shirt);
        break;
      case "bottom":
        icon = Icon(CustomIcons.long_pants);
        break;
      case "top & bottom":
        icon = Icon(Icons.accessibility);
        break;
      case "socks":
        icon = Icon(CustomIcons.socks);
        break;
      default:
        icon = Icon(CustomIcons.top_hat);
    }
  }

  //Basic empty constructor
  ClothingItem.empty();

  //Placing item in or out of the "laundry basket"
  static void changeLaundryState(ClothingItem item, File clothingFile,
      List<List<ClothingItem>> clothes, Function callBack) {
    item.available = !item.available;

    ClothingItem.rewriteFile(clothes, clothingFile);
    
    callBack();
  }

  static void rewriteFile(List<List<ClothingItem>> clothes, File clothingFile) {
    //Clear and rewrite file
    clothingFile.writeAsStringSync("");
    for (List<ClothingItem> list in clothes) {
      for (ClothingItem item in list) {
        clothingFile.writeAsStringSync(
            "#${item.id}\n${item.name}\n${item.type}\n${item.available.toString()}\n${item.tempsAsString}\n${item.imagePath}\n",
            mode: FileMode.writeOnlyAppend);
      }
    }
  }
}
