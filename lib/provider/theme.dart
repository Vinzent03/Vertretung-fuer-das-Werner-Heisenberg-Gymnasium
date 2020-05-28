import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/provider/themedata.dart';
class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;
  ThemeChanger(this._themeData,this.isDark,this.newRestore,this.newRestore2);
  bool isDark;
  bool newRestore;
  bool newRestore2;
  getTheme() => _themeData;

  /// Return true if the dark mode is activated
  getIsDark() => isDark;

  setDarkTheme() {
    isDark = true;
    LocalDatabase().setBool(Names.dark, true);
    _themeData = darkTheme;
    notifyListeners();
  }

  setLightTheme() {
    isDark= false;
    LocalDatabase().setBool(Names.dark, false);
    _themeData = lightTheme;
    notifyListeners();
  }
  

  getVertretungReload()=> newRestore;

  setVertretungReload(restore){
    newRestore = restore;
    notifyListeners();
  }

  getFriendReload()=> newRestore2;

  setFriendReload(restore){
    newRestore2 = restore;
    notifyListeners();
  }

}