import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_functions.dart';
import "package:flutter/material.dart";

class AddFriendPerDynamicLink extends StatefulWidget {
  final name;
  final friendUid;

  const AddFriendPerDynamicLink({Key key, this.name, this.friendUid})
      : super(key: key);
  @override
  _AddFriendPerDynamicLinkState createState() =>
      _AddFriendPerDynamicLinkState();
}

class _AddFriendPerDynamicLinkState extends State<AddFriendPerDynamicLink> {
  bool addFriendToYourself = false;
  String uid = "Laden";
  @override
  void initState() {
    super.initState();
    setState(() => uid = AuthService().getUserId());
  }

  @override
  Widget build(BuildContext context) {
    return widget.friendUid != uid
        ? AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Möchtest bei ${widget.name} Freund sein?"),
            content: CheckboxListTile(
              title: Text("Auch bei mir hinzufügen"),
              onChanged: (value) {
                setState(() {
                  addFriendToYourself = value;
                });
              },
              value: addFriendToYourself,
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Bestätigen"),
                onPressed: () {
                  Functions().addFriend(widget.friendUid, addFriendToYourself);
                  Navigator.pop(context);
                },
              ),
            ],
          )
        : AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text(
                "Dies ist dein eigener Link. Du kannst dich nicht selbst als Freund hinzufügen."),
            actions: <Widget>[
              ElevatedButton(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
  }
}
