import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tangteevs/chat/group_info.dart';
import 'package:tangteevs/services/database_service.dart';
import 'package:tangteevs/widgets/message-bubble.dart';
import 'package:tangteevs/widgets/custom_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/color.dart';
import '../utils/showSnackbar.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatPage(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ImagePicker imagePicker = ImagePicker();
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String _ImageUrl = '';
  String admin = "";
  bool isLoading = false;
  bool text = false;
  bool image = true;
  var groupData = {};
  var member = [];

  var userData = {};
  File? media;
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
          .doc(widget.userName)
          .get();

      userData = userSnap.data()!;

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
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        title: Text(widget.groupName),
        backgroundColor: lightPurple,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      groupMember: member,
                    ));
              },
              icon: const Icon(Icons.people))
        ],
      ),
      body: Stack(
        children: <Widget>[
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.075,
              color: white,
              child: Form(
                child: Row(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.01,
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: ((builder) => bottomSheet()),
                      );
                    },
                    child: const Icon(
                      Icons.attach_file_outlined,
                      color: purple,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.78,
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      minLines: 1,
                      controller: messageController,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(width: 2, color: unselected),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(70)),
                          borderSide: BorderSide(width: 2, color: unselected),
                        ),
                        hintText: 'Send a message...',
                        hintStyle: TextStyle(
                          color: unselected,
                          fontFamily: 'MyCustomFont',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      sendMessage();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      child: const Center(
                          child: Icon(
                        Icons.send_outlined,
                        size: 30,
                        color: purple,
                      )),
                    ),
                  )
                ]),
              ),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .orderBy("time")
          .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                        image: snapshot.data.docs[index]['image'],
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        profile: snapshot.data.docs[index]['profile'],
                        time: snapshot.data.docs[index]['time'].toString(),
                        sentByMe: userData['Displayname'].toString() ==
                            snapshot.data.docs[index]['sender']);
                  },
                ),
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": userData['Displayname'].toString(),
        "time": DateTime.now().millisecondsSinceEpoch,
        "profile": userData['profile'].toString(),
        "image": text
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  sendImage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": userData['Displayname'].toString(),
        "time": DateTime.now().millisecondsSinceEpoch,
        "profile": userData['profile'].toString(),
        "image": image
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }

  Widget bottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Choose Profile Photo',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: TextButton.icon(
                  icon: Icon(
                    Icons.camera,
                    color: lightPurple,
                  ),
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  label: Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              SizedBox(
                child: TextButton.icon(
                  icon: Icon(
                    Icons.image,
                    color: lightPurple,
                  ),
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                  label: Text(
                    'Gallery',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    XFile? file = await imagePicker.pickImage(
      source: source,
    );
    // print('${file?.path}');

    if (file == null) return;

    try {
      String getRandomString(int length) {
        const characters =
            '+-*=?AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
        Random random = Random();
        return String.fromCharCodes(Iterable.generate(length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length))));
      }

      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('Profile');
      Reference referenceImageToUpload =
          referenceDirImages.child(getRandomString(30));
      //Store the file
      await referenceImageToUpload.putFile(File(file.path));
      //  Success: get the download URL

      messageController.text = (await referenceImageToUpload.getDownloadURL());
      sendImage();
    } catch (error) {
      //Some error occurred
    }
    setState(() {
      media = File(file.path);
    });
  }
}
