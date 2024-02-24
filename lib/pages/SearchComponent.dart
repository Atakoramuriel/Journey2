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

  void _handleSearch() {
    widget.onSearchSubmit(_controller.text);
    _controller.clear(); // Clear the search bar after submission
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search for places...',
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: _handleSearch,
          ),
        ),
        onSubmitted: (value) => _handleSearch(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
