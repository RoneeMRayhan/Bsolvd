import 'package:bsolvd/FbStorage/RayStoryView.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class NavigationBar extends StatefulWidget {
  NavigationBar({Key key}) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _currentIndex = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text("Video"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xee33ff00), Color(0xff99ff00)],
            stops: [0.5, 1.0],
          )),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 55,
        index: _currentIndex,
        color: Colors.limeAccent[700],
        backgroundColor: Colors.grey,
        key: _bottomNavigationKey,
        items: <Widget>[
          Icon(
            Icons.image,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.video_library,
            size: 30,
            color: Colors.white,
          ),
          Icon(
            Icons.compare_arrows,
            size: 30,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (value) {
            setState(() => _currentIndex = value);
          },
          children: <Widget>[
            RayStoryView(),
            RayStoryView(),
            RayStoryView(),
          ],
        ),
      ),
    );
  }
}
