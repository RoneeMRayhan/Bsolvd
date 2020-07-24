import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class RayVideo extends StatefulWidget {
  RayVideo({Key key}) : super(key: key);

  @override
  _RayVideoState createState() => _RayVideoState();
}

class _RayVideoState extends State<RayVideo> {
  final fdb = FirebaseDatabase.instance.reference().child("VideoLinks");
  List<String> itemList = new List();
  //List<ModelProject> itemList = new List();
  FirebaseAuth mAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ListView(padding: const EdgeInsets.all(8), children: <Widget>[
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListView.separated(
                shrinkWrap: true,
                cacheExtent: 1000,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                key: PageStorageKey(widget.key),
                addAutomaticKeepAlives: true,
                itemCount: itemList.isEmpty ? 0 : itemList.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  width: double.infinity,
                  height: 250,
                  alignment: Alignment.center,
                  child: Container(
                    key: new PageStorageKey(
                      "keydata$index",
                    ),
                    child: VideoWidget(
                        play: true,
                        url: itemList[index]), //url: itemList[index].link,
                  ),
                ),
                separatorBuilder: (context, index) {
                  print("Index ${index + 1}");
                  return Divider();
                },
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          uploadToStorage();
        },
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Future uploadToStorage() async {
    var uuid = Uuid();
    dynamic id = uuid.v1();
    try {
      mAuth.signInAnonymously().then(
        (value) async {
          final file = await ImagePicker.pickVideo(source: ImageSource.gallery);
          StorageReference ref =
              FirebaseStorage.instance.ref().child("video").child(id);
          StorageUploadTask uploadTask =
              ref.putFile(file, StorageMetadata(contentType: 'video/mp4'));
          var storageTaskSnapshot = await uploadTask.onComplete;
          var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
          final String url = downloadUrl.toString();
          fdb.child(id).set(
            {
              "id": id,
              "link": url,
            },
          ).then(
            (value) {
              print("Done");
            },
          );
        },
      );
    } catch (e) {
      print(e);
    }
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
        /* ModelProject model = new ModelProject(
          link: value['link'],
          key: key,
        );
        itemList.add(model); */
        itemList.add(value['link']);
      });
      setState(() {
        print("value is ");
        print(itemList.length);
      });
    });
  }
}

class VideoWidget extends StatefulWidget {
  final bool play = true;
  final String url =
      "https://firebasestorage.googleapis.com/v0/b/bsolvd-f5f74.appspot.com/o/video%2F78d52270-cdb5-11ea-a422-c9efb26b8426?alt=media&token=370c4867-07d3-4811-9e44-03bad3663caf";
  //VideoWidget({Key key}) : super(key: key);
  VideoWidget({Key key, bool play, String url}) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    videoPlayerController = new VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture =
        videoPlayerController.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    // widget.videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return new Container(
            child: Card(
              key: new PageStorageKey(widget.url),
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chewie(
                      key: new PageStorageKey(widget.url),
                      controller: ChewieController(
                        videoPlayerController: videoPlayerController,
                        aspectRatio: 3 / 2,
                        autoInitialize: true,
                        looping: false,
                        autoPlay: false,
                        // Errors can occur for example when trying to play a video
                        // from a non-existent URL
                        errorBuilder: (context, errorMessage) {
                          return Center(
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
