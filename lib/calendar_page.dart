import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);

  CalendarPageState createState() => new CalendarPageState();
}

class CalendarItem {
  String date;
  String kind;
  bool not_available;
  CalendarItem(this.date, this.kind, this.not_available);
}

class CalendarPageState extends State<CalendarPage> {
  CalendarPageState();

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentTown = "";
  Map<String, List<CalendarItem>> _calendars = new Map();

  @override
  void initState() {
    super.initState();
    getDropDownMenuItems().then((val) {
      setState(() {
        _dropDownMenuItems = val;
        _currentTown = _dropDownMenuItems[0].value;
      });
    });
    getCalendar().then((val) {
      setState(() {
        _calendars = val;
      });
    });
  }

  Future<List<DropdownMenuItem<String>>> getDropDownMenuItems() async {
    var response = await http.get("https://b-sw.co/nagano_gomi_calendar/calendar_no_list_withoutbom.json");
    List<DropdownMenuItem<String>> menu = [];
    if (response.statusCode == 200) {
      String responseBody = convert.utf8.decode(response.bodyBytes);
      var jsonResponse = convert.jsonDecode(responseBody);
      for (String key in jsonResponse.keys) {
        final value = jsonResponse[key];
        menu.add(new DropdownMenuItem(value: key, child: Text("${key} ${value}")));
      }
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    return menu;
  }

  Future<Map<String, List<CalendarItem>>> getCalendar() async {
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    final calendar = _calendars.containsKey(_currentTown) ? _calendars[_currentTown] : [];
    for (CalendarItem item in calendar) {
      items.add(new ListTile(title: new Text(item.date)));
    }

    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new DropdownButton(
          value: _currentTown,
          items: _dropDownMenuItems,
          onChanged: changedDropDownItem,
        ),
        new Expanded(
          child: ListView.builder(
            itemCount: calendar.length,
            itemBuilder: (context, int index) {
              final style = calendar[index].not_available == true
                  ? new TextStyle(decoration: TextDecoration.lineThrough, fontSize: 26)
                  : new TextStyle(fontSize: 26);
              return Text(
                "${calendar[index].date} ${calendar[index].kind}",
                style: style,
              );
            }),
        ),
      ],
    );
  }
  void changedDropDownItem(String selectedTown) {
    print("Selected city $selectedTown, we are going to refresh the UI");
    setState(() {
      _currentTown = selectedTown;
    });
  }
}
