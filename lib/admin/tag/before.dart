// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tangteevs/utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../widgets/custom_textfield.dart';
import 'Category.dart';
import 'hsv_picker.dart';

class BeforeTagPage extends StatefulWidget {
  const BeforeTagPage({Key? key}) : super(key: key);
  @override
  _BeforeTagPageState createState() => _BeforeTagPageState();
}

class _BeforeTagPageState extends State<BeforeTagPage> {
  final CollectionReference _categorys =
      FirebaseFirestore.instance.collection('categorys');
  final TextEditingController _CategoryController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final categorysSet = FirebaseFirestore.instance.collection('categorys').doc();

  bool lightTheme = true;
  Color currentColor = purple;
  List<Color> colorHistory = [];

  void changeColor(Color color) => setState(() => currentColor = color);

  Future<void> _create([DocumentSnapshot? documentSnapshot, value]) async {
    Color pickerColor2;
    ValueChanged<Color> onColorChanged = changeColor;
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _CategoryController,
                    decoration: textInputDecorationp.copyWith(
                        hintText: 'category'.toString()),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  HSVColorPicker(
                    pickerColor: currentColor,
                    onColorChanged: changeColor,
                    colorHistory: colorHistory,
                    onHistoryChanged: (List<Color> colors) =>
                        colorHistory = colors,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'MyCustomFont',
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () async {
                        final String Category = _CategoryController.text;
                        // final String color = _colorController.text;
                        if (Category != null) {
                          await categorysSet.set({
                            "Category": Category,
                            "color": value,
                            "categoryId": categorysSet.id
                          });

                          _CategoryController.text = '';
                          _colorController.text = '';
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  hsvPicker(BuildContext context) {
    Color value = white;
    ValueChanged<Color> onColorChanged = changeColor;
    SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                titlePadding: const EdgeInsets.all(0),
                contentPadding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? const BorderRadius.vertical(
                              top: Radius.circular(500),
                              bottom: Radius.circular(100),
                            )
                          : const BorderRadius.horizontal(
                              right: Radius.circular(500)),
                ),
                content: SingleChildScrollView(
                  child: HueRingPicker(
                    pickerColor: value,
                    onColorChanged: onColorChanged,
                    enableAlpha: true,
                    displayThumbColor: true,
                  ),
                ),
              );
            },
          );
        },
        child: Text(
          'Color',
        ),
      ),
    );
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        useWhiteForeground(currentColor) ? Colors.white : Colors.black;
    return MaterialApp(
      home: DismissKeyboard(
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 50,
            backgroundColor: mobileBackgroundColor,
            leadingWidth: 130,
            centerTitle: true,
            leading: Container(
              padding: const EdgeInsets.all(0),
              child: Image.asset('assets/images/logo with name.png',
                  fit: BoxFit.scaleDown),
            ),
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: mobileBackgroundColor,
          body: Category(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _create(),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class Category extends StatelessWidget {
  final CollectionReference _categorys =
      FirebaseFirestore.instance.collection('categorys');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
            child: Text(
              'Categorys',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _categorys.snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
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
                      );
                    }
                    return ListView.builder(
                        itemCount: (snapshot.data! as dynamic).docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];
                          return CategoryWidget(
                              snap: (snapshot.data! as dynamic).docs[index]);
                        });
                  })),
        ],
      ),
    );
  }
}
