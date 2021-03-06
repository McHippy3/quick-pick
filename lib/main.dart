import 'weather.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'summary.dart';
import 'clothes.dart';
import 'add_edit.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'wardrobe.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
import 'helpers.dart';
import 'update.dart';

void main() => runApp(
      MaterialApp(
        title: "Quick Pick",
        debugShowCheckedModeBanner: false,
        routes: {
          '/main': (context) => MainPage(),
        },
        home: MainPage(),
      ),
    );

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLoading;
  PrimitiveWrapper autoSelect = PrimitiveWrapper(false);
  Weather weather;
  List<List<ClothingItem>> clothes = [];
  File clothingFile;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateTime.now().toString().substring(0, 10)),
        backgroundColor: Colors.cyan,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.assignment),
            onPressed: isLoading
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WardrobePage(clothes, clothingFile, weather),
                      ),
                    ),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: isLoading
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(weather, autoSelect),
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: isLoading
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEditPage(this.clothingFile, this.clothes, this.weather),
                  ),
                ),
      ),
      body: SummaryPage(
        autoSelect: autoSelect.primitive,
        isLoading: isLoading,
        weather: weather,
        clothes: clothes,
        callback: setStateMethod,
        clothingFile: this.clothingFile,
      ),
    );
  }

  //Made partly with the help of https://dragosholban.com/2018/07/01/how-to-build-a-simple-weather-app-in-flutter/ and https://flutter.dev/docs/cookbook/networking/fetch-data
  //Weather information and images provided by https://openweathermap.org/api
  void _fetchWeather() async {
    isLoading = true;
    //Getting location
    num lat, lon;
    try {
      var location = new Location();
      Map<String, double> currentLoc = await location.getLocation();
      lat = currentLoc['latitude'];
      lon = currentLoc['longitude'];
    } on Exception {
      lat = 0;
      lon = 0;
    }

    //Getting weather data
    http.Response response = await http.get(
        "http://api.openweathermap.org/data/2.5/weather?lat=${lat.toString()}&lon=${lon.toString()}&appid=7000894b3eefc3b3bee0fa5cc2152fb1&units=metric");

    if (response.statusCode == 200) {
      weather = Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to retrieve weather data");
    }

    _initClothing();
  }

  void _initClothing() async {
    isLoading = true;

    //Opening File
    String path = (await getApplicationDocumentsDirectory()).path;
    //File("$path/clothes.dat").deleteSync();
    clothingFile = File('$path/clothes.dat');
    if (!(await clothingFile.exists())) {
      clothingFile.createSync();
    }
    List<String> clothingInfo = (await clothingFile.readAsString())
        .split("\n")
        .where((line) => line != "")
        .toList();
    print(clothingInfo.toString());

    //Initializing the five lists within clothes, one for each type of clothing
    //Order: top, bottom, top & bottom, socks, hat
    for (int i = 0; i < 5; i++) {
      clothes.add([]);
    }

    //Converting contents of file into a list of ClothingItem objects
    for (int i = 0; i < clothingInfo.length; i += 6) {
      ClothingItem item = ClothingItem(
          int.parse(clothingInfo[i].substring(1)),
          clothingInfo[i + 1],
          clothingInfo[i + 2],
          clothingInfo[i + 3],
          clothingInfo[i + 4].split(" "),
          clothingInfo[i + 5]);
      switch (item.type) {
        case "top":
          clothes[0].add(item);
          break;
        case "bottom":
          clothes[1].add(item);
          break;
        case "top & bottom":
          clothes[2].add(item);
          break;
        case "socks":
          clothes[3].add(item);
          break;
        case "hat":
          clothes[4].add(item);
          break;
      }
    }

    //Setting preferred options
    updatePreferences();
  }

  //Reads from user's shared preferences
  void updatePreferences() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int prefUnits = prefs.getInt('temp_units');
    autoSelect.primitive = prefs.getBool('auto_select');
    String currentVersion = prefs.getString('version');

    //Create the shared preference if it doesn't exist
    if (prefUnits == null || autoSelect.primitive == null) {
      prefs.setInt('temp_units', weather.unit);
      prefs.setBool('auto_select', true);
      autoSelect.primitive = true;
    }
    if (prefUnits != weather.unit) {
      weather.convertUnits();
    }

    //Creating shared preference for currentVersion
    if(currentVersion == null){
      prefs.setString('version', (await PackageInfo.fromPlatform()).version);
      currentVersion = prefs.getString('version');
    }
    String newestVersion = (await PackageInfo.fromPlatform()).version;

    //Check to see if edits must be made to accomodate current version
    checkForUpdates(clothingFile, currentVersion, newestVersion);

    //Refresh with new info
    setState(() {
      isLoading = false;
    });
  }

  //Used for callback
  void setStateMethod() {
    setState(() {});
  }
}
