// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:giphy_flutter/keys/api_keys.dart';
import 'package:giphy_flutter/pages/gif_page.dart';
import 'package:giphy_flutter/utils/clear_focus.dart';
import 'package:http/http.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

import '../exceptions/response_server_error.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FocusNode searchFocus = FocusNode();
  final TextEditingController searchController = TextEditingController();

  AsyncMemoizer? _memoizer = AsyncMemoizer();
  String? _search;
  int _offset = 0;
  bool _searchChanged = false;

  @override
  void initState() {
    super.initState();
    searchController.text = _search ?? '';
  }

  /*@override
  void initState() {
    super.initState();

    _getGifs()!.then(
      (map) {
        print(map);
      },
    ).catchError((e) => print('Exception: ${e.toString()}'));
  }*/

  _getGifs() {
    return _memoizer?.runOnce(
      () async {
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
                '${GiphyApi.baseUri.value}/gifs/search?api_key=${GiphyApi.key.value}&q=$_search&limit=19&offset=$_offset&rating=g&lang=en',
              ),
            );
          }
        } catch (e) {
          print('Exception: ${e.toString()}');
          throw ResponseServerError();
        }
        if (response.statusCode >= 400) throw ResponseServerError();
        //await Future.delayed(Duration(seconds: 3));
        print('Requesting gifs...');
        return json.decode(response.body);
      },
    );
  }

  /*Future<Map>? _getGifs() async {
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
            '${GiphyApi.baseUri.value}/gifs/search?api_key=${GiphyApi.key.value}&q=$_search&limit=19&offset=$_offset&rating=g&lang=en',
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
    print('Requesting gifs...');
    return json.decode(response.body);
  }*/

  @override
  Widget build(BuildContext context) {
    return ClearFocus(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
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
              preferredSize: const Size.fromHeight(100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
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
                      //width: MediaQuery.of(context).size.width,
                    ),
                  ],
                ),
              )),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Flexible(
                  flex: 5,
                  child: TextField(
                    controller: searchController,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    focusNode: searchFocus,
                    decoration: const InputDecoration(
                      labelText: 'Pesquise por um GIF',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                    onSubmitted: onSubmit,
                    onChanged: onChanged,
                  ),
                ),
                if (searchController.text.trim().isNotEmpty) ...[
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 61,
                    height: 61,
                    child: _searchChanged &&
                            searchController.text.trim().isNotEmpty
                        ? ElevatedButton(
                            onPressed: () => onSubmit(searchController.text),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            child: const Icon(
                              Icons.search,
                              size: 32,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: onReset,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              backgroundColor: Colors.red,
                            ),
                            child: const Icon(
                              Icons.cancel,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                  )
                ]
              ],
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
        /*floatingActionButton: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.add),
            color: Colors.white,
            iconSize: 32,
            onPressed: () {},
          ),
        ),*/
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.data!['data'].length == 0) {
      return Center(
        child: Text(
          _offset == 0
              ? 'Não existem gifs para a consulta "$_search"'
              : 'Todos os gifs de "$_search" foram exibidos.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 18,
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          GridView.builder(
              itemCount: _getCount(snapshot.data!['data']),
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                // if not searching all items will be images OR
                // if searching all be images except last one.
                if (_search == null || index < snapshot.data!['data'].length) {
                  return GestureDetector(
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: snapshot.data!['data'][index]['images']
                          ['fixed_height']['url'],
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GifPage(
                            gifData: snapshot.data!['data'][index],
                          ),
                        ),
                      );
                    },
                    onLongPress: () => Share.share(snapshot.data!['data'][index]
                        ['images']['fixed_height']['url']),
                  );
                } else {
                  return GestureDetector(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            radius: 35,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            child: const Icon(
                              Icons.add,
                              color: Colors.black38,
                              size: 70,
                            )),
                        const SizedBox(height: 10),
                        const Text(
                          'Carregar \nmais...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    onTap: () => setState(() {
                      _offset += 19;
                      _memoizer = AsyncMemoizer();
                    }),
                  );
                }
              }),
          /*Text(
            'Search changed: $_searchChanged\nSearch: $_search',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),*/
          if (_search != null)
            if (_search!.trim().isNotEmpty)
              Align(
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: .70,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Página ${(_offset / 19 + 1).toInt().toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),
        ],
      );
    }
  }

  void onSubmit(String text) {
    final String submitedText = text.trim();

    // search was cleared
    if (_search != null) {
      if (submitedText.isEmpty && _search!.isNotEmpty) {
        setState(() => _search = null);
        return;
      }
    }

    // avoid submit when empty field or search text not changed
    if (submitedText.isEmpty || submitedText == _search) return;
    print('new search started...');
    setState(() {
      _searchChanged = false;
      _memoizer = AsyncMemoizer();
      // reset page counter
      _offset = 0;
      _search = submitedText;
    });
    //searchFocus.requestFocus();
  }

  void onChanged(String text) {
    final search = text.trim();

    if (search != _search) {
      setState(() => _searchChanged = true);
    } else {
      setState(() => _searchChanged = false);
    }
  }

  void onReset() {
    searchController.clear();
    setState(() {
      _search = null;
      _searchChanged = false;
      _offset = 0;
      _memoizer = AsyncMemoizer();
    });
  }
}
