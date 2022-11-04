import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert' as convert;
import 'calendar_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({Key? key}) : super(key: key);

  CalendarPageState createState() => new CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  CalendarPageState();

  List<DropdownMenuItem<String>> _dropDownMenuItems = [];
  String _currentTown = "";
  Map<String, List<CalendarItem>> _calendars = new Map();

  @override
  void initState() {
    super.initState();
    getDropDownMenuItems().then((val) {
      SharedPreferences.getInstance().then((prefs) {
        final selectedTown = prefs.getString("selectedTown");
        setState(() {
          _dropDownMenuItems = val;
          _currentTown = (selectedTown == null ? _dropDownMenuItems[0].value : selectedTown)!;
        });
      });
    });
    CalendarUtil.getCalendar().then((val) {
      setState(() {
        _calendars = val;
      });
    });
  }

  Future<List<DropdownMenuItem<String>>> getDropDownMenuItems() async {
    var response = await http.get(Uri.parse("https://b-sw.co/nagano_gomi_calendar/calendar_no_list_withoutbom.json"));
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    final calendar = _calendars.containsKey(_currentTown) ? _calendars[_currentTown] : [];
    for (CalendarItem item in calendar!) {
      items.add(new ListTile(title: new Text(item.date)));
    }
    final width = MediaQuery.of(context).size.width;
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
              final rawDate = DateTime.parse(calendar[index].date);
              final formatter = new DateFormat('M/d');
              final weekdayNames = ['日', '月', '火', '水', '木', '金', '土'];
              final formattedDate = formatter.format(rawDate); // DateからString
              return Padding(
                padding: EdgeInsets.only(left: 10),
                child:  Text(
                  "${formattedDate}(${weekdayNames[rawDate.weekday]}) ${calendar[index].kind}",
                  style: style,
                )
              );
            }),
        ),
      ],
    );
  }

  void changedDropDownItem(String? selectedTown) {
    print("Selected city $selectedTown, we are going to refresh the UI");
    setState(() {
      _currentTown = selectedTown!;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("selectedTown", selectedTown!);
    });
  }
}
