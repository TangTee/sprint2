import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tangteevs/feed/EditAct.dart';
import 'package:tangteevs/utils/showSnackbar.dart';
import 'package:tangteevs/widgets/like.dart';
import 'package:url_launcher/url_launcher.dart';
import '../HomePage.dart';
import '../Report.dart';
import '../comment/comment.dart';
import '../utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'TagResult.dart';

class CardRWidget extends StatefulWidget {
  final review;
  const CardRWidget({super.key, required this.review});

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<CardRWidget> {
  var postData = {};
  var userData = {};
  var joinLen = 0;
  bool isLoading = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.review['uid'])
          .get();

      userData = userSnap.data()!;
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
        widget.review['timeStamp'].seconds * 1000);
    return SafeArea(
      child: Container(
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(
              color: unselected,
              width: 2,
            ),
          ),
          margin: const EdgeInsets.all(15),
          child: SizedBox(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 15.00, top: 15.00, bottom: 10.00),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: green,
                          backgroundImage: NetworkImage(
                            widget.review['reviewer_P'].toString(),
                          ),
                          radius: 25,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text('\t\t' + widget.review['reviewer_N'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'MyCustomFont',
                                color: mobileSearchColor,
                              )),
                        ),
                      ],
                    ),
                    RatingBar.builder(
                      initialRating: widget.review['rating'],
                      direction: Axis.horizontal,
                      ignoreGestures: true,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        null;
                      },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('\t\t' + widget.review['review'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'MyCustomFont',
                          color: mobileSearchColor,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 210),
                      child: Text('\t\t$date',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'MyCustomFont',
                            color: mobileSearchColor,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
