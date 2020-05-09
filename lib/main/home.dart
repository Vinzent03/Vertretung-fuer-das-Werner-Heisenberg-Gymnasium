import 'package:Vertretung/friends/friends.dart';
import 'package:Vertretung/logic/theme.dart';
import 'package:provider/provider.dart';
import 'package:Vertretung/pages/newsPage.dart';
import 'package:Vertretung/pages/VertretungsPage.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/logic/functionsForMain.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget usedPage = Vertretung();

  int currentIndex = 0;
  @override
  void initState() {
    showUpdateDialog(context);
    super.initState();
  }
  final List<Widget> pages = [
    Vertretung(),
    Friends(),
    NewsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(//damit beim page wechsel nichte alles neugeladen werden muss
        children: pages,
        index: currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: currentIndex,
        backgroundColor: Provider.of<ThemeChanger>(context).getIsDark()
            ? Colors.black
            : Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text("Vertretung"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            title: Text("Freunde"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            title: Text("Nachrichten"),
          ),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
