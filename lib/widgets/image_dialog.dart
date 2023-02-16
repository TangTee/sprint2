import 'package:flutter/material.dart';
import 'package:tangteevs/model/chat_model.dart';
import 'package:tangteevs/utils/color.dart';

class ImageDialog extends StatelessWidget {
  const ImageDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        child: Stack(
          children: [
            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: redColor,
                  ),
                  child: Icon(
                    Icons.close,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: MediaQuery.of(context).size.width * 0.001,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(message),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
