import 'package:flutter/material.dart';
import 'weather.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget{
  
  final Weather weather;
  SettingsPage(this.weather);
  
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState(weather);
  }
}

class _SettingsPageState extends State <SettingsPage> {
  int temperature;
  Weather weather;

  _SettingsPageState(this.weather){
    temperature = weather.unit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.cyan,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Preferred Units"),
            subtitle: Text("Select default unit of temperature"),
            trailing: DropdownButton <int> (
              value: temperature,
              onChanged: (int newValue) {
                setState(() {
                 temperature = newValue;
                 updatePrefs(); 
                });
              },
              items: <DropdownMenuItem<int>> [
                DropdownMenuItem<int>(
                  value: 0,
                  child: Text("Celcius"),
                ),
                DropdownMenuItem <int>(
                  value: 1,
                  child: Text("Fahrenheit"),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

  void updatePrefs() async{
    weather.convertUnits();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('temp_units', weather.unit);
  }
}
