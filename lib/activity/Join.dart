import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tangteevs/activity/Activity.dart';
import 'package:tangteevs/profile/Profile.dart';
import 'package:tangteevs/services/auth_service.dart';
import 'package:tangteevs/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/color.dart';
import '../utils/showSnackbar.dart';
import '../widgets/custom_textfield.dart';
import 'package:image_picker/image_picker.dart';

class JoinPage extends StatefulWidget {
  final String postid;
  JoinPage({Key? key, required this.postid}) : super(key: key);

  @override
  JoinPageState createState() => JoinPageState();
}

class JoinPageState extends State<JoinPage> {
  //final user = FirebaseAuth.instance.currentUser;
  DatabaseService databaseService = DatabaseService();
  bool _isLoading = false;
  var postData = {};
  var waiting = [];
  bool isLoading = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var postSnap = await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.postid)
          .get();

      postData = postSnap.data()!;
      waiting = postSnap.data()!['waiting'];
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center()
        : DismissKeyboard(
            child: MaterialApp(
              home: Scaffold(
                bottomNavigationBar: null,
                backgroundColor: mobileBackgroundColor,
                appBar: AppBar(
                  backgroundColor: mobileBackgroundColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: mobileSearchColor, size: 30),
                    onPressed: () => {Navigator.of(context).pop()},
                  ),
                  toolbarHeight: MediaQuery.of(context).size.height * 0.13,
                  centerTitle: true,
                  elevation: 0,
                  title: const Text(
                    "Request List",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: purple,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: unselected,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(-20),
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        child: Column(
                          children: [
                            Text("กดเครื่องหมายถูกเพื่อยอมรับคำขอเข้าร่วม",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: unselected)),
                            Text("หรือกดเครื่องหมายกากบาทเพื่อปฏิเสธ",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: unselected)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                body: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: mobileBackgroundColor,
                      ))
                    : SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.84,
                                child: ListView(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.84,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .where('uid', whereIn: waiting)
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            return SizedBox(
                                              height: 500,
                                              width: 600,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      child: ListView.builder(
                                                          itemCount: snapshot
                                                              .data!
                                                              .docs
                                                              .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final DocumentSnapshot
                                                                documentSnapshot =
                                                                snapshot.data!
                                                                        .docs[
                                                                    index];
                                                            return Card(
                                                              elevation: 2,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: ClipPath(
                                                                clipper: ShapeBorderClipper(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(3))),
                                                                child:
                                                                    Container(
                                                                  height: 80,
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          80,
                                                                      child:
                                                                          ListTile(
                                                                        leading:
                                                                            CircleAvatar(
                                                                          backgroundColor:
                                                                              green,
                                                                          backgroundImage:
                                                                              NetworkImage(
                                                                            documentSnapshot['profile'].toString(),
                                                                          ),
                                                                          radius:
                                                                              25,
                                                                        ),
                                                                        title: Text(
                                                                            documentSnapshot['Displayname']),
                                                                        //subtitle: documentSnapshot['bio'],
                                                                        trailing:
                                                                            SingleChildScrollView(
                                                                          child: SizedBox(
                                                                              width: 100,
                                                                              child: Row(
                                                                                children: [
                                                                                  IconButton(
                                                                                    icon: const Icon(Icons.check),
                                                                                    onPressed: () => joinActivity(
                                                                                      widget.postid.toString(),
                                                                                      documentSnapshot['uid'],
                                                                                      postData['waiting'],
                                                                                    ),
                                                                                  ),
                                                                                  IconButton(
                                                                                    icon: const Icon(Icons.close),
                                                                                    onPressed: () => denyActivity(
                                                                                      widget.postid.toString(),
                                                                                      documentSnapshot['uid'],
                                                                                      postData['waiting'],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return Container(
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: const <Widget>[
                                                  SizedBox(
                                                    height: 30.0,
                                                    width: 30.0,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
  }
}

Future<String> joinActivity(String postId, String uid, List waiting) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String res = "Some error occurred";

  try {
    _firestore.collection('join').doc(postId).update({
      'member': FieldValue.arrayUnion([uid])
    }).whenComplete(() {
      _firestore.collection('post').doc(postId).update({
        'waiting': FieldValue.arrayRemove([uid])
      });
    });
    res = 'success';
  } catch (err) {
    res = err.toString();
  }
  return res;
}

Future<String> denyActivity(String postId, String uid, List waiting) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String res = "Some error occurred";

  try {
    _firestore.collection('post').doc(postId).update({
      'waiting': FieldValue.arrayRemove([uid])
    });
    res = 'success';
  } catch (err) {
    res = err.toString();
  }
  return res;
}
