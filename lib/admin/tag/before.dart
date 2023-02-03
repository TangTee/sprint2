// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tangteevs/utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/custom_textfield.dart';
import 'Category.dart';

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

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
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
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: _colorController,
                      decoration: textInputDecorationp.copyWith(
                          hintText: 'color (Hex color)'.toString()),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
                        final String color = _colorController.text;
                        if (color != null) {
                          await categorysSet.set({
                            "Category": Category,
                            "color": color,
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

  @override
  Widget build(BuildContext context) {
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
