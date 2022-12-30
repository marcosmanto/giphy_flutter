import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giphy_flutter/keys/api_keys.dart';
import 'package:http/http.dart';

import '../exceptions/response_server_error.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String? _search = null;
  final int _offset = 0;

  @override
  void initState() {
    super.initState();
    try {
      _getGifs()!.then(
        (map) {
          print(map);
        },
      );
    } catch (e) {
      print('Exception: ${e.toString()}');
    }
  }

  Future<Map>? _getGifs() async {
    final Response response;
    try {
      if (_search == null) {
        // get trends gifs
        response = await get(
          Uri.parse(
            '${GiphyApi.baseUri.value}/gifs/trending?api_key=${GiphyApi.key.value}&limit=20&rating=g',
          ),
        );
      } else {
        // there is a search query use search api request
        response = await get(
          Uri.parse(
            '${GiphyApi.baseUri}/gifs/search?api_key=${GiphyApi.key.value}&q=$_search&limit=20&offset=$_offset&rating=g&lang=en',
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Exception: ${e.toString()}');
      throw ResponseServerError();
    }
    if (response.statusCode >= 400) throw ResponseServerError();
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)),
        ),
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(200),
            child: Container(
              height: 200,
              color: Colors.green,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                        'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif')
                  ]),
            )),
      ),
      body: Container(),
      floatingActionButton: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.add),
          color: Colors.white,
          iconSize: 32,
          onPressed: () {},
        ),
      ),
    );
  }
}
