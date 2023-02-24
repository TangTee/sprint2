import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import '../utils/color.dart';

showModalBottomSheetC(BuildContext context) {
  final CollectionReference _categorys =
      FirebaseFirestore.instance.collection('categorys');
  var value = new Map();

  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.1,
        height: MediaQuery.of(context).size.height * 0.5,
        child: StreamBuilder(
          stream: _categorys.snapshots(),
          builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 2 / 2,
                    crossAxisSpacing: 30,
                    mainAxisSpacing: 20),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: (snapshot.data! as dynamic).docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      snapshot.data!.docs[index];

                  var Mytext = new Map();
                  Mytext['Category'] = documentSnapshot['Category'];
                  Mytext['categoryId'] = documentSnapshot['categoryId'];
                  Mytext['color'] = documentSnapshot['color'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: HexColor(Mytext['color']),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ListTile(
                          textColor: mobileSearchColor,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          title: Center(
                              child: Text(
                            Mytext['Category'],
                            style: TextStyle(
                              fontFamily: 'MyCustomFont',
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          )),
                          onTap: () {
                            value = showModalBottomSheetT(
                                context, Mytext['categoryId'], value);
                          },
                        )
                      ],
                    ),
                  );
                },
              );
            }
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
          }),
        ),
      );
    },
  );
  return value;
}

// showModalBottomSheetT(BuildContext context, categoryId, value) {
//   final CollectionReference _tags =
//       FirebaseFirestore.instance.collection('tags');

//   showModalBottomSheet(
//     useRootNavigator: true,
//     context: context,
//     builder: (BuildContext context) {
//       return Container(
//         height: MediaQuery.of(context).size.height * 0.5,
//         width: MediaQuery.of(context).size.width * 0.5,
//         child: StreamBuilder(
//           stream: _tags.where("categoryId", isEqualTo: categoryId).snapshots(),
//           builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             if (snapshot.hasData) {
//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: SizedBox(
//                   child: Expanded(
//                     child: ListView.builder(
//                       padding: new EdgeInsets.only(top: 10.0),
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       scrollDirection: Axis.horizontal,
//                       shrinkWrap: true,
//                       itemCount: (snapshot.data! as dynamic).docs.length,
//                       itemBuilder: (context, index) {
//                         final DocumentSnapshot documentSnapshot =
//                             snapshot.data!.docs[index];

//                         var Mytext = new Map();
//                         Mytext['tag'] = documentSnapshot['tag'];
//                         Mytext['tagColor'] = documentSnapshot['tagColor'];

//                         return Wrap(direction: Axis.horizontal, children: <
//                             Widget>[
//                           Container(
//                               width: MediaQuery.of(context).size.width * 0.3,
//                               height: MediaQuery.of(context).size.height * 0.1,
//                               child: Column(children: [
//                                 SizedBox(
//                                   child: OutlinedButton(
//                                     onPressed: () {
//                                       value['_tag2'] = Mytext['tag'].toString();
//                                       value['_tag2Color'] =
//                                           Mytext['tagColor'].toString();
//                                       Navigator.of(context).pop();
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: Text(
//                                       Mytext['tag'],
//                                       style: const TextStyle(
//                                           color: mobileSearchColor,
//                                           fontSize: 14),
//                                     ),
//                                     style: OutlinedButton.styleFrom(
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(30)),
//                                         side: BorderSide(
//                                             color: HexColor(
//                                               Mytext['tagColor'],
//                                             ),
//                                             width: 1.5)),
//                                   ),
//                                 ),
//                               ])),
//                         ]);
//                       },
//                     ),
//                   ),
//                 ),
//               );
//             }
//             return Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: const <Widget>[
//                   SizedBox(
//                     height: 30.0,
//                     width: 30.0,
//                     child: CircularProgressIndicator(),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       );
//     },
//   );
//   return value;
// }

// showModalBottomSheetT(BuildContext context, categoryId, value) {
//   final CollectionReference _tags =
//       FirebaseFirestore.instance.collection('tags');

//   showModalBottomSheet(
//     useRootNavigator: true,
//     context: context,
//     builder: (BuildContext context) {
//       return Scaffold(
//           body: Column(
//         children: [
//           Flexible(
//             child: StreamBuilder(
//               stream:
//                   _tags.where("categoryId", isEqualTo: categoryId).snapshots(),
//               builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasData) {
//                   return ListView.builder(
//                     padding: EdgeInsets.only(top: 10.0),
//                     itemCount: (snapshot.data! as dynamic).docs.length,
//                     itemBuilder: (context, index) {
//                       final DocumentSnapshot documentSnapshot =
//                           snapshot.data!.docs[index];

//                       var Mytext = new Map();
//                       Mytext['tag'] = documentSnapshot['tag'];
//                       Mytext['tagColor'] = documentSnapshot['tagColor'];

//                       return Wrap(children: [
//                         SizedBox(
//                             // width: MediaQuery.of(context).size.width * 0.3,
//                             // height: MediaQuery.of(context).size.height * 0.1,
//                             width: 100,
//                             height: 50,
//                             child: Column(children: [
//                               SizedBox(
//                                 child: OutlinedButton(
//                                   onPressed: () {
//                                     value['_tag2'] = Mytext['tag'].toString();
//                                     value['_tag2Color'] =
//                                         Mytext['tagColor'].toString();
//                                     Navigator.of(context).pop();
//                                     Navigator.of(context).pop();
//                                   },
//                                   child: Text(
//                                     Mytext['tag'],
//                                     style: const TextStyle(
//                                         color: mobileSearchColor, fontSize: 14),
//                                   ),
//                                   style: OutlinedButton.styleFrom(
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(30)),
//                                       side: BorderSide(
//                                           color: HexColor(
//                                             Mytext['tagColor'],
//                                           ),
//                                           width: 1.5)),
//                                 ),
//                               ),
//                             ])),
//                       ]);
//                     },
//                   );
//                 }
//                 return Center(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: const <Widget>[
//                       SizedBox(
//                         height: 30.0,
//                         width: 30.0,
//                         child: CircularProgressIndicator(),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ),
//           )
//         ],
//       ));
//     },
//   );
//   return value;
// }

// showModalBottomSheetT(BuildContext context, categoryId, value) {
//   final CollectionReference _tags =
//       FirebaseFirestore.instance.collection('tags');

//   showModalBottomSheet(
//     useRootNavigator: true,
//     context: context,
//     builder: (BuildContext context) {
//       return SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(
//               width: MediaQuery.of(context).size.width * 0.9,
//               height: MediaQuery.of(context).size.height * 0.9,
//               child: StreamBuilder(
//                 stream: _tags
//                     .where("categoryId", isEqualTo: categoryId)
//                     .snapshots(),
//                 builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                   if (snapshot.hasData) {
//                     return Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: SizedBox(
//                         child: Expanded(
//                           child: ListView.builder(
//                             padding: new EdgeInsets.only(top: 10.0),
//                             // physics: const AlwaysScrollableScrollPhysics(),
//                             // scrollDirection: Axis.horizontal,
//                             shrinkWrap: true,
//                             itemCount: (snapshot.data! as dynamic).docs.length,
//                             itemBuilder: (context, index) {
//                               final DocumentSnapshot documentSnapshot =
//                                   snapshot.data!.docs[index];

//                               var Mytext = new Map();
//                               Mytext['tag'] = documentSnapshot['tag'];
//                               Mytext['tagColor'] = documentSnapshot['tagColor'];

//                               // return Wrap(direction: Axis.vertical, children: <
//                               //     Widget>[
//                               return Wrap(children: [
//                                 Container(
//                                     width:
//                                         MediaQuery.of(context).size.width * 0.3,
//                                     height: MediaQuery.of(context).size.height *
//                                         0.1,
//                                     child: Column(children: [
//                                       SizedBox(
//                                         child: OutlinedButton(
//                                           onPressed: () {
//                                             value['_tag2'] =
//                                                 Mytext['tag'].toString();
//                                             value['_tag2Color'] =
//                                                 Mytext['tagColor'].toString();
//                                             Navigator.of(context).pop();
//                                             Navigator.of(context).pop();
//                                           },
//                                           child: Text(
//                                             Mytext['tag'],
//                                             style: const TextStyle(
//                                                 color: mobileSearchColor,
//                                                 fontSize: 14),
//                                           ),
//                                           style: OutlinedButton.styleFrom(
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           30)),
//                                               side: BorderSide(
//                                                   color: HexColor(
//                                                     Mytext['tagColor'],
//                                                   ),
//                                                   width: 1.5)),
//                                         ),
//                                       ),
//                                     ])),
//                               ]);
//                             },
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                   return Center(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: const <Widget>[
//                         SizedBox(
//                           height: 30.0,
//                           width: 30.0,
//                           child: CircularProgressIndicator(),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
//   return value;
// }

showModalBottomSheetT(BuildContext context, categoryId, value) {
  final CollectionReference _tags =
      FirebaseFirestore.instance.collection('tags');

  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder(
        stream: _tags.where("categoryId", isEqualTo: categoryId).snapshots(),
        builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 700,
                height: 500,
                child: Expanded(
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              childAspectRatio: 3 / 2,
                              crossAxisSpacing: 30,
                              mainAxisSpacing: 20),
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (BuildContext ctx, index) {
                        final DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];

                        var Mytext = new Map();
                        Mytext['tag'] = documentSnapshot['tag'];
                        Mytext['tagColor'] = documentSnapshot['tagColor'];
                        return Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Column(children: [
                              SizedBox(
                                child: OutlinedButton(
                                  onPressed: () {
                                    value['_tag2'] = Mytext['tag'].toString();
                                    value['_tag2Color'] =
                                        Mytext['tagColor'].toString();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    Mytext['tag'],
                                    style: const TextStyle(
                                        color: mobileSearchColor, fontSize: 14),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      side: BorderSide(
                                          color: HexColor(
                                            Mytext['tagColor'],
                                          ),
                                          width: 1.5)),
                                ),
                              ),
                            ]));
                      }),
                ),
              ),
            );
          }
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
        }),
      );
    },
  );
  return value;
}
