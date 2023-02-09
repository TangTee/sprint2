import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tangteevs/profile/Profile.dart';
import 'package:flutter/material.dart';
import '../utils/color.dart';
import '../utils/showSnackbar.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List groupMember;

  const GroupInfo({
    Key? key,
    required this.groupName,
    required this.groupId,
    required this.groupMember,
  }) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  var groupData = {};
  var member = [];
  bool isLoading = false;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var groupSnap = await FirebaseFirestore.instance
          .collection('join')
          .doc(widget.groupId)
          .get();

      groupData = groupSnap.data()!;
      member = groupSnap.data()?['member'];
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
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: lightPurple,
          title: Text("${widget.groupName}"),
          // actions: [
          //   ElevatedButton(
          //       onPressed: () {
          //         //
          //       },
          //       child: const Text('text'))
          // ],
        ),
        body: memberList());
  }

  memberList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: widget.groupMember)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot =
                  snapshot.data!.docs[index];
              return Container(
                height: MediaQuery.of(context).size.height * 0.08,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 20,
                ),
                alignment: Alignment.topLeft,
                child: Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ProfilePage(
                            uid: documentSnapshot['uid'],
                          ),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                        );
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.08,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 1),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: green,
                                  backgroundImage: NetworkImage(
                                    documentSnapshot['profile'].toString(),
                                  ),
                                  radius: 25,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.64,
                                  child: Text(
                                    documentSnapshot['Displayname'],
                                    style: const TextStyle(
                                      color: mobileSearchColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                SizedBox(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: unselected,
                                      size: 30,
                                    ),
                                    onPressed: (() {
                                      //add action
                                      _showModalBottomSheet(
                                          context, documentSnapshot['uid']);
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ));
        }
      },
    );
  }

  void _showModalBottomSheet(BuildContext context, uid) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // if (documentSnapshot['uid'].toString() == uid)
              //   ListTile(
              //     contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              //     title: Center(
              //       child: Text(
              //         'Edit Activity',
              //         style:
              //             TextStyle(fontFamily: 'MyCustomFont', fontSize: 20),
              //       ),
              //     ),
              //     onTap: () {
              //       PersistentNavBarNavigator.pushNewScreen(
              //         context,
              //         screen: EditAct(
              //           postid: widget.snap['postid'],
              //         ),
              //         withNavBar: false, // OPTIONAL VALUE. True by default.
              //         pageTransitionAnimation:
              //             PageTransitionAnimation.cupertino,
              //       );
              //     },
              //   ),
              // if (postData['uid'].toString() == uid)
              //   ListTile(
              //     contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              //     title: const Center(
              //       child: Text(
              //         'Delete',
              //         style: TextStyle(
              //             fontFamily: 'MyCustomFont',
              //             fontSize: 20,
              //             color: redColor),
              //       ),
              //     ),
              //     onTap: () {
              //       showDialog(
              //           context: context,
              //           builder: (context) => AlertDialog(
              //                 title: Text('Delete Activity'),
              //                 content: Text(
              //                     'Are you sure you want to permanently\nremove this Activity from Tungtee?'),
              //                 actions: [
              //                   TextButton(
              //                       onPressed: () => Navigator.pop(context),
              //                       child: Text('Cancle')),
              //                   TextButton(
              //                       onPressed: (() {
              //                         FirebaseFirestore.instance
              //                             .collection('post')
              //                             .doc(widget.snap['postid'])
              //                             .delete()
              //                             .whenComplete(() {
              //                           Navigator.push(
              //                             context,
              //                             MaterialPageRoute(
              //                               builder: (context) => MyHomePage(),
              //                             ),
              //                           );
              //                         });
              //                       }),
              //                       child: Text('Delete'))
              //                 ],
              //               ));
              //     },
              //   ),
              // if (postData['uid'].toString() != uid)
              //   ListTile(
              //     contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              //     title: const Center(
              //         child: Text(
              //       'Report',
              //       style: TextStyle(
              //           color: redColor,
              //           fontFamily: 'MyCustomFont',
              //           fontSize: 20),
              //     )),
              //     onTap: () {
              //       return showModalBottomSheetRP(context, postData);
              //     },
              //   ),
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
}
