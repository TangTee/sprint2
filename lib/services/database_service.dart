import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  final CollectionReference joinCollection =
      FirebaseFirestore.instance.collection("join");

  // saving the userdata
  Future savingUserData(
    String fullName,
    String email,
    String age,
    String Imageidcard,
    String Imageprofile,
    String Displayname,
    String gender,
    String bio,
    bool isadmin,
    bool verify,
    String facebook,
    String instagram,
    String twitter,
    String day,
    String month,
    String year,
  ) async {
    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "Displayname": Displayname,
      "email": email,
      "gender": gender,
      "bio": bio,
      "uid": uid,
      "age": age,
      "idcard": Imageidcard,
      "profile": Imageprofile,
      "admin": isadmin,
      "facebook": facebook,
      "instagram": instagram,
      "twitter": twitter,
      "verify": verify,
      "uid": uid,
      "day": day,
      "month": month,
      "year": year,
    });
  }

  // getting user data
  Future gettingUserData(String uid) async {
    QuerySnapshot snapshot =
        await userCollection.where("uid", isEqualTo: uid).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // get group members
  getGroupMembers(groupId) async {
    return joinCollection.doc(groupId).snapshots();
  }

  // search
  searchByName(String groupName) {
    return groupCollection.where("groupName", isEqualTo: groupName).get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    joinCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
