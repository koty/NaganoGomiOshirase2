import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencePage extends StatefulWidget {
  @override
  _PreferencePageState createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  TimeOfDay previousTime;
  TimeOfDay todayTime;
  bool notifyOnPreviousDay = false;
  bool notifyOnToday = false;
  final TextEditingController _previousTimeController = new TextEditingController();
  final TextEditingController _todayTimeController = new TextEditingController();
  final f = new NumberFormat("00");

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((SharedPreferences prefs) {
          setState(() {
            notifyOnPreviousDay = getBool(prefs, "notifyOnPreviousDay", false);
            notifyOnToday = getBool(prefs, "notifyOnToday", true);
            previousTime = TimeOfDay(hour: getInt(prefs, "previousHour", 21),
                                     minute: getInt(prefs, "previousMinute", 0));
            todayTime = TimeOfDay(hour: getInt(prefs, "todayHour", 6),
                minute: getInt(prefs, "todayMinute", 0));
            final previousHour = f.format(previousTime.hour);
            final previousMinute = f.format(previousTime.minute);
            _previousTimeController.text = "$previousHour:$previousMinute";
            final todayHour = f.format(todayTime.hour);
            final todayMinute = f.format(todayTime.minute);
            _todayTimeController.text = "$todayHour:$todayMinute";
          });
    });
  }

  static bool getBool(SharedPreferences prefs, String key, bool defaultValue) {
    final val = prefs.getBool(key);
    if (val == null) {
      return defaultValue;
    }
    return val;
  }
  static int getInt(SharedPreferences prefs, String key, int defaultValue) {
    final val = prefs.getInt(key);
    if (val == null) {
      return defaultValue;
    }
    return val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                ButtonBar(
                  children: <Widget>[
                    Checkbox(value: notifyOnPreviousDay, onChanged: (value) {
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setBool("notifyOnPreviousDay", value);
                      });
                      setState(() {
                        notifyOnPreviousDay = value;
                      });
                    },),
                    Text("前日に通知する"),
                    Container(
                      width: 50,
                      child: TextField(
                        controller: _previousTimeController,
                        onTap: () {
                          showTimePicker(
                            context: context,
                            initialTime: previousTime,
                          ).then((picked){
                            if (picked != null && picked != previousTime) {
                              SharedPreferences.getInstance().then((prefs) {
                                final hour = picked.hour;
                                final minute = picked.minute;
                                prefs.setInt("previousHour", hour);
                                prefs.setInt("previousMinute", minute);
                                final fhour = f.format(hour);
                                final fminute = f.format(minute);
                                _previousTimeController.text = "$fhour:$fminute";
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                ButtonBar(
                  children: <Widget>[
                    Checkbox(value: notifyOnToday, onChanged: (value) {
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setBool("notifyOnDoday", value);
                      });
                      setState(() {
                        notifyOnToday = value;
                      });
                    },),
                    Text("当日に通知する"),
                    Container(
                      width: 50,
                      child: TextField(
                        controller: _todayTimeController,
                        onTap: () {
                          showTimePicker(
                            context: context,
                            initialTime: todayTime,
                          ).then((picked){
                            if (picked != null && picked != todayTime) {
                              SharedPreferences.getInstance().then((prefs) {
                                final hour = picked.hour;
                                final minute = picked.minute;
                                prefs.setInt("todayHour", hour);
                                prefs.setInt("todayMinute", minute);
                                final fhour = f.format(hour);
                                final fminute = f.format(minute);
                                _todayTimeController.text = "$fhour:$fminute";
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        )
      ),
    );
  }
}

class SharedPreferencesHelper {
  ///
  /// Instantiation of the SharedPreferences library
  ///
  static final String _kLanguageCode = "language";

  /// ------------------------------------------------------------
  /// Method that returns the user language code, 'en' if not set
  /// ------------------------------------------------------------
  static Future<String> getLanguageCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_kLanguageCode) ?? 'en';
  }

  /// ----------------------------------------------------------
  /// Method that saves the user language code
  /// ----------------------------------------------------------
  static Future<bool> setLanguageCode(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(_kLanguageCode, value);
  }
}