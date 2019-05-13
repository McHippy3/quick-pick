///Contains Functions for updating the user information to be compatible
///with the current version
///function format: update[first number]_[second number]_[third number]

import 'dart:io';
import 'package:path_provider/path_provider.dart';

void checkForUpdates(String currentVersion) async{
  //Converting current version to an integer without any periods
  int currentVersionInt = int.parse(currentVersion[0] + currentVersion[2] + currentVersion[4]);
  if(currentVersionInt <= 101){
    update1_0_1();
  }
}

//Changed file format to temperature range instead of zones
//Called for users of version 1.0.1 as well because some 1.0.0 users are labeled as 1.0.1 (versioning system implemented in 1.0.1)
void update1_0_1() async{
  if(await File("${(await getApplicationDocumentsDirectory()).path}/clothes.dat").exists()){
  }
}