///Contains Functions for updating the user information to be compatible
///with the current version
///function format: update[first number]_[second number]_[third number]

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'clothes.dart';

void checkForUpdates(String currentVersion) async {
  //Converting current version to an integer without any periods
  int currentVersionInt =
      int.parse(currentVersion[0] + currentVersion[2] + currentVersion[4]);
  if (currentVersionInt <= 101) {
    update1_0_1();
  }
}

//Changed file format to temperature range instead of zones
//Called for users of version 1.0.1 as well because some 1.0.0 users are labeled as 1.0.1 (versioning system implemented in 1.0.1)
void update1_0_1() async {
  File clothingFile =
      File("${(await getApplicationDocumentsDirectory()).path}/clothes.dat");

  //Only make changes if the file already exists
  if (await clothingFile.exists()) {
    List<String> content = (await clothingFile.readAsString())
        .split("\n")
        .where((line) => line != "")
        .toList();
    //Checking for outdated file content
    if (content.contains("hot") ||
        content.contains("warm") ||
        content.contains("cool") ||
        content.contains("cold")) {
          //Setting low temp to be the lowest temp zone and high temp to be the highest temp zone
          for(int i = 4; i < content.length; i += 6){
            double lowTemp, highTemp;
            List <String> tempZones = content[i].split(" ");
            switch(tempZones[0]){
              case "hot": highTemp = 40; break;
              case "warm": highTemp = 20; break;
              case "cool": highTemp = 10; break;
              case "cold": highTemp = -5; break;
            }
            switch(tempZones[tempZones.length-1]){
              case "hot": lowTemp = 20; break;
              case "warm": lowTemp = 10; break;
              case "cool": lowTemp = -5; break;
              case "cold": lowTemp = -30; break;
            }
            
          }
    }
  }
}
