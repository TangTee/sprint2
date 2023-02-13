import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tangteevs/utils/color.dart';

import '../utils/my_date_util.dart';
import '../utils/showSnackbar.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool image;
  final String sender;
  final String profile;
  final String time;
  final bool sentByMe;

  const MessageBubble(
      {Key? key,
      required this.message,
      required this.image,
      required this.sender,
      required this.time,
      required this.sentByMe,
      required this.profile})
      : super(key: key);

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
        left: widget.sentByMe ? 0 : 24,
        right: widget.sentByMe ? 24 : 0,
      ),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: widget.image == true
            ? EdgeInsets.only(
                top: widget.sentByMe ? 0 : 7,
              )
            : EdgeInsets.only(
                top: widget.sentByMe ? 2 : 7,
                bottom: 7,
                left: 10,
                right: 10,
              ),
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
          color: widget.sentByMe
              ? orange
              : userData['Displayname'].toString() == true &&
                      userData['profile'].toString() == true
                  ? mobileBackgroundColor
                  : disable,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width:
                  widget.sentByMe ? 0 : MediaQuery.of(context).size.width * 0.3,
              child: Row(
                children: [
                  widget.sentByMe
                      ? SizedBox()
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                            userData['profile'].toString(),
                          ),
                          radius: 15,
                        ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  widget.sentByMe
                      ? SizedBox()
                      : Text(
                          userData['Displayname'].toString().toUpperCase(),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: mobileSearchColor,
                              letterSpacing: -0.5),
                        ),
                ],
              ),
            ),
            if (widget.image == true)
              Padding(
                padding: EdgeInsets.all(0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.65,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.message),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            if (widget.image == false)
              Text(
                widget.message,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 16,
                  color: mobileSearchColor,
                ),
              ),
            // if (widget.image == false)
            //   Text(
            //     MyDateUtil.getFormattedTime(
            //         context: context, time: widget.time),
            //     style: const TextStyle(
            //       fontSize: 13,
            //       color: unselected,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
