import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:intl/intl.dart';

class CalendarItem {
  String date;
  String kind;
  bool not_available;
  CalendarItem(this.date, this.kind, this.not_available);
}

class CalendarUtil {
  static Future<Map<String, List<CalendarItem>>> getCalendar() async {
    var response = await http.get("https://b-sw.co/nagano_gomi_calendar/gomi_calendar.json");
    if (response.statusCode == 200) {
      String responseBody = convert.utf8.decode(response.bodyBytes);
      final jsonResponse = convert.jsonDecode(responseBody);
      final o = new Map<String, List<CalendarItem>>();
      final dateFormatter = new DateFormat("yyyy-MM-dd");
      final today = dateFormatter.format(DateTime.now());
      for (var key in jsonResponse.keys) {
        final List<CalendarItem> h = jsonResponse[key]
            .map((x) => new CalendarItem(x['date'], x['kind'], x['not_available']))
            .toList()
            .cast<CalendarItem>();
        h.sort((x, y) => x.date.compareTo(y.date));
        o[key] = h.where((x) => today.compareTo(x.date) <= 0).toList();
      }
      return o;
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    return null;
  }
}