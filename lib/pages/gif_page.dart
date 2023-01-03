import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

const Map gifDataDefault = {
  'title': 'Imagem não encontrada',
  'images': {
    'fixed_height': {
      'url': 'https://media.giphy.com/avatars/default4.gif',
    },
  }
};

class GifPage extends StatelessWidget {
  final Map gifData;

  const GifPage({super.key, this.gifData = gifDataDefault});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        appBar: AppBar(
          title: FittedBox(child: Text(gifData['title'])),
          leadingWidth: 30,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () =>
                    Share.share(gifData['images']['fixed_height']['url']),
                icon: const Icon(Icons.share))
          ],
        ),
        body: Center(
          child: Image.network(gifData['images']['fixed_height']['url']),
        ));
  }
}
