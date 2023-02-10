import 'package:flutter/material.dart';
import 'package:tangteevs/utils/color.dart';

import '../utils/my_date_util.dart';

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
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
          top: widget.sentByMe ? 0 : 7,
          bottom: 10,
          left: 10,
          right: widget.sentByMe ? 0 : 10,
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
          color: widget.sentByMe ? orange : disable,
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
                            widget.profile,
                          ),
                          radius: 15,
                        ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  widget.sentByMe
                      ? SizedBox()
                      : Text(
                          widget.sender.toUpperCase(),
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.005,
            ),
            if (widget.image == true)
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.65,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.message),
                    fit: BoxFit.fill,
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
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.time),
              style: const TextStyle(
                fontSize: 13,
                color: unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
