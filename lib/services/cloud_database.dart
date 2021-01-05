import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/models/news_model.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:stream_transform/stream_transform.dart';

enum updateCodes { availableNormal, availableForce, notAvailable }

class CloudDatabase {
  final FirebaseFirestore ref = FirebaseFirestore.instance;
  String uid = AuthService().getUserId();

  void updateUserData({
    @required personalSubstitute,
    @required schoolClass,
    @required notificationOnChange,
    @required notificationOnFirstChange,
  }) async {
    updateToken();
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({
      Names.personalSubstitute: personalSubstitute,
      Names.notificationOnChange: notificationOnChange,
      Names.notificationOnFirstChange: notificationOnFirstChange,
      Names.schoolClass: schoolClass,
    }, SetOptions(merge: true));
  }

  void updateToken() async {
    String token = await PushNotificationsManager().getToken();
    DocumentReference doc = ref.collection("userdata").doc(uid);
    if (token != null) doc.update({"token": token});
  }

  void updateSubjects() async {
    List<String> subjects = await SharedPref.getStringList(Names.subjects);
    List<String> subjectsNot =
        await SharedPref.getStringList(Names.subjectsNot);

    ref.collection("userdata").doc(uid).update(
      {
        Names.subjects: subjects,
        Names.subjectsNot: subjectsNot,
      },
    );
  }

  void updateCustomSubjects() async {
    List<String> subjectsCustom =
        await SharedPref.getStringList(Names.subjectsCustom);
    List<String> subjectsNotCustom =
        await SharedPref.getStringList(Names.subjectsNotCustom);

    ref.collection("userdata").doc(uid).update(
      {
        Names.subjectsCustom: subjectsCustom,
        Names.subjectsNotCustom: subjectsNotCustom,
      },
    );
  }

  void updateFreeLessons(List<String> newFreeLessons) async {
    ref.collection("userdata").doc(uid).update(
      {
        "freeLessons": newFreeLessons,
      },
    );
  }

  void updateLastNotification(UserData provider) async {
    List<String> justSubstitute = [];
    List<SubstituteModel> list;
    if (provider.personalSubstitute) {
      list = Filter.checkPersonalSubstitute(
        provider.schoolClass,
        provider.rawSubstituteToday,
        provider.subjects,
        provider.subjectsNot,
      );
    } else {
      list = Filter.checkForSchoolClass(
        provider.schoolClass,
        provider.rawSubstituteToday,
      );
    }
    for (SubstituteModel item in list) {
      justSubstitute.add(item.title);
    }
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({"lastNotification": justSubstitute}, SetOptions(merge: true));
  }

  void updateName(String newName) async {
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({
      "name": newName.trim(),
    }, SetOptions(merge: true));
  }

  Future<String> getName() async {
    DocumentSnapshot snap = await ref.collection("userdata").doc(uid).get();
    return snap.data()["name"] ?? "No internet connection";
  }

  Future<void> syncSettings(UserData provider) async {
    DocumentSnapshot userdataDoc =
        await ref.collection("userdata").doc(uid).get();

    updateToken();

    if (!userdataDoc.exists) return;
    String schoolClass = userdataDoc.data()[Names.schoolClass];
    List<String> subjects =
        List<String>.from(userdataDoc.data()[Names.subjects]);
    List<String> subjectsNot =
        List<String>.from(userdataDoc.data()[Names.subjectsNot]);
    List<String> subjectsCustom =
        List<String>.from(userdataDoc.data()[Names.subjectsCustom]);
    List<String> subjectsNotCustom =
        List<String>.from(userdataDoc.data()[Names.subjectsNotCustom]);
    List<String> freeLessons =
        List<String>.from(userdataDoc.data()[Names.freeLessons] ?? []);
    bool personalSubstitute = userdataDoc.data()[Names.personalSubstitute];
    bool notificationOnChange = userdataDoc.data()[Names.notificationOnChange];
    bool notificationOnFirstChange =
        userdataDoc.data()[Names.notificationOnFirstChange];

    SharedPref.setStringList(Names.subjectsCustom, subjectsCustom);
    SharedPref.setStringList(Names.subjectsNotCustom, subjectsNotCustom);
    SharedPref.setBool(Names.notificationOnChange, notificationOnChange);
    SharedPref.setBool(
        Names.notificationOnFirstChange, notificationOnFirstChange);

    provider.schoolClass = schoolClass;
    provider.subjects = subjects;
    provider.subjectsNot = subjectsNot;
    provider.personalSubstitute = personalSubstitute;
    provider.freeLessons = freeLessons;
  }

  //Updates
  Future<updateCodes> getUpdate() async {
    PackageInfo pa = await PackageInfo.fromPlatform();
    String version = pa.version;
    bool updateAvailable = true;
    bool forceUpdate;
    try {
      DocumentSnapshot snap =
          await ref.collection("details").doc("versions").get();
      updateAvailable = snap.data()["newVersion"] != version;
      forceUpdate = snap.data()["forceUpdate"];
      if (updateAvailable) {
        if (forceUpdate) {
          return updateCodes.availableForce;
        } else {
          return updateCodes.availableNormal;
        }
      } else {
        return updateCodes.notAvailable;
      }
    } catch (e) {
      return updateCodes.notAvailable;
    }
  }

  Future<Map<String, String>> getUpdateLinks() async {
    DocumentSnapshot snap = await ref.collection("details").doc("links").get();
    return {
      "download": snap.data()["downloadLink"],
      "changelog": snap.data()["changelogLink"]
    };
  }

  Future<List<dynamic>> getUpdateMessage() async {
    DocumentSnapshot snap =
        await ref.collection("details").doc("versions").get();
    return snap.data()["message"];
  }

  //News
  Stream<List<NewsModel>> getNews(String schoolClass, bool isAdmin) {
    List<QueryDocumentSnapshot> sort(QuerySnapshot event) {
      List<QueryDocumentSnapshot> list = event.docs;
      list.sort((a, b) => (a.data()["created"] as Timestamp)
          .compareTo((b.data()["created"] as Timestamp)));
      return list.reversed.toList();
    }

    Stream<QuerySnapshot> snap;
    if (isAdmin)
      snap = ref.collection("news").snapshots();
    else
      snap = ref
          .collection("news")
          .where("schoolClasses", arrayContains: schoolClass)
          .snapshots();
    return snap.map((event) => (sort(event))
        .map((e) => NewsModel(e.id, e["title"], e["text"], e["lastEdited"]))
        .toList());
  }

  // friends
  Future<void> removeFriend(String frienduid) async {
    DocumentReference doc = ref.collection("userdata").doc(uid);
    DocumentSnapshot snap = await doc.get();
    List<dynamic> friends = List<String>.from(snap.data()["friends"]);
    friends.remove(frienduid);
    return await doc.update({"friends": friends});
  }

  Stream<List<FriendModel>> getFriendsSettings() {
    return ref.collection("userdata").doc(uid).snapshots().map((event) {
      return List<String>.from(event.data()["friends"] ?? []);
    }).concurrentAsyncExpand(
        (List<String> friends) => _getFriendsSettings(friends));
  }

  Stream<List<FriendModel>> _getFriendsSettings(List<String> friends) {
    if (friends.isEmpty) return Stream.value([]);
    var newStream = ref
        .collection("userdata")
        .where(FieldPath.documentId, whereIn: friends)
        .snapshots();
    return newStream.map((event) {
      var sortedList = event.docs
          .map(
            (e) => FriendModel(
              e.id,
              e.data()["name"],
              e.data()[Names.schoolClass],
              e.data()[Names.personalSubstitute],
              List<String>.from(e.data()[Names.subjects]),
              List<String>.from(e.data()[Names.subjectsNot]),
              List<String>.from(e.data()[Names.freeLessons] ?? []),
            ),
          )
          .toList();
      sortedList.sort((friendA, friendB) =>
          friendA.name.toLowerCase().compareTo(friendB.name.toLowerCase()));
      return sortedList;
    });
  }

  ///only used for web app
  Future<List<dynamic>> getSubstitute() async {
    DocumentSnapshot data = await ref.collection("details").doc("webapp").get();
    String lastChange = data.data()["lastChange"];
    return [
      lastChange.substring(17, 23) + lastChange.substring(27),
      List<String>.from(data.data()["substituteToday"]),
      List<String>.from(data.data()["substituteTomorrow"])
    ];
  }
}
