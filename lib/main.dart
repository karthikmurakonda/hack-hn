import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class Item {
  final int id;
  final String title;
  final String url;

  const Item({required this.id, required this.title, required this.url});

  factory Item.fromJson(Map<String, dynamic> json) {
    if (json['url'] == null){
      return Item(id: json['id'], title: json['title'], url: '');
    }
    return Item(
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Hacker News'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // state is array of items
  List<Item> items = [];

  @override
  void initState() {
    super.initState();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    _fetchData();
  }

  void _fetchData() async {
    final response = await http.get(
        Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      // make api call for each item
      for (int i = 0; i < data.length; i++) {
        final itemResponse = await http.get(Uri.parse(
            'https://hacker-news.firebaseio.com/v0/item/${data[i]}.json'));
        if (itemResponse.statusCode == 200) {
          Map<String, dynamic> itemData = jsonDecode(itemResponse.body);
          Item item = Item.fromJson(itemData);
          setState(() {
            items.add(item);
          });
        }
      }
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index].title),
                subtitle: Text(items[index].url),
                onTap: () {
                  // open in browser
                  launchUrlString(items[index].url);
                },
              );
            },
          ),
        ));
  }
}

Future<http.Response> fetchList() {
  return http
      .get(Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'));
}
