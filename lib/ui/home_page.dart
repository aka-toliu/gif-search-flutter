import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gif_search/ui/gif_page.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == null || _search!.isEmpty) {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=BgWffskRbwTRRRL7WfgVAXbK9RtBhqBc&limit=20&offset=20&rating=g&bundle=messaging_non_clips"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=BgWffskRbwTRRRL7WfgVAXbK9RtBhqBc&q=$_search&limit=19&offset=$_offset&rating=g&lang=en&bundle=messaging_non_clips"));
    }

    return jsonDecode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Gif Search",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquisar...",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: _getGifs(),
            builder: (context, snapshots) {
              switch (snapshots.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                    alignment: Alignment.center,
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5,
                    ),
                  );
                default:
                  if (snapshots.hasError) {
                    return Container();
                  } else {
                    return _createGifsTable(context, snapshots);
                  }
              }
            },
          ))
        ],
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

  Widget _createGifsTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  height: 300,
                  fit: BoxFit.cover,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"]),

              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(gifData: snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar mais...",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        });
  }
}
