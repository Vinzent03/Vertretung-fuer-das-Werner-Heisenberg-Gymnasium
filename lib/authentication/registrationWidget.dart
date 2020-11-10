import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class RegistrationWidget extends StatelessWidget {
  final String name;
  RegistrationWidget({Key key, this.name}) : super(key: key);
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Email:"),
        ),
        TextFormField(
          autofillHints: [AutofillHints.email],
          controller: emailController,
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Passwort:"),
        ),
        TextFormField(
          autofillHints: [AutofillHints.newPassword],
          obscureText: true,
          controller: passwordController,
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Passwort bestätigen:"),
        ),
        TextFormField(
          obscureText: true,
          controller: passwordConfirmController,
        ),
        SizedBox(
          height: 20,
        ),
        RaisedButton(
          child: Text(kIsWeb ? "Registrieren" : "Account mit Email verbinden"),
          onPressed: () async {
            ProgressDialog pr =
                ProgressDialog(context, isDismissible: false, showLogs: false);
            String err;
            if (passwordController.text != passwordConfirmController.text)
              return Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Die beiden Passwörter sind nicht identisch."),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ));
            await pr.show();
            if (kIsWeb) {
              await AuthService()
                  .setupAccount(false, name, emailController.text,
                      passwordController.text)
                  .catchError((e) async {
                await pr.hide();
                final SnackBar snack = SnackBar(
                  content: Text(e),
                  backgroundColor: Colors.red,
                );
                Scaffold.of(context).showSnackBar(snack);
              });
              await pr.hide();
            } else {
              err = await AuthService().linkAccountWithEmail(
                  emailController.text, passwordController.text);
              await pr.hide();
            }
            if (err != null) {
              final SnackBar snack = SnackBar(
                content: Text(err),
                backgroundColor: Colors.red,
              );
              Scaffold.of(context).showSnackBar(snack);
            } else {
              Navigator.popUntil(context, ModalRoute.withName(Names.wrapper));
            }
          },
        ),
      ],
    );
  }
}
