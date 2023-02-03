import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tangteevs/profile/Profile.dart';
import 'package:tangteevs/services/auth_service.dart';
import 'package:tangteevs/services/database_service.dart';
import '../utils/color.dart';
import '../utils/showSnackbar.dart';
import '../widgets/custom_textfield.dart';

import 'package:image_picker/image_picker.dart';

class EditPage extends StatefulWidget {
  final String uid;
  const EditPage({Key? key, required this.uid}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  ImagePicker imagePicker = ImagePicker();
  String _ImageProfileController = '';
  File? media1;

  final user = FirebaseAuth.instance.currentUser;
  DatabaseService databaseService = DatabaseService();
  String Displayname = "";
  bool _isLoading = false;
  String bio = "";
  String facebook = "";
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  final TextEditingController _DisplaynameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  var userData = {};
  bool isLoading = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;
      _DisplaynameController.text = userData['Displayname'].toString();
      _bioController.text = userData['bio'].toString();
      _genderController.text = userData['gender'].toString();
      _instagramController.text = userData['instagram'].toString();
      _facebookController.text = userData['facebook'].toString();
      _ImageProfileController = userData['profile'].toString();
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
    return isLoading
        ? const Center()
        : DismissKeyboard(
            child: MaterialApp(
              home: Scaffold(
                bottomNavigationBar: null,
                backgroundColor: mobileBackgroundColor,
                appBar: AppBar(
                  backgroundColor: mobileBackgroundColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: mobileSearchColor, size: 30),
                    onPressed: () => {
                      Navigator.of(context).popUntil((route) => route.isFirst)
                    },
                  ),
                  toolbarHeight: MediaQuery.of(context).size.height * 0.13,
                  centerTitle: true,
                  elevation: 0,
                  title: const Text(
                    "PROFILE",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: purple,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: unselected,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(-20),
                    child: Text("แก้ไขข้อมูลส่วนตัวของคุณ",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: unselected)),
                  ),
                ),
                body: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: mobileBackgroundColor,
                      ))
                    : SafeArea(
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                ),
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: ((builder) => bottomSheet()),
                                      );
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: purple,
                                              )),
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundColor: transparent,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(60),
                                              child: media1 != null
                                                  ? Image.file(media1!)
                                                  : Image.network(
                                                      userData['profile']
                                                          .toString(),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: 2,
                                                color: primaryColor,
                                              ),
                                              color: lightPurple,
                                            ),
                                            child: Ink(
                                              child: Icon(
                                                Icons.edit,
                                                color: primaryColor,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                ),
                                Center(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: TextFormField(
                                      controller: _DisplaynameController,
                                      decoration: textInputDecorationp.copyWith(
                                          hintText: 'Display Name',
                                          prefixIcon: Icon(
                                            Icons.person_pin_circle_sharp,
                                            color: lightPurple,
                                            //color: Theme.of(context).primaryColor,
                                          )),
                                      validator: (val) {
                                        if (val!.isNotEmpty) {
                                          return null;
                                        } else {
                                          return "plase Enter Display Name";
                                        }
                                      },
                                      onChanged: (val) {
                                        setState(() {
                                          Displayname = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: TextFormField(
                                    controller: _bioController,
                                    maxLines: 3,
                                    decoration: textInputDecorationp.copyWith(
                                        hintText: 'bio',
                                        prefixIcon: Icon(
                                          Icons.pending,
                                          color: lightPurple,
                                        )),
                                    validator: (val) {
                                      if (val!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "plase Enter Your bio";
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        bio = val;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: TextFormField(
                                    controller: _instagramController,
                                    decoration: textInputDecorationp.copyWith(
                                        hintText: "IG Username",
                                        prefixIcon: Image.asset(
                                            'assets/images/instagram.png')),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: TextFormField(
                                    controller: _facebookController,
                                    decoration: textInputDecorationp.copyWith(
                                      hintText: "Facebook Url",
                                      prefixIcon: Image.asset(
                                        'assets/images/facebook.png',
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val!.isNotEmpty) {
                                        if (!Uri.tryParse(val)!
                                            .hasAbsolutePath) {
                                          return 'Please enter facebook link ';
                                        }
                                      }
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        facebook = val;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: purple,
                                      minimumSize: const Size(307, 49),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30))),
                                  child: const Text(
                                    "save",
                                    style: TextStyle(
                                        color: primaryColor, fontSize: 24),
                                  ),
                                  onPressed: () {
                                    Updata();
                                  },
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
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('Profile');
      Reference referenceImageToUpload =
          referenceDirImages.child("${user?.uid}");
      //Store the file
      await referenceImageToUpload.putFile(File(file.path));
      //  Success: get the download URL
      _ImageProfileController = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      //Some error occurred
    }
    setState(() {
      media1 = File(file.path);
    });
  }

  Updata() async {
    final String Displayname = _DisplaynameController.text;
    final String bio = _bioController.text;
    final String instagram = _instagramController.text;
    final String facebook = _facebookController.text;
    final String gender = _genderController.text;
    final String ImageProfile = _ImageProfileController.toString();
    if (_formKey.currentState!.validate()) {
      await _users.doc(widget.uid).update({
        "Displayname": Displayname,
        "bio": bio,
        "gender": gender,
        "instagram": instagram,
        "facebook": facebook,
        "profile": ImageProfile,
      });
      _DisplaynameController.text = '';
      _bioController.text = '';
      _instagramController.text = '';
      _facebookController.text = '';
      _genderController.text = '';
      _ImageProfileController = '';
      Navigator.of(context).popUntil((route) => route.isFirst);
      ;
    }
  }
}
