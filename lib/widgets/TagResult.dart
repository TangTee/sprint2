import 'package:flutter/material.dart';
import 'package:tangteevs/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/PostCard.dart';
import '../widgets/custom_textfield.dart';

class TagResult extends StatefulWidget {
  final String Tag;
  TagResult({Key? key, required this.Tag}) : super(key: key);

  @override
  _MySearchTagState createState() => _MySearchTagState();
}

class _MySearchTagState extends State<TagResult> {
  final CollectionReference _post =
      FirebaseFirestore.instance.collection('post');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DismissKeyboard(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                  Icons.notifications_none,
                  color: purple,
                  size: 30,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream: _post
                  .where('tag', isGreaterThanOrEqualTo: widget.Tag)
                  //.orderBy('activityName', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                }

                return ListView.builder(
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) => Container(
                          child: CardWidget(
                              snap: (snapshot.data! as dynamic).docs[index]),
                        ));
              }),
        ),
      ),
    );
  }
}
