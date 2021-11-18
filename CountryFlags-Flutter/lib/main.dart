import 'dart:convert';

import 'package:flutter/material.dart';
//http package for network calls
import 'package:http/http.dart' as http;

//Create a ModelClass FlagData to store response of the API
class FlagData {
  late bool error; // set bolean variable
  late String msg; // set message variable
  late List<Data> data; // set list of data variable

  FlagData(
      {required this.error,
      required this.msg,
      required this.data}); // flagdata constructor

  //fromJson & toJson function helps in parsing the api data
  FlagData.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    msg = json['msg'];
    if (json['data'] != null) {
      // ignore: deprecated_member_use
      data = new List<Data>.empty(growable: true);
      ;
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  late String name;
  late String unicodeFlag;

  Data({required this.name, required this.unicodeFlag}); // constructor of data

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    unicodeFlag = json['unicodeFlag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['unicodeFlag'] = this.unicodeFlag;
    return data;
  }
}

//calling the api using Future as it is a async func
Future<FlagData> fetchData() async {
  final response = await http.get(
      Uri.parse('https://countriesnow.space/api/v0.1/countries/flag/unicode'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return FlagData.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Flags');
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // disable debaug flag
      title: "Simple Intrest Calculator",
      theme: ThemeData(
          brightness: Brightness.light, // for backgrund color
          primaryColor: Colors.green, //for app bar
          accentColor: Colors.lightGreen //for overscoll edge effect and nobs
          ),
      home: MyApp(),
    ),
  );
}

//create a stateful widget
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<FlagData> futureData;

  @override
  void initState() {
    super.initState();

    futureData = fetchData(); // fetchdata when this widget build
  }

  bool listbutton = true; // set for liatview or gridview conditions

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context)
        .orientation; // here we set orientation for grid view
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Flags'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                listbutton =
                    !listbutton; //here we change listview to gridview or vice-versa
              });
            },
            icon: Icon(
              listbutton
                  ? Icons.list_outlined
                  : Icons
                      .apps_outlined, // here we use ternary experession for icons
            ),
          )
        ],
      ),
      body: Container(
        child: Center(
          child: FutureBuilder(
            // futurebuilder use for collecting data from http responese
            future: futureData, // here we call the function where api calling
            builder: (BuildContext context, AsyncSnapshot<FlagData> snapshot) {
              if (snapshot.hasData) {
                FlagData content = new FlagData(
                    error: snapshot.data!.error,
                    msg: snapshot.data!.msg,
                    data: snapshot.data!.data);
                List<Data> flags = content!.data; // set the data from server

                return listbutton // by condition if listbutton true then its listview else its grid view
                    ? ListView.separated(
                        itemCount: flags.length,
                        separatorBuilder: (context, index) => const Divider(
                              height: 1.0,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 75,
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                flags[index]!.unicodeFlag +
                                    "  " +
                                    flags[index]!.name,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        })
                    : GridView.builder(
                        // for gridview we use grid builder
                        itemCount: flags.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (orientation == Orientation.portrait) ? 2 : 4),
                        itemBuilder: (BuildContext context, int index) {
                          return new Card(
                            child: new GridTile(
                              footer: new Text(
                                flags[index]!.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                              child: new Text(
                                flags[index]!.unicodeFlag,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 100),
                              ), //just for testing, will fill with image later
                            ),
                          );
                        },
                      );
              } else if (snapshot.hasError) {
                print(snapshot);
                return Text('Error');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
