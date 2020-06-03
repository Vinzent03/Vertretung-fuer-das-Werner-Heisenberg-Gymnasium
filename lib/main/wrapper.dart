import 'package:Vertretung/main/introScreen.dart';
import 'package:Vertretung/pages/VertretungsPage.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'home.dart';

class Wrapper extends StatelessWidget {
  Wrapper() {
    PushNotificationsManager().init();
    initDynamicLinks();
  }
  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);
    print("Aktueller User in Wrapper: ${user == null ? "Kein konto" : user.uid}");
    if(user == null) {
      return IntroScreen();
    }else{
      return Home();
    }
  }
}
