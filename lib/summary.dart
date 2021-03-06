import 'package:flutter/material.dart';
import 'weather.dart';
import 'clothes.dart';
import 'custom_icons.dart';
import 'helpers.dart';
import 'dart:io';

class SummaryPage extends StatelessWidget {
  final bool isLoading, autoSelect;
  final Weather weather;
  final List<List<ClothingItem>> clothes;
  final Function callback;
  final File clothingFile;

  SummaryPage(
      {this.autoSelect,
      this.isLoading,
      this.weather,
      this.clothes,
      this.callback,
      this.clothingFile});

  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    //Getting info such as screen size
    MediaQueryData deviceInfo = MediaQuery.of(context);

    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Center(
                child: Image.network(
                    "http://openweathermap.org/img/w/${weather.imageId}.png")),
            Text(
              "${weather.city}",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Text(
              "${weather.description}",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
            Text(
              getFormattedTemp(weather.unit, weather.temperature),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Text(
            "Clothing Suggestions",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: _getSuggestion(deviceInfo),
          ),
        ),
      ],
    );
  }

  //Returns a column of tiles containing all the clothing options
  List<Widget> _getSuggestion(MediaQueryData deviceInfo) {
    //Using metric
    num temp = weather.temperature;
    if (weather.unit != 0) {
      temp = convertToMetric(temp);
    }

    //Adding to suggestions if item is in temperature zone and is available
    //Only one of each type of clothing is included
    List<Widget> clothingList = [];
    List<String> remainingTypes = [
      "top",
      "bottom",
      "top & bottom",
      "socks",
      "hat"
    ];
    for (List<ClothingItem> list in clothes) {
      for (ClothingItem item in list) {
        //limit number of each type of clothing item if autoSelect is on
        if (item.available && item.temps.contains(weather.tempZone) &&
            ((remainingTypes.contains(item.type) ||
                !autoSelect))) {
          //Ensuring that "top & bottom" doesn't overlap with an individual top and an individual bottom
          if (autoSelect) {
            if (item.type == "top & bottom") {
              remainingTypes.remove("top");
              remainingTypes.remove("bottom");
            } else if (item.type == "top" || item.type == "bottom") {
              remainingTypes.remove("top & bottom");
            }
            remainingTypes.remove(item.type);
          }

          clothingList.add(
            Padding(
              padding: EdgeInsets.only(
                  left: deviceInfo.size.width / 20,
                  right: deviceInfo.size.width / 20,
                  bottom: deviceInfo.size.width / 20),
              child: Card(
                child: ListTile(
                  leading: item.icon,
                  title: Text(item.name),
                  subtitle: Text(item.type),
                  trailing: IconButton(
                    icon: Icon(CustomIcons.basket),
                    onPressed: () => ClothingItem.changeLaundryState(
                        item, clothingFile, clothes, callback),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    return clothingList;
  }
}
