// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:nagano_gomi_oshirase2/calendar_page.dart';
import 'package:nagano_gomi_oshirase2/notification_scheduler.dart';
import 'package:nagano_gomi_oshirase2/preference.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MyApp() {
    AndroidAlarmManager.initialize();
    NotificationScheduler.initialize();
  }

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
    final textStyle = TextStyle(fontSize: 19);
    return Scaffold(
      appBar: AppBar(
        title: Text('長野市unofficialごみ収集カレンダー', style: textStyle),
        actions: <Widget>[
          IconButton(
            icon: new Image.asset("assets/icons/preference.png"),
            tooltip: 'Open shopping cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PreferencePage()),
              );
            },
          ),
        ],
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
