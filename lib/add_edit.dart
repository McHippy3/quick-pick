import 'package:flutter/material.dart';
import 'row_textfield.dart';
import 'dart:io';
import 'weather.dart';
import 'helpers.dart';
import 'clothes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';

class AddEditPage extends StatefulWidget {
  final File clothingFile;
  final List<List<ClothingItem>> clothes;
  final ClothingItem editItem;
  final Weather weather;

  AddEditPage(this.clothingFile, this.clothes, this.weather, {this.editItem});

  @override
  State<StatefulWidget> createState() {
    Map<String, bool> temperatures = {
      'hot': false,
      'warm': false,
      'cool': false,
      'cold': false,
    };

    return _AddEditPageState(temperatures, clothingFile, clothes, weather,
        editItem: editItem);
  }
}

enum ClothingType { top, bottom, topBot, socks, hat }

/// If an item is passed in, then the page is for editing, else for adding
class _AddEditPageState extends State<AddEditPage> {
  final Weather weather;
  TextEditingController _nameController;
  Map<String, bool> temperatures;
  ClothingType type;
  File clothingFile, image;
  List<List<ClothingItem>> clothes;
  IconButton _submitButton;
  ClothingItem editItem;
  String appBarTitle;
  int lowTemp, highTemp;

  _AddEditPageState(
      this.temperatures, this.clothingFile, this.clothes, this.weather,
      {this.editItem}) {
    _nameController = TextEditingController();
    _submitButton = IconButton(icon: Icon(Icons.check), onPressed: null);
    if (editItem == null) {
      appBarTitle = "Add New Item";
      if(weather.unit == 0){
        lowTemp = -40;
        highTemp = 60;
      }
      else{
        lowTemp = -40;
        highTemp = 135;
      }
    }
    //Setting default values if in editing mode
    else {
      ///Temporary:
      lowTemp = 0;
      highTemp = 0;
      
      appBarTitle = "Edit ${editItem.name}";
      _nameController.text = editItem.name;
      //Default type
      switch (editItem.type) {
        case "top":
          type = ClothingType.top;
          break;
        case "bottom":
          type = ClothingType.bottom;
          break;
        case "socks":
          type = ClothingType.socks;
          break;
        case "hat":
          type = ClothingType.hat;
          break;
        default:
          type = ClothingType.topBot;
      }
      //Default temperatures
      List<String> defTemps = editItem.tempsAsString.trim().split(" ");
      for (String key in defTemps) {
        temperatures[key] = true;
      }
      if (editItem.imagePath != "n/a") {
        image = File(editItem.imagePath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //Used to accomodate different screen sizes
    MediaQueryData deviceInfo = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.cyan,
        actions: <Widget>[_submitButton],
      ),
      body: ListView(children: <Widget>[
        RowTextField(
          frontText: "Name: ",
          widthTextField: deviceInfo.size.width * 0.6,
          fontSize: deviceInfo.size.width / 20,
          controller: _nameController,
          paddingValue: deviceInfo.size.width / 25,
          onChange: _checkFilled,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: deviceInfo.size.width / 25),
          child: Center(
            child: image == null
                ? RaisedButton.icon(
                    icon: Icon(Icons.image),
                    label: Text("Add Image"),
                    onPressed: _getImage,
                  )
                : RaisedButton.icon(
                    icon: Icon(Icons.close),
                    label: Text("Remove Image"),
                    onPressed: () {
                      setState(() {
                        image = null;
                        _checkFilled();
                      });
                    },
                  ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(deviceInfo.size.width / 20),
            child:
                image == null ? Text("No Image Selected") : Image.file(image),
          ),
        ),
        ListTile(
          title: Text(
            "Clothing Type",
            style: TextStyle(fontSize: deviceInfo.size.width / 20),
          ),
          trailing: DropdownButton(
            value: type,
            items: <DropdownMenuItem<ClothingType>>[
              DropdownMenuItem(
                value: ClothingType.top,
                child: Text("Top"),
              ),
              DropdownMenuItem(
                value: ClothingType.bottom,
                child: Text("Bottom"),
              ),
              DropdownMenuItem(
                value: ClothingType.topBot,
                child: Text("Top & Bottom"),
              ),
              DropdownMenuItem(
                value: ClothingType.socks,
                child: Text("Socks"),
              ),
              DropdownMenuItem(
                value: ClothingType.hat,
                child: Text("Hat"),
              ),
            ],
            onChanged: (ClothingType newType) {
              setState(() {
                type = newType;
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(deviceInfo.size.width / 25),
          child: Text(
            "Temperature Range:",
            style: TextStyle(fontSize: deviceInfo.size.width / 20),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: temperatures.keys.map((String key) {
            return CheckboxListTile(
              title: new Text(key),
              value: temperatures[key],
              onChanged: (bool value) {
                setState(() {
                  temperatures[key] = value;
                  _checkFilled();
                });
              },
            );
          }).toList(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Text(getFormattedTemp(weather.unit, lowTemp.toDouble())),
              Expanded(
                child: RangeSlider(
                  min: weather.unit == 0 ? -40.0 : -40.0,
                  max: weather.unit == 0 ? 60.0 : 135.0,
                  divisions: weather.unit == 0 ? 100 : 175,
                  lowerValue: lowTemp.toDouble(),
                  upperValue: highTemp.toDouble(),
                  onChanged: (double low, double high) {
                    setState(() {
                      lowTemp = low.round();
                      highTemp = high.round();
                    });
                  },
                ),
              ),
              Text(getFormattedTemp(weather.unit, highTemp.toDouble())),
            ],
          ),
        ),
      ]),
    );
  }

  //Enable submit if all fields are full
  void _checkFilled() {
    if (_nameController.text.isNotEmpty &&
        type != null &&
        temperatures.containsValue(true)) {
      setState(() {
        if (editItem == null) {
          _submitButton =
              IconButton(icon: Icon(Icons.check), onPressed: _addClothingItem);
        } else
          _submitButton =
              IconButton(icon: Icon(Icons.check), onPressed: _editClothingItem);
      });
    } else if (_submitButton.onPressed != null) {
      setState(() {
        _submitButton = IconButton(icon: Icon(Icons.check), onPressed: null);
      });
    }
  }

  void _getImage() async {
    image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _checkFilled();
    });
  }

  void _addClothingItem() async {
    ClothingItem newItem = ClothingItem.empty();

    //Id
    //highest current id + 1
    newItem.id = 1;
    for (List<ClothingItem> list in clothes) {
      for (ClothingItem item in list) {
        if (item.id >= newItem.id) {
          newItem.id = item.id + 1;
        }
      }
    }

    //Name
    newItem.name = _nameController.text;

    //Type
    switch (type) {
      case ClothingType.top:
        newItem.type = "top";
        break;
      case ClothingType.bottom:
        newItem.type = "bottom";
        break;
      case ClothingType.socks:
        newItem.type = "socks";
        break;
      case ClothingType.hat:
        newItem.type = "hat";
        break;
      default:
        newItem.type = "top & bottom";
    }

    //Availability
    newItem.available = true;

    //Temperatures
    if (temperatures["hot"]) {
      newItem.temps.add(Temperatures.hot);
      newItem.tempsAsString = newItem.tempsAsString + "hot ";
    }
    if (temperatures["warm"]) {
      newItem.temps.add(Temperatures.warm);
      newItem.tempsAsString = newItem.tempsAsString + "warm ";
    }
    if (temperatures["cool"]) {
      newItem.temps.add(Temperatures.cool);
      newItem.tempsAsString = newItem.tempsAsString + "cool ";
    }
    if (temperatures["cold"]) {
      newItem.temps.add(Temperatures.cold);
      newItem.tempsAsString = newItem.tempsAsString + "cold ";
    }

    //Creating image
    if (image != null) {
      String path = (await getApplicationDocumentsDirectory()).path;
      path = path + "/${newItem.id}." + (image.path.split(".")).last;
      newItem.imagePath = path;
      await image.copy(path);
    } else {
      newItem.imagePath = "n/a";
    }

    clothingFile.writeAsStringSync(
        "#${newItem.id}\n${newItem.name}\n${newItem.type}\n${newItem.available.toString()}\n${newItem.tempsAsString}\n${newItem.imagePath}\n",
        mode: FileMode.writeOnlyAppend);
    Navigator.of(context)
        .pushNamedAndRemoveUntil("/main", (Route<dynamic> route) => false);
  }

  void _editClothingItem() async {
    //Name
    editItem.name = _nameController.text;

    //Type
    switch (type) {
      case ClothingType.top:
        editItem.type = "top";
        break;
      case ClothingType.bottom:
        editItem.type = "bottom";
        break;
      case ClothingType.socks:
        editItem.type = "socks";
        break;
      case ClothingType.hat:
        editItem.type = "hat";
        break;
      default:
        editItem.type = "top & bottom";
    }

    //Temperatures
    editItem.temps.clear();
    editItem.tempsAsString = "";
    if (temperatures["hot"]) {
      editItem.temps.add(Temperatures.hot);
      editItem.tempsAsString = editItem.tempsAsString + "hot ";
    }
    if (temperatures["warm"]) {
      editItem.temps.add(Temperatures.warm);
      editItem.tempsAsString = editItem.tempsAsString + "warm ";
    }
    if (temperatures["cool"]) {
      editItem.temps.add(Temperatures.cool);
      editItem.tempsAsString = editItem.tempsAsString + "cool ";
    }
    if (temperatures["cold"]) {
      editItem.temps.add(Temperatures.cold);
      editItem.tempsAsString = editItem.tempsAsString + "cold ";
    }
    //Creating image
    if (image != null && image.path != editItem.imagePath) {
      if (File(editItem.imagePath).existsSync()) {
        File(editItem.imagePath).deleteSync();
      }
      String path = (await getApplicationDocumentsDirectory()).path;
      path = path + "/${editItem.id}." + (image.path.split(".")).last;
      editItem.imagePath = path;
      await image.copy(path);
    } else if (image == null) {
      editItem.imagePath = "n/a";
    }
    imageCache.clear();

    ClothingItem.rewriteFile(clothes, clothingFile);
    Navigator.of(context)
        .pushNamedAndRemoveUntil("/main", (Route<dynamic> route) => false);
  }
}
