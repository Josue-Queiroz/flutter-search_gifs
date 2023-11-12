import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_search_giphys/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const apiKey = 'uqIF6ZrXwLkOKQeUFhIUd3u6NlnTBz09';
  static const urlRequest = 'api.giphy.com';

  int limit = 25;
  int offset = 0;
  String lang = 'en';
  String search = '';

  Future<Map> getGifs() async {
    var client = http.Client();
    if (search.isNotEmpty) {
      http.Response response = await client.get(
        Uri.https(
          urlRequest,
          'v1/gifs/search',
          {
            'api_key': apiKey,
            'q': search.toString(),
            'limit': limit.toString(),
            'offset': offset.toString(),
            'rating': 'g',
            'lang': lang,
            'bundle': 'messaging_non_clips'
          },
        ),
      );
      return json.decode(response.body);
    } else {
      http.Response response = await client.get(
        Uri.https(urlRequest, '/v1/gifs/trending', {
          'api_key': apiKey,
          'limit': limit.toString(),
          'offset': offset.toString(),
          'rating': 'g',
          'bundle': 'messaging_non_clips',
        }),
      );
      return json.decode(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    getGifs().then((value) {
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                  labelText: "Pesquisar",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  search = text;
                  offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      height: 200,
                      width: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    }
                    return createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int getCount(List data) {
    if (search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data['data'][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        } else {
          return GestureDetector(
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 70),
                Text(
                  "Carregar Mais",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                offset += 19;
              });
            },
          );
        }
      },
    );
  }
}
