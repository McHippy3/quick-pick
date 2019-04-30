import 'package:flutter/material.dart';

class CitationsPage extends StatelessWidget{
  Widget build(BuildContext context){
    List <String> citations = ["Long pants Icon made by Freepik from www.flaticon.com", "Top Hat Icon made by Smashicons from www.flaticon.com", "Socks Icon made by Pause08 from www.flaticon.com", "Laundry basket icon made by iconixar from www.flaticon.com", "Clean icon made by Freepik from www.flaticon.com"];
    return Scaffold(
      appBar: AppBar(
        title: Text("Citations"),
        backgroundColor: Colors.cyan,
      ),
      body: ListView(
        children: citations.map((line) => new Text(line)).toList(),
      ),
    );
  }
}