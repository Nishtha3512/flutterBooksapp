import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/models/books_model.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets.dart';
import 'home.dart';

class CreateBooks extends StatefulWidget {
  @override
  _CreateBooksState createState() => _CreateBooksState();
}

class _CreateBooksState extends State<CreateBooks> {
  bool isLoading = false;
  // CrudMethods crudMethods = new CrudMethods();
  File selectedImage;
  var dropdownValue = '1';
  TextEditingController _nameEditController = TextEditingController();
  TextEditingController _authorEditController = TextEditingController();
  TextEditingController _descEditController = TextEditingController();
  var bytes;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final user = FirebaseAuth.instance.currentUser.uid;
//final userid = user.uid;

  Future getImage() async {
    var file = await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(file.path);
      bytes = selectedImage.readAsBytes().toString();
    });
  }

  uploadStatus() async {
    setState(() {
      isLoading = true;
    });
    var collectionName = dropdownValue;
    var blogUpload = await uploadBooks(collectionName);

    BooksModel booksModel = new BooksModel();

    booksModel.imageURL = blogUpload.toString();
    booksModel.name = _nameEditController.text;
    booksModel.author = _authorEditController.text;
    booksModel.rating = dropdownValue;

    String docId = FirebaseFirestore.instance.collection(user).doc().id;
    booksModel.docId = docId;

    // await FirebaseFirestore.instance
    //     .collection(user)
    //     .doc(booksModel.docId)
    //     .set(booksModel.toMap());
    await FirebaseFirestore.instance
        .collection('admin')
        .doc(user)
        .collection('products')
        .add(booksModel.toMap());

    Fluttertoast.showToast(msg: 'successfully uploaded');
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
    // Navigator.pop(context);
    setState(() {
      isLoading = false;
    });
  }

  Future<dynamic> uploadBooks(String collection) async {
    if (selectedImage != null) {
      var fbStorageRef = FirebaseStorage.instance.ref().child(collection);

      var task = await fbStorageRef
          .child("image_" + DateTime.now().toIso8601String())
          .putFile(selectedImage);

      var snapshot = task;

      var downloadUrl = await snapshot.ref.getDownloadURL();
      print('this is Url $downloadUrl');
      return downloadUrl;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add Products',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0.0,
        actions: [
          GestureDetector(
            onTap: () {
              if (selectedImage != null) {
                uploadStatus();
              } else {
                Fluttertoast.showToast(msg: 'please select the image');
              }
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.file_upload)),
          )
        ],
      ),
      body: isLoading
          ? Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              // color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      getImage();
                    },
                    child: selectedImage != null
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            height: 170,
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                selectedImage,
                                fit: BoxFit.cover,
                              ),
                            ))
                        : Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            height: 170,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6)),
                            width: MediaQuery.of(context).size.width,
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.black45,
                            )),
                  ),
                  // selectedImage != null ? Text(bytes) : Text('Bytes'),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  //   color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.teal)),
                              child: Row(
                                children: [
                                  Text(
                                    'Ratings',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  DropdownButton<String>(
                                    isExpanded: false,
                                    value: dropdownValue,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 16,
                                    autofocus: false,
                                    style: const TextStyle(color: Colors.white),
                                    // underline: Container(
                                    //   height: 2,
                                    //   color: Colors.deepPurpleAccent,
                                    // ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue = newValue;
                                      });
                                    },
                                    items: <String>['1', '2', '3', '4', '5']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(value),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: textfrm(
                              hint: 'Name',
                              controller: _nameEditController,
                              keyboadrdtype: TextInputType.name),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: textfrm(
                        //       hint: 'Author Name',
                        //       controller: _descEditController,
                        //       keyboadrdtype: TextInputType.name),
                        // ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: textfrm(
                              hint: 'Author Name',
                              controller: _authorEditController,
                              keyboadrdtype: TextInputType.name),
                        ),
                        // TextField(
                        //   controller: _titleEditController,
                        //   decoration: InputDecoration(hintText: 'Title'),
                        // ),
                        // TextField(
                        //   controller: _descEditController,
                        //   decoration: InputDecoration(hintText: 'Description'),
                        // )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
