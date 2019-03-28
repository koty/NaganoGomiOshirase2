import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:nagano_gomi_oshirase2/android_alarm_manager_custom_wrapper.dart';
import 'package:nagano_gomi_oshirase2/calendar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TodayPreviousDay {
  today,
  previousDay
}


class NotificationScheduler {
  static final flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  static void initialize() {
    final initializationSettingsAndroid = new AndroidInitializationSettings('trashcan_no_bg');
    final initializationSettingsIOS = new IOSInitializationSettings();
    final initializationSettings = new InitializationSettings(
        initializationSettingsAndroid,
        initializationSettingsIOS
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
    print('_showTodayNotification');
    _showNotification(TodayPreviousDay.today);
  }
  static void _showPreviousDayNotification() {
    print('_showPreviousDayNotification');
    _showNotification(TodayPreviousDay.previousDay);
  }
  static void register(SharedPreferences prefs, TodayPreviousDay todayPrevious) {
    String notifyOnKey;
    String hourKey;
    String minuteKey;
    int alarmId;
    Function callback;
    if (todayPrevious == TodayPreviousDay.today) {
      notifyOnKey = "notifyOnToday";
      hourKey = "todayHour";
      minuteKey = "todayMinute";
      alarmId = 0;
      callback = _showTodayNotification;
    } else {
      notifyOnKey = "notifyOnPreviousDay";
      hourKey = "previousHour";
      minuteKey = "previousMinute";
      alarmId = 1;
      callback = _showPreviousDayNotification;
    }

    final notify = prefs.getBool(notifyOnKey);
    if (notify != true) {
      return;
    }
    final hour = prefs.getInt(hourKey);
    final minute = prefs.getInt(minuteKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    DateTime runAt;
    if (today.compareTo(now) > 0) {
      // 本日未到来時刻
      runAt = today;
    } else {
      // 本日到来済み時刻なので翌日を指定
      runAt = today.add(Duration(days: 1));
    }
    AndroidAlarmManagerCustomWrapper
        .oneShot(runAt, alarmId, callback, wakeup: true)
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
    final androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id $notificationId', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    final iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    final platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    final calendars = await CalendarUtil.getCalendar();
    final prefs = await SharedPreferences.getInstance();
    final selectedTown = prefs.getString("selectedTown");
    if (selectedTown == null) {
      NotificationScheduler.register(prefs, todayPrevious);
      return;
    }
    final calendar = calendars[selectedTown];
    calendar.add(CalendarItem("2019-03-28", "28日のごみ■", false));
    calendar.add(CalendarItem("2019-03-29", "29日のごみ★", false));
    final found = calendar.where((x) => x.date == date).toList();
    if (found.length > 0) {
      final kinds = found.map((x) => x.kind).join(", ");
      String body = '$kindsです';
      if (found[0].not_available == true) {
        body += 'がこの日は収集はありません。';
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
}
