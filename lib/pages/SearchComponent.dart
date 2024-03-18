import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey2/constants.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'SearchComponent.dart';


class SearchComponent extends StatefulWidget {
 final Function(String) onSearchSubmit;


 const SearchComponent({Key? key, required this.onSearchSubmit}) : super(key: key);


 @override
 _SearchComponentState createState() => _SearchComponentState();
}


class _SearchComponentState extends State<SearchComponent> {
 final TextEditingController _controller = TextEditingController();


 @override
 Widget build(BuildContext context) {
   return Container(
     margin: EdgeInsets.all(10),
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(10),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.1),
           blurRadius: 5,
           offset: Offset(0, 2),
         ),
       ],
     ),
     child: Row(
       children: [
         IconButton(
           icon: Icon(Icons.menu),
           onPressed: () {
             // Handle menu button press
           },
         ),
         Expanded(
           child: TextField(
             controller: _controller,
             // ignore: prefer_const_constructors
             decoration: InputDecoration(
               hintText: 'Search here',
               border: InputBorder.none,
               contentPadding: EdgeInsets.symmetric(vertical: 15),
             ),
             onSubmitted: (value) {
               widget.onSearchSubmit(value);
             },
           ),
         ),
         IconButton(
           icon: Icon(Icons.search),
           onPressed: () {
             widget.onSearchSubmit(_controller.text);
           },
         ),
       ],
     ),
   );
 }


 @override
 void dispose() {
   _controller.dispose();
   super.dispose();
 }
}
