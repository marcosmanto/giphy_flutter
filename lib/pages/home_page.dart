import 'package:flutter/material.dart';
import 'package:giphy_flutter/keys/api_keys.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;

  _getGifs() async {
    Response response;
    if (_search == null) {
      // get trends gifs
      response = await get(
        Uri.parse(
          '${GiphyApi.baseUri}/gifs/trending?api_key=${GiphyApi.key.value}&limit=20&rating=g',
        ),
      );
    } else {
      // there is a search query use search api request
      response = await get(
        Uri.parse(
          '${GiphyApi.baseUri}/gifs/search?api_key=${GiphyApi.key.value}&q=$_search&limit=20&offset=0&rating=g&lang=en',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
