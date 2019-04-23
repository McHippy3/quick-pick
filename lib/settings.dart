import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State <SettingsPage> {
  int temperature;

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
}
