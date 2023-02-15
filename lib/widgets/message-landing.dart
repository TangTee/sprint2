import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/my_date_util.dart';
import '../utils/color.dart';

class MessagePreviewWidget extends StatefulWidget {
  const MessagePreviewWidget({
    Key? key,
    required this.messageTitle,
    required this.messageContent,
    required this.timer,
    required this.isunread,
    required this.messageTime,
    required this.messageImage,
  }) : super(key: key);

  final String messageTitle;
  final String messageImage;
  final String messageContent;
  final bool timer;
  final bool isunread;
  final String messageTime;

  @override
  _MessagePreviewWidgetState createState() => _MessagePreviewWidgetState();
}

class _MessagePreviewWidgetState extends State<MessagePreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: widget.messageImage)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot =
                  snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.10,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: green,
                              backgroundImage: NetworkImage(
                                documentSnapshot['profile'].toString(),
                              ),
                              radius: 25,
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(
                                      left: 30,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          child: Text(
                                            widget.messageTitle,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: 'MyCustomFont',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(
                                      left: 30,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.55,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          child: Text(
                                            '' + widget.messageContent,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontFamily: 'MyCustomFont',
                                              fontSize: 14,
                                              fontWeight: widget.isunread
                                                  ? FontWeight.w100
                                                  : FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          child: Text(
                                              widget.timer
                                                  ? ''
                                                  : MyDateUtil.getFormattedTime(
                                                      context: context,
                                                      time: widget.messageTime),
                                              style: TextStyle(
                                                  fontFamily: 'MyCustomFont',
                                                  fontSize: 14)),
                                        ),
                                        SizedBox(
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: purple,
                                            size: 20,
                                          ),
                                        ),
                                      ],
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
