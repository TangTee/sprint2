import 'package:flutter/material.dart';
import 'package:tangteevs/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/PostCard.dart';
import '../widgets/SearchResult.dart';
import '../widgets/custom_textfield.dart';

class FeedPage extends StatefulWidget {
  final String uid;
  const FeedPage({Key? key, required this.uid}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DismissKeyboard(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: mobileBackgroundColor,
          appBar: AppBar(
            backgroundColor: mobileBackgroundColor,
            elevation: 1,
            centerTitle: false,
            title: Image.asset(
              "assets/images/logo with name.png",
              width: MediaQuery.of(context).size.width * 0.31,
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: purple,
                  size: 30,
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SearchForm(),
        ),
      ),
    );
  }
}

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> {
  final activitySearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            forceElevated: innerBoxIsScrolled,
            backgroundColor: mobileBackgroundColor,
            elevation: 0,
            centerTitle: false,
            title: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.05,
                child: TextFormField(
                  controller: activitySearch,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: searchInputDecoration.copyWith(
                    hintText: 'ค้นหากิจกรรม หรือ Tag ที่คุณสนใจ',
                    hintStyle: TextStyle(
                      color: unselected,
                      fontFamily: 'MyCustomFont',
                    ),
                    prefixIcon: const Icon(
                      Icons.search_outlined,
                      color: orange,
                      size: 30,
                    ),
                    suffixIcon: activitySearch.text.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(Icons.clear),
                            color: orange,
                            iconSize: 18,
                            onPressed: (() {
                              activitySearch.clear();
                              setState(() {});
                            })),
                  ),
                  onFieldSubmitted: (value) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchResult(activity: activitySearch.text),
                      ),
                    );
                  },
                ),
              ),
            ),
            actions: [
              PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Make for you"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("New to you"),
                      ),
                    ];
                  },
                  icon: const Icon(
                    Icons.filter_list,
                    color: green,
                    size: 30,
                  ),
                  onSelected: (value) {
                    if (value == 0) {
                      final snackBar = SnackBar(
                        content: const Text("Display feed for you"),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            // Some code to undo the change.
                          },
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else if (value == 1) {
                      final snackBar = SnackBar(
                        content: const Text("Display new for you"),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            // Some code to undo the change.
                          },
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }),
            ],
          ),
          //),
        ];
      },
      body: SafeArea(
        child: PostCard(),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final CollectionReference _post =
      FirebaseFirestore.instance.collection('post');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _post.orderBy('timeStamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              child: Center(
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
              ),
            );
          }

          return ListView.builder(
              itemCount: (snapshot.data! as dynamic).docs.length,
              itemBuilder: (context, index) => Container(
                    child: CardWidget(
                        snap: (snapshot.data! as dynamic).docs[index]),
                  ));
        });
  }
}

