import 'package:flutter/material.dart';
import 'weather.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers.dart';

class SettingsPage extends StatefulWidget{
  
  final Weather weather;
  final PrimitiveWrapper autoSelect;
  
  SettingsPage(this.weather, this.autoSelect);
  
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState(weather, autoSelect);
  }
}

class _SettingsPageState extends State <SettingsPage> {
  int temperature;
  Weather weather;
  PrimitiveWrapper autoSelect = PrimitiveWrapper(false);

  _SettingsPageState(this.weather, this.autoSelect){
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
                 updateTempPrefs(); 
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
          SwitchListTile(
            title: Text("Auto-Select"),
            value: autoSelect.primitive,
            onChanged: (bool newVal) {
              setState(() {
               updateSelectPrefs(); 
              });
            },
          ),
        ],
      ),
    );
  }

  void updateTempPrefs() async{
    weather.convertUnits();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("temp_units", weather.unit);
  }

  void updateSelectPrefs() async {
    autoSelect.primitive = !autoSelect.primitive;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("auto_select", autoSelect.primitive);
  }
}
