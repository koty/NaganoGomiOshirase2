import 'dart:async';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nagano_gomi_oshirase2/notification_scheduler.dart';
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
                      AndroidAlarmManager.cancel(1);
                      setState(() {
                        notifyOnPreviousDay = value;
                      });
                      if (value) {
                        SharedPreferences.getInstance().then((prefs) {
                          NotificationScheduler.register(prefs, TodayPreviousDay.previousDay);
                        });
                      }
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
                            if (picked != null) {
                              SharedPreferences.getInstance().then((prefs) {
                                final hour = picked.hour;
                                final minute = picked.minute;
                                prefs.setInt("previousHour", hour);
                                prefs.setInt("previousMinute", minute);
                                final fhour = f.format(hour);
                                final fminute = f.format(minute);
                                final text = "$fhour:$fminute";
                                if (text != _previousTimeController.text) {
                                  _previousTimeController.text = text;
                                  if (notifyOnPreviousDay) {
                                    AndroidAlarmManager.cancel(1);
                                    SharedPreferences.getInstance().then((
                                        prefs) {
                                      NotificationScheduler.register(
                                          prefs, TodayPreviousDay.previousDay);
                                    });
                                  }
                                }
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
                        prefs.setBool("notifyOnToday", value);
                      });
                      setState(() {
                        notifyOnToday = value;
                      });
                      AndroidAlarmManager.cancel(0);
                      if (value) {
                        SharedPreferences.getInstance().then((prefs) {
                          NotificationScheduler.register(prefs, TodayPreviousDay.today);
                        });
                      }
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
                            if (picked != null) {
                              SharedPreferences.getInstance().then((prefs) {
                                final hour = picked.hour;
                                final minute = picked.minute;
                                prefs.setInt("todayHour", hour);
                                prefs.setInt("todayMinute", minute);
                                final fhour = f.format(hour);
                                final fminute = f.format(minute);
                                final text = "$fhour:$fminute";
                                if (text != _todayTimeController.text) {
                                  _todayTimeController.text = text;
                                  if (notifyOnToday) {
                                    AndroidAlarmManager.cancel(0);
                                    SharedPreferences.getInstance().then((
                                        prefs) {
                                      NotificationScheduler.register(
                                          prefs, TodayPreviousDay.today);
                                    });
                                  }
                                }
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