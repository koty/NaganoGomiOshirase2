import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class CalendarPage extends StatefulWidget {
  CalendarPage({Key key}) : super(key: key);

  CalendarPageState createState() => new CalendarPageState();
}

class CalendarItem {
  String date;
  String kind;
  bool not_available;
}

class CalendarPageState extends State<CalendarPage> {
  CalendarPageState();

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentTown = "";
  Map<String, List<CalendarItem>> _calendars = null;

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
      _calendars = val;
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
        // print('$key, $value');
        menu.add(new DropdownMenuItem(value: value, child: Text("${key} ${value}")));
      }
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    return menu;
  }

  Future<Map<String, List<CalendarItem>>> getCalendar() async {
    var response = await http.get("https://b-sw.co/nagano_gomi_calendar/gomi_calendar.json");
    List<DropdownMenuItem<String>> menu = [];
    if (response.statusCode == 200) {
      String responseBody = convert.utf8.decode(response.bodyBytes);
       final jsonResponse = convert.jsonDecode(responseBody);
       return jsonResponse;
    } else {
      print("Request failed with status: ${response.statusCode}.");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    for (CalendarItem item in _calendars[_currentTown]) {
      items.add(new ListTile(title: new Text(item.date)));
    }
    return Stack(
      children: <Widget>[
        new DropdownButton(
          value: _currentTown,
          items: _dropDownMenuItems,
          onChanged: changedDropDownItem,
        ),
        items,
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
