// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:nagano_gomi_oshirase2/calendar_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample for material.AppBar.actions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyStatelessWidget(),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('長野市unofficialゴミ収集カレンダー'),
        /*
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            tooltip: 'Open shopping cart',
            onPressed: () {
              // ...
            },
          ),
        ],
        */
      ),
      body: new AppBody(),
    );
  }
}

class AppBody extends StatelessWidget {

  AppBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
          child: new CalendarPage(),
      ),
    );
  }
}
