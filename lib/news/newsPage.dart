import 'dart:math';

import 'package:Vertretung/news/newsTransmitter.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'editNewsPage.dart';
import 'newsLogic.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key key}) : super(key: key);

  @override
  NewsPageState createState() => NewsPageState();
}

enum actions { delete, edit }

class NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  List<dynamic> newsList = [];
  bool isAdmin = false;
  bool finishedLoading = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AnimationController _controller;

  Animation<double> _animation;

  @override
  void initState() {
    AuthService().getAdminStatus().then((value) => setState(() {
          isAdmin = value;
        }));
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this, value: 0.1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
    reload();
    super.initState();
  }

  void reload() async {
    CloudDatabase manager = CloudDatabase();
    await manager.getNews().then((onValue) {
      setState(() {
        newsList = onValue;
      });
    });
    finishedLoading = true;
    _controller.forward();
    _refreshController.refreshCompleted();
  }

  void reAnimate() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nachrichten"),
      ),
      body: finishedLoading
          ? SmartRefresher(
              controller: _refreshController,
              onRefresh: reload,
              child: ScaleTransition(
                scale: _animation,
                child: ListView.builder(
                  physics: ScrollPhysics(),
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      elevation: 3,
                      child: ListTile(
                        title: Text(newsList[index]["title"]),
                        //show only the first 100 chars as subtitle, to see more click on the ListTile
                        subtitle: newsList[index]["text"] != ""
                            ? Text(newsList[index]["text"].toString().substring(
                                0,
                                min(newsList[index]["text"].toString().length,
                                    100)))
                            : null,
                        onTap: () async {
                          final result = await NewsLogic().openDetailsPage(
                              context,
                              newsList[index]["text"],
                              newsList[index]["title"],
                              index);

                          //check if the page have to be reloaded(needed when deleted or edited)
                          if (result != null)
                            _refreshController.requestRefresh();
                        },
                        trailing: isAdmin
                            ? PopupMenuButton(
                                icon: Icon(Icons.more_vert),
                                onSelected: (selected) async {
                                  if (selected == actions.delete) {
                                    if (await NewsLogic()
                                        .deleteNews(context, index))
                                      _refreshController.requestRefresh();
                                  } else {
                                    await NewsLogic().openEditNewsPage(
                                      context,
                                      newsList[index]["text"],
                                      newsList[index]["title"],
                                      index,
                                    );
                                    _refreshController.requestRefresh();
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem(
                                      value: actions.delete,
                                      child: Text("löschen"),
                                    ),
                                    PopupMenuItem(
                                      value: actions.edit,
                                      child: Text("bearbeiten"),
                                    ),
                                  ];
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: "filter",
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNewsPage(NewsTransmitter(false)),
                  ),
                ).then((value) => _refreshController.requestRefresh());
              },
            )
          : null,
    );
  }
}
