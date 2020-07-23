import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';

class RayGallery extends StatefulWidget {
  RayGallery({Key key}) : super(key: key);

  @override
  _RayGalleryState createState() => _RayGalleryState();
}

class _RayGalleryState extends State<RayGallery> {
  final fdb = FirebaseDatabase.instance.reference().child("RayImages");
  List<String> itemList = new List();
  List<String> listHeader = ["Gallery"];
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        itemList.length == 0
            ? Text("Loading")
            : Container(
                height: height - 380,
                child: ListView.builder(
                    itemCount: listHeader.length,
                    itemBuilder: (context, index) {
                      return new StickyHeader(
                          header: new Container(
                            height: 38.0,
                            color: Colors.transparent,
                            padding: new EdgeInsets.symmetric(horizontal: 12.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              listHeader[index],
                              style: const TextStyle(
                                  color: Colors.purple,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          content: Container(
                            color: Colors.white,
                            child: Card(
                              color: Colors.white,
                              child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: itemList.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1,
                                  ),
                                  itemBuilder: (contxt, indx) {
                                    return GestureDetector(
                                      //onTap: ,
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                itemList[indx],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ));
                    }),
              ),
      ],
    );
  }

  @override
  void initState() {
    fdb.once().then((DataSnapshot snap) {
      print(snap);
      var data = snap.value;
      print(data);
      itemList.clear();
      data.forEach((key, value) {
        itemList.add(value['link']);
      });
      setState(() {
        print("value is ");
        print(itemList.length);
      });
    });
    super.initState();
  }
}
