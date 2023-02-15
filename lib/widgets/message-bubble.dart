import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'package:tangteevs/model/chat_model.dart';
import 'package:tangteevs/utils/color.dart';

import '../Profile/Profile.dart';
import '../utils/my_date_util.dart';
import '../utils/showSnackbar.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool image;
  final String sender;
  final String profile;
  final String time;
  final bool sentByMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.image,
    required this.sender,
    required this.time,
    required this.sentByMe,
    required this.profile,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  TextEditingController messageController = TextEditingController();
  bool isLoading = false;
  bool text = false;
  bool image = true;
  var groupData = {};
  var member = [];

  var userData = {};

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
          .doc(widget.sender)
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: widget.sentByMe ? 0 : 4,
        bottom: 4,
        left: widget.sentByMe ? 0 : 18,
        right: widget.sentByMe ? 18 : 0,
      ),
      alignment: widget.sentByMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: widget.image == true
            ? EdgeInsets.only(
                left: widget.sentByMe ? 80 : 0,
                right: widget.sentByMe ? 0 : 80,
              )
            : EdgeInsets.only(
                top: 2,
                bottom: 7,
                left: widget.sentByMe ? 80 : 0,
                right: widget.sentByMe ? 0 : 80,
              ),
        child: Column(
          crossAxisAlignment: widget.sentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            SizedBox(
              width:
                  widget.sentByMe ? 0 : MediaQuery.of(context).size.width * 0.6,
              child: Row(
                children: [
                  widget.sentByMe
                      ? SizedBox()
                      : Container(
                          color: mobileBackgroundColor,
                          child: InkWell(
                            onTap: () {
                              PersistentNavBarNavigator.pushNewScreen(
                                context,
                                screen: ProfilePage(
                                  uid: userData['uid'],
                                ),
                                withNavBar:
                                    false, // OPTIONAL VALUE. True by default.
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                userData['profile'].toString(),
                              ),
                              radius: 15,
                            ),
                          ),
                        ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  widget.sentByMe
                      ? SizedBox()
                      : Container(
                          color: mobileBackgroundColor,
                          child: Text(
                            userData['Displayname'].toString().toUpperCase(),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5),
                          ),
                        ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.005,
            ),
            InkWell(
              onTap: () {
                return _showModalBottomSheet(context, userData, groupData);
              },
              child: Container(
                child: widget.image == true
                    ? Padding(
                        padding: EdgeInsets.all(0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: widget.sentByMe
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  )
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20),
                                  ),
                            image: DecorationImage(
                              image: NetworkImage(widget.message),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: widget.sentByMe
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                          color: widget.sentByMe ? orange : disable,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            widget.message,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 16,
                              color: mobileSearchColor,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              child: Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.time),
                style: const TextStyle(
                  fontSize: 12,
                  color: unselected,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context, userData, groupdata) {
    final _report = FirebaseFirestore.instance.collection('report').doc();
    final TextEditingController _ReportController = TextEditingController();

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      )),
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.image == false
                  ? ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      //ignore: unnecessary_new
                      title: const Center(
                        child: Text(
                          'Copy Text',
                          style: TextStyle(
                              fontFamily: 'MyCustomFont', fontSize: 20),
                        ),
                      ),

                      onTap: () async {
                        Clipboard.setData(
                          new ClipboardData(
                            text: widget.message,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    )
                  : ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      title: const Center(
                          child: Text(
                        'Save Image',
                        style:
                            TextStyle(fontFamily: 'MyCustomFont', fontSize: 20),
                      )),
                      onTap: () async {
                        String url = widget.message;

                        final tempDir = await getTemporaryDirectory();
                        final path = '${tempDir.path}/TungTee.jpg';
                        try {
                          await Dio().download(url, path);
                          await GallerySaver.saveImage(path,
                                  albumName: 'TungTee')
                              .then((success) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                          });
                        } catch (e) {
                          log('ErrorWhileSavingImg: $e');
                        }
                      },
                    ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                title: const Center(
                    child: Text(
                  'Reply',
                  style: TextStyle(fontFamily: 'MyCustomFont', fontSize: 20),
                )),
                onTap: () {
                  //return replyToMessage(context);
                },
              ),
              if (widget.sentByMe == false)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                  title: const Center(
                      child: Text(
                    'Report',
                    style: TextStyle(
                        color: redColor,
                        fontFamily: 'MyCustomFont',
                        fontSize: 20),
                  )),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
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
