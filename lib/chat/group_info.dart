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
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: ProfilePage(
                          uid: documentSnapshot['uid'],
                        ),
                        withNavBar: false, // OPTIONAL VALUE. True by default.
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: green,
                        backgroundImage: NetworkImage(
                          documentSnapshot['profile'].toString(),
                        ),
                        radius: 25,
                      ),
                      title: Text(documentSnapshot['Displayname']),
                    ),
                  ),
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
}
