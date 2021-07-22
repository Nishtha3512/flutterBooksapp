import 'dart:async';
import 'dart:io';

import 'package:paginate_firestore/bloc/pagination_listeners.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'create_products.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File imagefile;
  bool isLogedIn = false;
  @override
  void initState() {
    super.initState();
    getProducts();
    FirebaseAuth.instance.authStateChanges().listen((firebaseuser) {
      if (firebaseuser == null) {
        setState(() {
          isLogedIn = false;
          print(isLogedIn);
        });
        // user not logged in
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => Login()), (route) => false);
      } else {
        setState(() {
          isLogedIn = true;
          print(isLogedIn);
        });
        // user alredy logged in
      }
    });
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getProducts();
      }
    });
  }

  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> products = []; // stores fetched products
  bool isLoading = false; // track if products fetching
  bool hasMore = true; // flag for more products available or not
  int documentLimit = 3; // documents to be fetched per request
  DocumentSnapshot
      lastDocument; // flag for last document from where next 10 records to be fetched
  ScrollController _scrollController = ScrollController();
  // listener for listview scrolling
  // ignore: close_sinks

  StreamController<List<DocumentSnapshot>> _controller =
      StreamController<List<DocumentSnapshot>>();

  Stream<List<DocumentSnapshot>> get _streamController => _controller.stream;
  var user;
  getProducts() async {
    user = FirebaseAuth.instance.currentUser.uid;
    print(user);
    if (!hasMore) {
      print('No More Products');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot docsnap;
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await
          // firestore
          //     .collection(user)
          //     .orderBy('name')
          //     .limit(documentLimit)
          //     .get()
          firestore
              .collection('one')
              .doc(user)
              .collection('products')
              .limit(documentLimit)
              .get()
              // ignore: missing_return
              .then((QuerySnapshot querysnapshot) {
        querysnapshot.docs.forEach((doc) {
          products.add(doc);
          print(doc["name"]);
        });
      });
    } else {
      querySnapshot = await firestore
          // .collection(user)
          // .orderBy('name')
          // .startAfterDocument(lastDocument)
          // .limit(documentLimit)
          // // ignore: missing_return
          // .get()
          .collection('one')
          .doc(user)
          .collection('products')
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .get()
          // ignore: missing_return
          .then((QuerySnapshot querysnapshot) {
        querysnapshot.docs.forEach((doc) {
          products.add(doc);
          print(products.length);
          print(doc["name"]);
        });
      });
    }
    if (querySnapshot.docs.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];
    products.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Products',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0.0,
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  // ignore: unnecessary_statements
                  // isLogedIn
                  //     ? null
                  //     :
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                  // FirebaseAuth.instance.signOut().then((value) =>
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => Login())));
                }),
          ),
        ],
        leading: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.home)),
      ),
      body:
          // Column(
          //   children: [
          //     Expanded(
          //       child: StreamBuilder(
          //           stream: _streamController,
          //           builder: (context, snapshot) {
          //             if (!snapshot.hasData) {
          //               return CircularProgressIndicator();
          //             }
          //             if (snapshot.data.length == 0) {
          //               return Center(child: Text('No Data'));
          //             }

          //             return GestureDetector(
          //               onTap: () async {
          //                 // imagefile = await Navigator.push(context,
          //                 //     MaterialPageRoute(builder: (context) => DisplayImage()));
          //                 setState(() {
          //                   imagefile = snapshot.data.docs['imageURL'];
          //                 });
          //               },
          //               child: Container(
          //                   child: ListView.builder(
          //                       controller: _scrollController,
          //                       shrinkWrap: true,
          //                       padding: EdgeInsets.symmetric(horizontal: 16),
          //                       itemCount: products.length,
          //                       itemBuilder: (context, index) {
          //                         return Container(
          //                           margin: EdgeInsets.only(bottom: 16, top: 16.0),
          //                           height: 270,
          //                           child: Column(
          //                             children: [
          //                               ClipRRect(
          //                                   borderRadius: BorderRadius.circular(6),
          //                                   child: Container(
          //                                     height: 170,
          //                                     child: CachedNetworkImage(
          //                                       imageUrl: snapshot.data.docs[index]
          //                                           ['imageURL'],
          //                                       width: MediaQuery.of(context)
          //                                           .size
          //                                           .width,
          //                                       fit: BoxFit.cover,
          //                                     ),
          //                                   )),
          //                               // Container(
          //                               //   height: 170,
          //                               //   decoration: BoxDecoration(
          //                               //       color: Colors.black45.withOpacity(0.3),
          //                               //       borderRadius: BorderRadius.circular(6)),
          //                               // ),
          //                               Container(
          //                                 width: MediaQuery.of(context).size.width,
          //                                 child: Column(
          //                                   mainAxisAlignment:
          //                                       MainAxisAlignment.center,
          //                                   crossAxisAlignment:
          //                                       CrossAxisAlignment.center,
          //                                   children: [
          //                                     Text(
          //                                         snapshot.data.docs[index]['name'],
          //                                         style: TextStyle(
          //                                             fontSize: 25,
          //                                             fontWeight: FontWeight.w400)),
          //                                     SizedBox(
          //                                       height: 5,
          //                                     ),
          //                                     Text(
          //                                         snapshot.data.docs[index]
          //                                             ['author'],
          //                                         style: TextStyle(
          //                                             fontSize: 15,
          //                                             fontWeight: FontWeight.w400)),
          //                                     SizedBox(
          //                                       height: 5,
          //                                     ),
          //                                     Text(
          //                                       'Rs ' +
          //                                           snapshot.data.docs[index]
          //                                               ['rating'],
          //                                       textAlign: TextAlign.center,
          //                                       style: TextStyle(
          //                                           fontSize: 15,
          //                                           fontWeight: FontWeight.w400),
          //                                     ),
          //                                   ],
          //                                 ),
          //                               )
          //                             ],
          //                           ),
          //                         );
          //                       })),
          //             );
          //           }),
          //     ),
          //     isLoading
          //         ? Container(
          //             width: MediaQuery.of(context).size.width,
          //             padding: EdgeInsets.all(5),
          //             color: Colors.yellowAccent,
          //             child: Text(
          //               'Loading',
          //               textAlign: TextAlign.center,
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           )
          //         : Container()
          //   ],
          // ),

          RefreshIndicator(
        child: PaginateFirestore(
          itemBuilder: (index, context, documentSnapshot) => Container(
              margin: EdgeInsets.only(bottom: 16, top: 16.0),
              height: 270,
              child: Column(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 170,
                      child: CachedNetworkImage(
                        imageUrl: documentSnapshot.data()['imageURL'],
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    )),
                // Container(
                //   height: 170,
                //   decoration: BoxDecoration(
                //       color: Colors.black45.withOpacity(0.3),
                //       borderRadius: BorderRadius.circular(6)),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Book: ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            documentSnapshot.data()['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Author Name: ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            documentSnapshot.data()['author'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rating: ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                          Text(
                            documentSnapshot.data()['rating'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ])),
          // orderBy is compulsary to enable pagination
          query: FirebaseFirestore.instance
              .collection('admin')
              .doc(user)
              .collection('products')
              .orderBy('name'),
          //FirebaseFirestore.instance
          //     .collection('blogimages')
          //     // .limit(3)
          //     .orderBy('name'),
          listeners: [
            refreshChangeListener,
          ],
          itemBuilderType: PaginateBuilderType.listView,
        ),
        onRefresh: () async {
          refreshChangeListener.refreshed = true;
        },
      ),
      floatingActionButton: isLogedIn
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateBooks()));
                    },
                    child: Icon(Icons.add),
                  )
                ],
              ),
            )
          : null,
    );
  }
}
