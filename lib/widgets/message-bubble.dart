import 'package:flutter/material.dart';
import 'package:tangteevs/utils/color.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool image;
  final String sender;
  final String profile;
  final bool sentByMe;

  const MessageBubble(
      {Key? key,
      required this.message,
      required this.image,
      required this.sender,
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
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
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
            color:
                widget.sentByMe ? Theme.of(context).primaryColor : unselected),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.profile,
              ),
              radius: widget.sentByMe ? 0 : 15,
            ),
            Text(
              widget.sentByMe ? '' : widget.sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            if (widget.image == true)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.message),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            if (widget.image == false)
              Text(widget.message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 16, color: white))
          ],
        ),
      ),
    );
  }
}
