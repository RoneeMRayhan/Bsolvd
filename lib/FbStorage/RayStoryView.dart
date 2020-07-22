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
    return Scaffold(
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

  Future<void> getImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery)
        .then((value) => image = value);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('new/${Path.basename(image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.onComplete;

    storageReference.getDownloadURL().then((fileURL) {
      _uploadedFileUrl = fileURL;
      if (_uploadedFileUrl != null) {
        dynamic key = createCryptoRandomString(32);
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
