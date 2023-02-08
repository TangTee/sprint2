import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tangteevs/feed/EditAct.dart';
import 'package:tangteevs/utils/showSnackbar.dart';
import 'package:tangteevs/widgets/custom_textfield.dart';
import 'package:url_launcher/url_launcher.dart';
import '../HomePage.dart';
import '../Report.dart';
import '../activity/Join.dart';
import '../activity/waiting.dart';
import '../utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/TagResult.dart';
import '../widgets/like.dart';

class Comment extends StatefulWidget {
  DocumentSnapshot postid;
  Comment({Key? key, required this.postid}) : super(key: key);

  @override
  _MyCommentState createState() => _MyCommentState();
}

class _MyCommentState extends State<Comment> {
  var postData = {};
  var userData = {};
  var commentData = {};
  var currentUser = {};
  var joinData = {};
  var joinLen = 0;
  var waitingLen = 0;
  bool isLoading = false;
  bool enable = false;

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
          .doc(widget.postid['postid'])
          .get();

      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.postid['uid'])
          .get();

      var currentSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      // get comment Length
      var commentSnap = await FirebaseFirestore.instance
          .collection('comments')
          .where('postid', isEqualTo: widget.postid['postid'])
          .get();

      var joinSnap = await FirebaseFirestore.instance
          .collection('join')
          .doc(widget.postid['postid'])
          .get();

      var waitingSnap = await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.postid['postid'])
          .get();

      waitingLen = postSnap.data()!['waiting'].length;
      joinLen = joinSnap.data()!['member'].length - 1;
      postData = postSnap.data()!;
      userData = userSnap.data()!;
      currentUser = currentSnap.data()!;
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _comment =
      FirebaseFirestore.instance.collection('comments');
  final TextEditingController _commentController = TextEditingController();
  final commentSet = FirebaseFirestore.instance.collection('comments');

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : DismissKeyboard(
            child: MaterialApp(
              home: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: mobileBackgroundColor,
                appBar: AppBar(
                  backgroundColor: mobileBackgroundColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: unselected),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  elevation: 1,
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: unselected,
                        size: 30,
                      ),
                      onPressed: () {
                        _showModalBottomSheet1(context, currentUser['uid']);
                      },
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('post')
                                .orderBy('timeStamp', descending: true)
                                .where('postid',
                                    isEqualTo: widget.postid['postid'])
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    itemCount:
                                        (snapshot.data! as dynamic).docs.length,
                                    itemBuilder: (context, index) {
                                      final DocumentSnapshot documentSnapshot =
                                          snapshot.data!.docs[index];
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: green,
                                                  backgroundImage: NetworkImage(
                                                    userData['profile']
                                                        .toString(),
                                                  ),
                                                  radius: 25,
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  child: Text(
                                                      '\t\t' +
                                                          userData[
                                                              'Displayname'],
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'MyCustomFont',
                                                        color:
                                                            mobileSearchColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                ),
                                                Container(
                                                  child: IconButton(
                                                    icon: documentSnapshot[
                                                                'likes']
                                                            .contains(
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                        ? const Icon(
                                                            Icons.favorite,
                                                            color: redColor,
                                                            size: 30,
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .favorite_border,
                                                            size: 30,
                                                          ),
                                                    onPressed: () => likePost(
                                                      documentSnapshot['postid']
                                                          .toString(),
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      documentSnapshot['likes'],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Card(
                                              clipBehavior: Clip.hardEdge,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                side: const BorderSide(
                                                  color: Color.fromARGB(
                                                      255, 151, 150, 150),
                                                  width: 0.5,
                                                ),
                                              ),
                                              //margin: const EdgeInsets.only(top: 15),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15.0,
                                                            top: 8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 8.0),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.62,
                                                                child: Text(
                                                                    documentSnapshot[
                                                                        'activityName'],
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          'MyCustomFont',
                                                                      color:
                                                                          unselected,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    )),
                                                              ),
                                                              SizedBox(
                                                                  child: Icon(Icons
                                                                      .person)),
                                                              Text.rich(TextSpan(
                                                                  children: <
                                                                      InlineSpan>[
                                                                    TextSpan(
                                                                        text: '\t' +
                                                                            joinLen
                                                                                .toString() +
                                                                            ' / ' +
                                                                            documentSnapshot['peopleLimit']
                                                                                .toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontFamily:
                                                                              'MyCustomFont',
                                                                          color:
                                                                              unselected,
                                                                        )),
                                                                  ])),
                                                            ],
                                                          ),
                                                        ),
                                                        Text.rich(TextSpan(
                                                            children: <
                                                                InlineSpan>[
                                                              const TextSpan(
                                                                text: '',
                                                              ),
                                                              const WidgetSpan(
                                                                child: Icon(
                                                                  Icons
                                                                      .calendar_today,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                  text:
                                                                      '${'\t\t' + documentSnapshot['date'] + '\t\t(' + documentSnapshot['time']})',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'MyCustomFont',
                                                                    color:
                                                                        unselected,
                                                                  )),
                                                            ])),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.01,
                                                        ),
                                                        Text.rich(TextSpan(
                                                            children: <
                                                                InlineSpan>[
                                                              const TextSpan(
                                                                text: '',
                                                              ),
                                                              const WidgetSpan(
                                                                child: Icon(
                                                                  Icons
                                                                      .maps_home_work,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                  text: '\t\t' +
                                                                      documentSnapshot[
                                                                          'place'],
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        'MyCustomFont',
                                                                    color:
                                                                        unselected,
                                                                  )),
                                                            ])),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.01,
                                                        ),
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.place,
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Uri uri = Uri.parse(
                                                                      documentSnapshot[
                                                                          'location']);
                                                                  _launchUrl(
                                                                      uri);
                                                                },
                                                                child: Text(
                                                                  'Location',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color:
                                                                        purple,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.01,
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.7,
                                                            child: Text(
                                                                '\nDetail\n\t\t\t\t\t' +
                                                                    documentSnapshot[
                                                                            'detail']
                                                                        .toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'MyCustomFont',
                                                                    color:
                                                                        unselected))),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.02,
                                                        ),
                                                        Row(
                                                          children: [
                                                            SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(1),
                                                                child: SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.4,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.04,
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.30,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        OutlinedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).push(
                                                                              MaterialPageRoute(
                                                                                builder: (context) => TagResult(Tag: widget.postid['tag'].toString()),
                                                                              ),
                                                                            );
                                                                          },
                                                                          style: OutlinedButton.styleFrom(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                                                              side: BorderSide(
                                                                                  color: HexColor(
                                                                                    postData['tagColor'],
                                                                                  ),
                                                                                  width: 1.5)),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 2),
                                                                            child:
                                                                                Text(
                                                                              postData['tag'],
                                                                              style: const TextStyle(color: mobileSearchColor, fontSize: 14),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            if (FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid ==
                                                                documentSnapshot[
                                                                    'uid'])
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    if (waitingLen ==
                                                                        0)
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            (() =>
                                                                                null),
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              unselected,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            const Text(
                                                                          '0 Request',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                'MyCustomFont',
                                                                            color:
                                                                                white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (waitingLen !=
                                                                        0)
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          PersistentNavBarNavigator
                                                                              .pushNewScreen(
                                                                            context,
                                                                            screen:
                                                                                JoinPage(postid: widget.postid['postid']),

                                                                            withNavBar:
                                                                                false, // OPTIONAL VALUE. True by default.
                                                                            pageTransitionAnimation:
                                                                                PageTransitionAnimation.cupertino,
                                                                          );
                                                                        },
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              lightGreen,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          '$waitingLen Request',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                'MyCustomFont',
                                                                            color:
                                                                                unselected,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            if (FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid !=
                                                                documentSnapshot[
                                                                    'uid'])
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.45,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    if (documentSnapshot[
                                                                            'open'] ==
                                                                        true)
                                                                      ElevatedButton(
                                                                        style: documentSnapshot['waiting'].contains(FirebaseAuth.instance.currentUser!.uid)
                                                                            ? ElevatedButton.styleFrom(
                                                                                backgroundColor: lightPurple,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                ),
                                                                              )
                                                                            : ElevatedButton.styleFrom(
                                                                                backgroundColor: lightGreen,
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                ),
                                                                              ),
                                                                        child: documentSnapshot['waiting'].contains(FirebaseAuth.instance.currentUser!.uid)
                                                                            ? const Text(
                                                                                'Waiting',
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontFamily: 'MyCustomFont',
                                                                                  color: mobileBackgroundColor,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              )
                                                                            : const Text(
                                                                                'Join',
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontFamily: 'MyCustomFont',
                                                                                  color: unselected,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                        onPressed: () => requestToLoin(
                                                                            documentSnapshot['postid'].toString(),
                                                                            FirebaseAuth.instance.currentUser!.uid,
                                                                            documentSnapshot['waiting'],
                                                                            documentSnapshot['join']),
                                                                      ),
                                                                    if (documentSnapshot[
                                                                            'open'] ==
                                                                        false)
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            (() =>
                                                                                null),
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              unselected,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            const Text(
                                                                          'Full',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                'MyCustomFont',
                                                                            color:
                                                                                white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )),
                                          Row(
                                            children: const [
                                              Padding(
                                                padding: EdgeInsets.all(16),
                                                child: Text('Comment',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily:
                                                          'MyCustomFont',
                                                      color: unselected,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    )),
                                              ),
                                            ],
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: commentSet
                                                .doc(documentSnapshot['postid'])
                                                .collection('comments')
                                                .orderBy('timeStamp',
                                                    descending: true)
                                                .snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    snapshot) {
                                              if (snapshot.hasData) {
                                                return Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.33,
                                                  child: ListView.builder(
                                                      itemCount: snapshot
                                                          .data!.docs.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final DocumentSnapshot
                                                            documentSnapshot =
                                                            snapshot.data!
                                                                .docs[index];

                                                        var postidD =
                                                            postData['postid'];

                                                        var Mytext = new Map();
                                                        Mytext['Displayname'] =
                                                            documentSnapshot[
                                                                'Displayname'];
                                                        Mytext['cid'] =
                                                            documentSnapshot[
                                                                'cid'];
                                                        Mytext['comment'] =
                                                            documentSnapshot[
                                                                'comment'];
                                                        Mytext['postid'] =
                                                            documentSnapshot[
                                                                'postid'];
                                                        Mytext['profile'] =
                                                            documentSnapshot[
                                                                'profile'];
                                                        Mytext['time'] =
                                                            timeago.format(
                                                                documentSnapshot[
                                                                        'timeStamp']
                                                                    .toDate(),
                                                                locale:
                                                                    'en_short');
                                                        Mytext['uid'] =
                                                            documentSnapshot[
                                                                'uid'];
                                                        Mytext['timeStamp'] =
                                                            documentSnapshot[
                                                                'timeStamp'];

                                                        return Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              45),
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundColor:
                                                                        green,
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                      Mytext['profile']
                                                                          .toString(),
                                                                    ),
                                                                    radius: 20,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onLongPress: () =>
                                                                      _showModalBottomSheet(
                                                                          context,
                                                                          postidD,
                                                                          Mytext),
                                                                  child: Card(
                                                                    clipBehavior:
                                                                        Clip.hardEdge,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15.0),
                                                                      side:
                                                                          const BorderSide(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            151,
                                                                            150,
                                                                            150),
                                                                        width:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              15.00),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 180,
                                                                                child: Text(Mytext['Displayname'],
                                                                                    style: const TextStyle(
                                                                                      fontSize: 16,
                                                                                      fontFamily: 'MyCustomFont',
                                                                                      color: mobileSearchColor,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    )),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 1),
                                                                                child: Text(Mytext['time'].toString(),
                                                                                    style: const TextStyle(
                                                                                      fontSize: 12,
                                                                                      fontFamily: 'MyCustomFont',
                                                                                      color: unselected,
                                                                                    )),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                250,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(
                                                                                Mytext['comment'],
                                                                                style: const TextStyle(
                                                                                  fontSize: 16,
                                                                                  fontFamily: 'MyCustomFont',
                                                                                  color: unselected,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                );
                                              }
                                              return Container(
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
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
                                          )
                                        ],
                                      );
                                      //),
                                    });
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
                                        child: CircularProgressIndicator(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.075,
                                color: white,
                                child: Form(
                                  key: _formKey,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.attach_file_outlined,
                                          color: purple,
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.74,
                                        child: TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 5,
                                          minLines: 1,
                                          controller: commentController,
                                          onChanged: (data) {
                                            if (commentController
                                                .text.isEmpty) {
                                              enable = false;
                                            } else {
                                              enable = true;
                                            }
                                            setState(() {});
                                          },
                                          decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 10),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              borderSide: BorderSide(
                                                  width: 2, color: unselected),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(70)),
                                              borderSide: BorderSide(
                                                  width: 2, color: unselected),
                                            ),
                                            hintText: 'Send a message',
                                            hintStyle: TextStyle(
                                              color: unselected,
                                              fontFamily: 'MyCustomFont',
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: enable
                                            ? () async {
                                                if (_formKey.currentState!
                                                        .validate() ==
                                                    true) {
                                                  setState(() {
                                                    _isLoading = true;
                                                  });
                                                  var commentSet2 = commentSet
                                                      .doc(postData['postid'])
                                                      .collection('comments')
                                                      .doc();
                                                  await commentSet2.set({
                                                    'cid': commentSet2.id,
                                                    'comment':
                                                        commentController.text,
                                                    'postid':
                                                        postData['postid'],
                                                    'uid': FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    'profile':
                                                        currentUser['profile'],
                                                    'Displayname': currentUser[
                                                        'Displayname'],
                                                    'timeStamp': DateTime.now(),
                                                  }).whenComplete(() {
                                                    commentController.clear();
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    setState(() {
                                                      enable = false;
                                                    });
                                                  });
                                                }
                                              }
                                            : null,
                                        icon: const Icon(
                                          Icons.send_outlined,
                                          size: 30,
                                          color: purple,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void _showModalBottomSheet1(BuildContext context, uid) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (postData['uid'].toString() == uid)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  title: Center(
                    child: Text(
                      'Edit Activity',
                      style:
                          TextStyle(fontFamily: 'MyCustomFont', fontSize: 20),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return EditAct(
                            postid: postData['postid'],
                          );
                        },
                      ),
                      (_) => false,
                    );
                  },
                ),
              if (postData['uid'].toString() == uid)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  title: const Center(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                          fontFamily: 'MyCustomFont',
                          fontSize: 20,
                          color: redColor),
                    ),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Delete Activity'),
                              content: Text(
                                  'Are you sure you want to permanently\nremove this Activity from Tungtee?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancle')),
                                TextButton(
                                    onPressed: (() {
                                      FirebaseFirestore.instance
                                          .collection('post')
                                          .doc(postData['postid'])
                                          .delete()
                                          .whenComplete(() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MyHomePage(),
                                          ),
                                        );
                                      });
                                    }),
                                    child: Text('Delete'))
                              ],
                            ));
                  },
                ),
              if (postData['uid'].toString() != uid)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  title: const Center(
                      child: Text(
                    'Report',
                    style: TextStyle(
                        color: redColor,
                        fontFamily: 'MyCustomFont',
                        fontSize: 20),
                  )),
                  onTap: () {
                    return showModalBottomSheetRP(context, postData);
                  },
                ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                title: const Center(
                    child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: redColor,
                      fontFamily: 'MyCustomFont',
                      fontSize: 20),
                )),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModalBottomSheet(BuildContext context, postidD, Map mytext) {
    _commentController.text = mytext['comment'].toString();
    String Comment = '';

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (FirebaseAuth.instance.currentUser!.uid == mytext['uid'])
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  title: Center(
                    child: Text(
                      'Edit',
                      style:
                          TextStyle(fontFamily: 'MyCustomFont', fontSize: 20),
                    ),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Edit Comment'),
                              content: Form(
                                child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  minLines: 1,
                                  controller: _commentController,
                                  decoration: textInputDecorationp.copyWith(
                                    hintText: 'type something',
                                  ),
                                  validator: (val) {
                                    if (val!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "plase Enter comment";
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() {
                                      Comment = val;
                                    });
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .popUntil((route) => route.isFirst),
                                    child: Text('Cancle')),
                                TextButton(
                                    onPressed: (() {
                                      FirebaseFirestore.instance
                                          .collection('comments')
                                          .doc(postidD)
                                          .collection('comments')
                                          .doc(mytext['cid'])
                                          .update({
                                        'cid': mytext['cid'],
                                        'postid': mytext['postid'],
                                        'uid': mytext['uid'],
                                        'profile': mytext['profile'],
                                        'Displayname': mytext['Displayname'],
                                        'timeStamp': mytext['timeStamp'],
                                        "comment": _commentController.text
                                      }).whenComplete(() {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      });
                                    }),
                                    child: Text('Save'))
                              ],
                            ));
                  },
                ),
              if (FirebaseAuth.instance.currentUser!.uid == mytext['uid'])
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  title: const Center(
                      child: Text(
                    'Delete',
                    style: TextStyle(
                        fontFamily: 'MyCustomFont',
                        fontSize: 20,
                        color: redColor),
                  )),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Delete Comment'),
                              content: Text(
                                  'Are you sure you want to permanently\nremove this comment from Tungtee?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancle')),
                                TextButton(
                                    onPressed: (() {
                                      FirebaseFirestore.instance
                                          .collection('comments')
                                          .doc(postidD)
                                          .collection('comments')
                                          .doc(mytext['cid'])
                                          .delete()
                                          .whenComplete(() {
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      });
                                    }),
                                    child: Text('Delete'))
                              ],
                            ));
                  },
                ),
              if (FirebaseAuth.instance.currentUser!.uid != mytext['uid'])
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  title: const Center(
                      child: Text(
                    'Report',
                    style: TextStyle(
                        color: redColor,
                        fontFamily: 'MyCustomFont',
                        fontSize: 20),
                  )),
                  onTap: () {
                    return showModalBottomSheetRC(
                        context, mytext['uid'], mytext);
                  },
                ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                title: const Center(
                    child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: redColor,
                      fontFamily: 'MyCustomFont',
                      fontSize: 20),
                )),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (_) {}
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}