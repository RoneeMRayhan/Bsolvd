import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:path/path.dart' as Path;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class RayStoryView extends StatefulWidget {
  RayStoryView({Key key}) : super(key: key);

  @override
  _RayStoryViewState createState() => _RayStoryViewState();
}

class _RayStoryViewState extends State<RayStoryView> {
  final fdb = FirebaseDatabase.instance.reference().child("RayImages");
  List<String> itemList = List();
  File image;
  String _uploadedFileUrl;
  String createCryptoRandomString([int length = 32]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
//Horizontal Listview Tile
    Widget LoadImages() {
      print(itemList.length);
      return Expanded(
        child: itemList.length == 0
            ? Text("Loading")
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xff9c37c0),
                        ),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                            itemList[index],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      );
    }

    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(8),
        color: Colors.amber,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
              child: Container(
                height: 60,
                width: width,
                //Horizontal Listview Tile
                child: LoadImages(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getImage(),
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fdb.once().then((DataSnapshot dataSnapshot) {
      print(dataSnapshot);
      var data = dataSnapshot.value;
      print(data);
      itemList.clear();
      //ItemList Preparation
      data.forEach((key, value) {
        itemList.add(value['link']);
      });
      setState(() {
        print("value is ");
        print(itemList.length);
      });
    });
  }

  Future<void> getImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery)
        .then((value) => image = value);
    //0=> Save to Firebase Storage
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('new/${Path.basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileUrl = fileURL;
      if (_uploadedFileUrl != null) {
        dynamic key = createCryptoRandomString(32);
        //0=> Save to Firebase Realtime Database
        fdb.child(key).set({"id": key, "link": _uploadedFileUrl}).then(
            (value) => showToast());
      } else {
        print("URL is null");
      }
    });
  }

  showToast() {
    Toast.show("ImageSaved", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }
}
