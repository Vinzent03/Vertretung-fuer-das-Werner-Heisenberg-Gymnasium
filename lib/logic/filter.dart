import 'package:Vertretung/logic/localDatabase.dart';

class Filter {
  LocalDatabase localDatabase = LocalDatabase();

  String stufe;
  Filter(this.stufe);


  Future<List<List<String>>> checker(String day) async {
    ///////////////////////////////  Klasse herausfiltern
    // 0 ist außerhalb der stufe, 1 ist innerhalb, 2 ist außerhalb
    List<String> rawList = await localDatabase.getStringList(day);
    List<String> listWithoutClasses = [];
    int b = 0;
    stufe = stufe.toLowerCase();
    for (String part in rawList) {
      String stk = part.toLowerCase();
      if (stk.contains("std.")) {
        if (b == 1) {
          listWithoutClasses.add(part);
        }
      } else {
        if (stk.contains(stufe)) {
          b = 1;
        } else {
          b = 2;
        }
      }
    }
    /////////////////////////////////////   Jetzt die bessere Sprache
    List<String> betterList = [];
    for(String st in listWithoutClasses){
      if(st.contains("bei +")){
        String beginn = st.substring(0,st.indexOf("bei +")-1);
        String end = st.substring(st.indexOf("bei +")+6);
        st = "$beginn Entfall $end";
      }
      betterList.add(st);
    }
    return [betterList,names(betterList)];
  }


  List<String> names(List<String> data){//das fach pro stunde herausfinden
    List<String> listFaecher = [];
    for(String st in data){
      int beginn = st.indexOf("Std. ")+5;
      int luecke = st.indexOf(" ",beginn);
      int minus = st.indexOf("-",beginn) == -1 ? 20:st.indexOf("-",beginn);// falls kein bindestrich vorhanden ist
      int end = luecke < minus ? luecke: minus;
      listFaecher.add(st.substring(beginn,end));
    }
    return listFaecher;
  }


  Future<List<List<String>>> checkerFaecher(String day,List<dynamic> faecherList,List<dynamic> faecherNotList) async {
    List<List<String>> all = await checker(day);
    List<String> listWithoutClasses = all[0];
    List<String> listWithoutLessons =[];
    if(faecherList.isEmpty || (faecherList[0] == "")){// Wenn man bei der Eingabe alles weg macht
      faecherList = [""];
    }
    if(faecherNotList.isEmpty || (faecherNotList[0] == "")){
      faecherNotList = ["customExample"];
    }


    if(listWithoutClasses.isNotEmpty){
      for (String st in listWithoutClasses) {
        String stLower = st.toLowerCase();

        for (String fach in faecherList) {
          fach = fach.toLowerCase();
          int i = 0;
          for(String fachNot in faecherNotList){

            fachNot = fachNot.toLowerCase();
            if(stLower.contains("bei")){
              stLower = stLower.substring(0,stLower.indexOf("bei"));
            }
            if (stLower.contains(fach)) {
              if(i != 2){
                i = 1;
              }
              if (stLower.contains(fachNot)) {
                i = 2;
              }
            }
          }
          if(i == 1){
            listWithoutLessons.add(st);
          }
        }
      }
    }
    return [listWithoutLessons,names(listWithoutLessons)];
  }
}
