import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:giphy_flutter/keys/api_keys.dart';
import 'package:giphy_flutter/utils/clear_focus.dart';
import 'package:http/http.dart';

import '../exceptions/response_server_error.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  final int _offset = 0;

  /*@override
  void initState() {
    super.initState();

    _getGifs()!.then(
      (map) {
        print(map);
      },
    ).catchError((e) => print('Exception: ${e.toString()}'));
  }*/

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
            '${GiphyApi.baseUri.value}/gifs/search?api_key=${GiphyApi.key.value}&q=$_search&limit=20&offset=$_offset&rating=g&lang=en',
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Exception: ${e.toString()}');
      throw ResponseServerError();
    }
    if (response.statusCode >= 400) throw ResponseServerError();
    //await Future.delayed(Duration(seconds: 3));
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return ClearFocus(
      child: Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          centerTitle: true,
          elevation: 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25)),
          ),
          toolbarHeight: 0,
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                        'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif',
                        width: MediaQuery.of(context).size.width),
                  ],
                ),
              )),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'Pesquise por um GIF'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
              onSubmitted: (text) => setState(() => _search = text),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro ao carregar as imagens.',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 18),
                        ),
                      );
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          )
        ]),
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
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot<Map> snapshot) {
    return GridView.builder(
      itemCount: snapshot.data!['data'].length,
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => GestureDetector(
        child: Image.network(
          snapshot.data!['data'][index]['images']['fixed_height']['url'],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
