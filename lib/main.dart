import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> fetchPost() async {
  final response = await http.get(
      'https://api.thecatapi.com/api/images/get?format=json&results_per_page=1');
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return CatImage.fromJson(json.decode(response.body)).url;
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load json from url');
  }
}

class CatImage {
  String url;
  CatImage({this.url});
  factory CatImage.fromJson(List<dynamic> json) {
    return CatImage(url: json[0]["url"]);
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  Future<String> _cat;

  @override
  initState() {
    super.initState();

    setState(() {
      try {
        _cat = fetchPost();
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("CatAPI showcase"),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      setState(() {
                        try {
                          _cat = fetchPost();
                        } catch (e) {
                          print(e);
                        }
                      });
                    },
                    child: FutureBuilder<String>(
                      future: _cat,
                      builder: (ctx, snapshot) {
                        if (snapshot.hasData) {
                          return Image.network(
                            snapshot.data,
                            fit: BoxFit.contain,
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    )),
              ],
            )));
  }
}
