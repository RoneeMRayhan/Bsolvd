import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class NavigationBar extends StatefulWidget {
  NavigationBar({Key key}) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: GradientAppBar(
         title: Text(
           "Video"
         ),
         flexibleSpace: Container(
           decoration: BoxDecoration(
             gradient: LinearGradient(
               colors: [Color(0xee33ff00), Color(0xff99ff00)], stops: [0.5,1.0],
             )
           ),
         ),
       ),
    );
  }
}