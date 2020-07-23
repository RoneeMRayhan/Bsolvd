import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:path/path.dart' as Path;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:story_view/story_view.dart';
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
  final StoryController controller = StoryController();
  String createCryptoRandomString([int length = 32]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (index) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final StoryController controller = StoryController();
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
            itemList.length == 0
                ? Text("Loading")
                : Expanded(
                    child: ListView(
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: height - 290,
                          child: StoryView(
                            storyItems: [
                              //for (var i in itemList) show1(i),
                              StoryItem.text(
                                title: "null",
                                backgroundColor: Colors.red,
                                roundedTop: true,
                              ),
                              StoryItem.pageVideo(
                                "https://firebasestorage.googleapis.com/v0/b/myfirstproject-c67e9.appspot.com/o/video%2F87fe03f0-c5e7--11ea-b384-a9f3",
                                controller: controller,
                              ),
                              StoryItem.inlineImage(
                                url:
                                    "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
                                caption: Text(
                                  "CaptionText",
                                  style: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: Colors.black54,
                                    fontSize: 17,
                                  ),
                                ),
                                controller: controller,
                              ),
                            ],
                            controller: controller,
                            onStoryShow: (s) => print("Showing a story"),
                            onComplete: () => print("Completed a cycle"),
                            progressPosition: ProgressPosition.bottom,
                            repeat: false,
                            inline: true,
                          ),
                        ),
                        Material(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (contex) => MoreStories(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(8),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    "View more stories...",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  show1(String data) {
    StoryItem.inlineImage(
        url: data,
        caption: Text(
          "Happy Codding",
          style: TextStyle(
            color: Colors.white,
            backgroundColor: Colors.black54,
            fontSize: 17,
          ),
        ),
        controller: controller);
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

class MoreStories extends StatefulWidget {
  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final StoryController storyController = StoryController();
  @override
  void dispose() {
    super.dispose();
    storyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryView(
          storyItems: [
            StoryItem.text(
              title: "Coding story title",
              backgroundColor: Colors.purple[500],
            ),
            StoryItem.text(
              title: "Amaging\n\nTap to continue.",
              backgroundColor: Colors.pink[500],
              textStyle: TextStyle(
                fontFamily: 'Dancing',
                fontSize: 40,
              ),
            ),
            StoryItem.pageImage(
              url:
                  "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
              caption: "Still sampling",
              controller: storyController,
            ),
            StoryItem.pageImage(
                url: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                caption: "Working with gifs",
                controller: storyController),
          ],
          onStoryShow: (value) {
            print("Showing a story");
          },
          onComplete: () {
            print("Completed a cycle");
          },
          progressPosition: ProgressPosition.top,
          repeat: false,
          controller: storyController),
    );
  }
}
