// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nagano_gomi_oshirase2/calendar_page.dart';
import 'package:nagano_gomi_oshirase2/preference.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  // This widget is the root of your application.
  MyApp() {
    final initializationSettingsAndroid = new AndroidInitializationSettings('gomi_icon');
    final initializationSettingsIOS = new IOSInitializationSettings();
    final initializationSettings = new InitializationSettings(
        initializationSettingsAndroid,
        initializationSettingsIOS
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _showNotification();
  }
  // notification
  Future _showNotification() async {
    final time = new Time(13, 18, 0);
    final androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    final iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    final platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      '4Timer',
      '5You should check the app',
      time,
      platformChannelSpecifics,
      payload: '6Default_Sound',
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('長野市unofficialゴミ収集カレンダー'),
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
