import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
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
import 'location_service.dart';
import 'autocomplete_prediction.dart';

class SearchComponent extends StatefulWidget {
  final Function(String, String) onSearchSubmit;

  const SearchComponent({Key? key, required this.onSearchSubmit}) : super(key: key);

  @override
  _SearchComponentState createState() => _SearchComponentState();
}

class _SearchComponentState extends State<SearchComponent> {
  final TextEditingController _controller = TextEditingController();
  List<AutocompletePrediction> _predictions = [];

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
      child: Column(
        children: [
          Row(
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
                  decoration: InputDecoration(
                    hintText: 'Search here',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: (value) {
                    _getAutocompleteSuggestions(value);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  widget.onSearchSubmit('', _controller.text);
                },
              ),
            ],
          ),
          if (_predictions.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_predictions[index].description),
                  onTap: () {
                    _controller.text = _predictions[index].description;
                    widget.onSearchSubmit(_predictions[index].placeId, _predictions[index].description);
                    _predictions = [];
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  void _getAutocompleteSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyCnsAxexDsIn6jzg3AcmxYT9v559SAp4mE';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    if (json['status'] == 'OK') {
      var predictions = json['predictions'] as List<dynamic>;
      setState(() {
        _predictions = predictions
            .map((prediction) => AutocompletePrediction.fromJson(prediction))
            .toList();
      });
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}