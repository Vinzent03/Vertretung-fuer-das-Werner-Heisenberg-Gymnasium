import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name = "Laden";
  String email = "Laden";
  bool isAnon = true;
  bool beta = false;

  changeNameAlert(scaffoldContext) {
    final TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Gib deinen neuen Namen ein"),
            content: TextField(
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                  child: Text("Bestätigen"),
                  onPressed: () async {
                    if (controller.text.length >= 2) {
                      setState(() {
                        name = controller.text;
                      });
                      AuthService().updateName(controller.text);
                      CloudDatabase().updateName(controller.text);
                      Navigator.pop(context);
                    } else {
                      final snack = SnackBar(
                        content: Text("Bitte wähle einen längeren Namen"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      );

                      Scaffold.of(scaffoldContext).showSnackBar(snack);
                      await Future.delayed(
                        Duration(seconds: 4),
                      ); //Erst nach den 4 Sekunden wird die Snackbar geschlossen. Keine Ahnung warum das extra nötig ist.
                      Scaffold.of(scaffoldContext).removeCurrentSnackBar();
                    }
                  }),
            ],
          );
        });
  }

  void deleteAccountAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Möchtest du dein Account wirklich löschen? Das kann nicht Rückgängig gemacht werden!"),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                color: Colors.red,
                child: Text("Bestätigen"),
                onPressed: () async {
                  await Functions().callDeleteProfile();
                  Navigator.pushNamedAndRemoveUntil(
                      context, Names.wrapper, (r) => false);
                },
              )
            ],
          );
        });
  }

  void becomeBetaUserAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              beta
                  ? "Möchtest du wirklich kein Beta Nutzer mehr sein? Falls du irgendwelche Fehler hattest, melde diese doch bitte."
                  : "Als Beta Nutzer bekommst du früher Updates. Diese sind ggf. fehlerhaft. Bei einem App-Neustart bekommst du dann eine Meldung zu einem verfügbaren Update",
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                color: Colors.red,
                child: Text("Bestätigen"),
                onPressed: () async {
                  CloudDatabase().becomeBetaUser(!beta);
                  LocalDatabase().setBool(Names.beta, !beta);
                  setState(() {
                    beta = !beta;
                  });
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    reload();
    super.initState();
  }

  void reload() {
    AuthService().getName().then((value) => name = value);
    AuthService().isAnon().then((newIsAnon) {
      setState(() {
        isAnon = newIsAnon;
      });
      if (!isAnon) {
        AuthService().getEmail().then((newEmail) {
          setState(() {
            email = newEmail;
          });
        });
      }
    });
    LocalDatabase().getBool(Names.beta).then((value) => beta = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Dein Account"),
        ),
        body: Builder(builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text("Dein Name:"),
                      onTap: () => changeNameAlert(context),
                      trailing: Padding(
                          child: Text(name),
                          padding: EdgeInsets.only(right: 10))),
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text("Anmelde Methode:"),
                        subtitle: isAnon ? null : Text(email),
                        trailing: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text("${isAnon ? "Anonym" : "Email"}"),
                        ),
                      ),
                      if (!isAnon)
                        ListTile(
                          leading: Icon(Icons.security),
                          title: Text("Passwort ändern"),
                          onTap: () {
                            Navigator.pushNamed(
                                context, Names.changePasswordPage);
                          },
                        )
                    ],
                  ),
                ),

                //Beta
                Card(
                  child: ListTile(
                    leading: Icon(Icons.warning),
                    title: Text(beta
                        ? "Kein Beta Nutzer mehr werden"
                        : "Beta Nutzer werden"),
                    onTap: becomeBetaUserAlert,
                  ),
                ),
                //Anonym
                if (isAnon)
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text(
                          "Zum Anmelden bitte erst Abmelden bzw. Konto löschen wenn du Anonym bist"),
                    ),
                  ),
                Card(
                  color: Colors.blue,
                  child: isAnon
                      ? ListTile(
                          title: RaisedButton(
                              color: Colors.blue,
                              elevation: 0,
                              child: Text("Registrieren"),
                              onPressed: () async {
                                await Navigator.pushNamed(
                                    context, Names.logInPage,
                                    arguments: true);
                                  reload();
                                
                              }),
                        )
                      : ListTile(
                          title: RaisedButton(
                              color: Colors.blue,
                              elevation: 0,
                              child: Text("Abmelden"),
                              onPressed: () async {
                                await AuthService().signOut();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, Names.wrapper, (r) => false);
                              }),
                        ),
                ),
                Card(
                  color: Colors.red,
                  child: ListTile(
                    title: RaisedButton(
                      color: Colors.red,
                      elevation: 0,
                      child: Text("Konto löschen"),
                      onPressed: deleteAccountAlert,
                    ),
                  ),
                )
              ],
            ),
          );
        }));
  }
}