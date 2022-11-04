import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'calendar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TodayPreviousDay {
  today,
  previousDay
}


class NotificationScheduler {
  static final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    final initializationSettingsAndroid = AndroidInitializationSettings('trashcan_no_bg');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings).then((value) {
      _registerAlarm();
    });

  }

  static void _registerAlarm() {
    SharedPreferences.getInstance().then((prefs) {
      AndroidAlarmManager.cancel(0);
      AndroidAlarmManager.cancel(1);
      register(prefs, TodayPreviousDay.today);
      register(prefs, TodayPreviousDay.previousDay);
    });
  }
  static void _showTodayNotification() {
    print('_showTodayNotification ' + DateTime.now().toString());
    _showNotification(TodayPreviousDay.today);
  }
  static void _showPreviousDayNotification() {
    print('_showPreviousDayNotification ' + DateTime.now().toString());
    _showNotification(TodayPreviousDay.previousDay);
  }
  static void register(SharedPreferences prefs, TodayPreviousDay todayPrevious) {
    String notifyOnKey;
    String hourKey;
    String minuteKey;
    int defaultHour;
    int alarmId;
    dynamic Function() callback;
    if (todayPrevious == TodayPreviousDay.today) {
      notifyOnKey = "notifyOnToday";
      hourKey = "todayHour";
      minuteKey = "todayMinute";
      alarmId = 0;
      callback = _showTodayNotification;
      defaultHour = 6;
    } else {
      notifyOnKey = "notifyOnPreviousDay";
      hourKey = "previousHour";
      minuteKey = "previousMinute";
      alarmId = 1;
      callback = _showPreviousDayNotification;
      defaultHour = 21;
    }

    final notify = prefs.getBool(notifyOnKey);
    if (notify != true) {
      return;
    }
    final hour = prefs.getInt(hourKey) == null ? defaultHour : prefs.getInt(hourKey);
    final minute = prefs.getInt(minuteKey) == null ? 0 : prefs.getInt(minuteKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, hour!, minute!);
    DateTime runAt;
    if (today.compareTo(now) > 0) {
      // 本日未到来時刻
      runAt = today;
    } else {
      // 本日到来済み時刻なので翌日を指定
      runAt = today.add(Duration(days: 1));
    }
    AndroidAlarmManager
        .oneShotAt(runAt, alarmId, callback, wakeup: true)
        .then((result) {
          print('oneShot result is $result at $runAt. alermId is $alarmId');
        });
  }

  // notification
  static Future _showNotification(TodayPreviousDay todayPrevious) async {
    String titlePrefix;
    String date;
    int notificationId;
    final dateFormatter = new DateFormat("yyyy-MM-dd");
    final now = DateTime.now();
    if (todayPrevious == TodayPreviousDay.today) {
      titlePrefix = "本日";
      date = dateFormatter.format(now);
      notificationId = 0;
    } else {
      titlePrefix = "明日";
      date = dateFormatter.format(now.add(Duration(days: 1)));
      notificationId = 1;
    }
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id $notificationId', 'your channel name',
        importance: Importance.max, priority: Priority.high);
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    final calendars = await CalendarUtil.getCalendar();
    final prefs = await SharedPreferences.getInstance();
    final selectedTown = prefs.getString("selectedTown");
    if (selectedTown == null) {
      NotificationScheduler.register(prefs, todayPrevious);
      return;
    }
    final calendar = calendars[selectedTown];
    final found = calendar!.where((x) => x.date == date).toList();
    if (found.length > 0) {
      final kinds = found.map((x) => x.kind).join(", ");
      String body = '$kindsです。';
      if (found[0].not_available == true) {
        body += 'この日は収集はありません。';
      }
      if (nextIsNotAvailable(calendar, found[0].date)) {
        body += '次回の可燃の収集はお休みです。';
      }
      final title = '$titlePrefixのごみ収集予定';
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: 'no payload',
      );
    }
    // 次回のアラームを登録
    NotificationScheduler.register(prefs, todayPrevious);
  }

  static bool nextIsNotAvailable(List<CalendarItem> calendar, String date) {
    final sameKindItem = calendar.where((x) => x.kind == '可燃').toList();
    for(int i = 0 ; i < sameKindItem.length ; i++) {
      if (sameKindItem[i].date == date) {
        if (i + 1 >= sameKindItem.length) {
          return false;
        }
        return sameKindItem[i + 1].not_available == true;
      }
    }
    return false;
  }
}
