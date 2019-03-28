import 'dart:ui';

import 'package:flutter/services.dart';

/// A Flutter plugin for registering Dart callbacks with the Android
/// AlarmManager service.
///
/// See the example/ directory in this package for sample usage.
class AndroidAlarmManagerCustomWrapper {
  static const String _channelName = 'plugins.flutter.io/android_alarm_manager';
  static const MethodChannel _channel =
  MethodChannel(_channelName, JSONMethodCodec());

  static Future<bool> oneShot(DateTime runAt,
      int id,
      dynamic Function() callback, {
        bool exact = false,
        bool wakeup = false,
        bool rescheduleOnReboot = false,
      }) async {
    final int first = runAt.millisecondsSinceEpoch;
    final CallbackHandle handle = PluginUtilities.getCallbackHandle(callback);
    if (handle == null) {
      return false;
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final dynamic r = await _channel.invokeMethod('Alarm.oneShot', <dynamic>[
      id,
      exact,
      wakeup,
      first,
      rescheduleOnReboot,
      handle.toRawHandle(),
    ]);
    return (r == null) ? false : r;
  }
}