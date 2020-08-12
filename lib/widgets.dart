import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomWidgets {
  static Widget getDiv() {
    return Container(
      height: 10,
      color: Colors.black12,
    );
  }

  static Widget getInput(label, value, watcher) {
    if (value == null) {
      value = "";
    }
    return Container(
      height: 45,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12))),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: <Widget>[
          Text(label),
          Expanded(
            child: TextField(
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 14),
              onChanged: watcher,
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                hintText: "请输入" + label,
                hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                border: UnderlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget getSelect(label, value, click) {
    if (value == null || value.length == 0) {
      value = "请选择" + label;
    }
    return Container(
      height: 45,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12))),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: <Widget>[
          Text(label),
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.all(0),
              child: Row(
                textDirection: TextDirection.rtl,
                children: <Widget>[
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black26,
                    size: 20,
                  ),
                  Text(value),
                ],
              ),
              onPressed: click,
            ),
          )
        ],
      ),
    );
  }

  static Widget getCircle(num1, num2, num3) {
    var cirlcles = [
      {"num": num1, "label": "享有天数", "color": Colors.red},
      {"num": num2, "label": "结余天数", "color": Colors.green},
      {"num": num3, "label": "已休天数", "color": Colors.blue},
    ];

    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: cirlcles.map((e) {
          return Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: e["color"], width: 2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        e["num"].toString(),
                        style: TextStyle(
                          color: e["color"],
                          fontSize: 30,
                        ),
                      ),
                    )),
                Text(
                  e["label"].toString(),
                  style: TextStyle(color: Colors.black45),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget getChildTitle(title) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12))),
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      alignment: Alignment.centerLeft,
      height: 40,
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
      ),
    );
  }

  static Widget getDetailItem(label, text) {
    return Container(
      height: 35,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(text),
          )
        ],
      ),
    );
  }

  static showPop(BuildContext context, List<dynamic> arr, key, click) {
    Scaffold.of(context).showBottomSheet<void>((BuildContext context) {
      return Container(
        constraints: BoxConstraints(maxHeight: 300),
        child: ListView(
          children: arr.map((e) {
            return FlatButton(
              child: Text(e[key]),
              onPressed: () {
                click(e);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
    });
  }
}
