import 'package:Vertretung/friends/friendsPage.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:provider/provider.dart';
import 'package:Vertretung/news/newsPage.dart';
import 'package:Vertretung/substitute//substitutePage.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  GlobalKey<FriendsState> friendKey = GlobalKey();
  GlobalKey<NewsPageState> newsKey = GlobalKey();
  List<Widget> pages;
  Future<void> showUpdateDialog(context) async {
    CloudDatabase cd = CloudDatabase();

    updateCodes updateSituation = await cd.getUpdate();
    String link = await cd.getUpdateLink();
    List<dynamic> message = await cd.getUpdateMessage();

    if (updateCodes.availableNormal == updateSituation ||
        updateCodes.availableForce == updateSituation) {
      if (updateCodes.availableForce == updateSituation)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              // ignore: missing_return
              onWillPop: () {},
              child: AlertDialog(
                title: Text(message[0]),
                content: Text(message[1]),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("Update"),
                    onPressed: () => launch(link),
                  )
                ],
              ),
            );
          },
        );
      else
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: Text(message[0]),
              content: Text(message[1]),
              actions: <Widget>[
                FlatButton(
                  child: Text("abbrechen"),
                  onPressed: () => Navigator.pop(context),
                ),
                RaisedButton(
                  child: Text("Update"),
                  onPressed: () => launch(link),
                )
              ],
            );
          },
        );
    }
  }

  _HomeState() {
    pages = [
      VertretungsPage(reloadFriendsSubstitute: reloadFriendsSubstitute),
      Friends(
        key: friendKey,
      ),
      NewsPage(
        key: newsKey,
      ),
    ];
  }

  @override
  void initState() {
    showUpdateDialog(context);
    super.initState();
  }

  void reloadFriendsSubstitute() {
    friendKey.currentState.reloadFriendsSubstitute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //by this Indexed Stack, the pages are not reloaded every time
      body: IndexedStack(
        children: pages,
        index: currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        currentIndex: currentIndex,
        backgroundColor: Provider.of<ProviderData>(context).getIsDark()
            ? Colors.black
            : Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
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
          if (index != currentIndex) {
            Provider.of<ProviderData>(context, listen: false)
                .setAnimation(true);
            newsKey.currentState.reAnimate();
          }

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
