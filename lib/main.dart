import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterapp1/info.dart';
import 'package:flutterapp1/widgets.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "/",
      routes: {
        "/add": (context) => VactionAdd(),
        "/": (context) => VactionList(),
        "/detail": (context) => VacationDetail(),
      },
    );
  }
}

class VactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VactionListState();
  }
}

class _VactionListState extends State<VactionList> {
  var list = [];
  var firstLoad = true;

  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      firstLoad = false;
      var params = {
        "page": "1",
        "limit": "10",
        "userid": Info.userId,
        "orgno": Info.orgNo
      };
      Info.post("getMyLeaveList", params).then((value) {
        print(value);
        setState(() {
          list = value["rows"];
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("休假申请"),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Icon(Icons.add),
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, "/add");
            },
          ),
        ],
      ),
      body: Center(
          child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                Widget widget = Container(
                    decoration: BoxDecoration(
                        border:
                            Border(bottom: BorderSide(color: Colors.black12))),
                    padding: EdgeInsets.all(5),
                    child: FlatButton(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            textDirection: TextDirection.rtl,
                            children: <Widget>[
                              Text(item["leavetime"]),
                              Expanded(
                                child: Text(item["leavename"]),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Text(item["approvenode"]),
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/detail",
                            arguments: {"pkvalue": item["leaveno"]});
                      },
                    ));
                return widget;
              })),
    );
  }
}

class VactionAdd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VactionAddReal real = VactionAddReal();

    return Scaffold(
      appBar: AppBar(
        title: Text("新建休假申请"),
        centerTitle: true,
      ),
      body: real,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          real.addNewChildItem();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class VactionAddReal extends StatefulWidget {
  _VactionAddState  state = _VactionAddState();

  @override
  State<StatefulWidget> createState() {
    return state;
  }

  addNewChildItem() {
    state.addNewChildItem();
  }
}

class _VactionAddState extends State<VactionAddReal> {
  var firstLoad = true;

  String name, typeNo, typeName, periodNo, periodName;
  var total = "0", left = "0", used = "0";

  var child = [
    {
      "leavestarttime": "",
      "leaveendtime": "",
      "leavedays": "",
      "leavereason": "",
      "worktransfer": "",
      "worktransferName": "",
      "phonenum": "",
    },
  ];

  var leavetype = [];
  var checkperiod = [];

  @override
  Widget build(BuildContext context) {
    print("_VactionAddState build");
    var widgets = [
      CustomWidgets.getDiv(),
      CustomWidgets.getInput("休假单名称", name, (str) {
        name = str;
      }),
      CustomWidgets.getSelect("休假类别", typeName, () {
        CustomWidgets.showPop(context, leavetype, "NAME", (item) {
          setState(() {
            typeName = item["NAME"];
            typeNo = item["ID"];
          });
          _getLeaveDays();
        });
      }),
      CustomWidgets.getSelect("考勤周期", periodName, () {
        CustomWidgets.showPop(context, checkperiod, "NAME", (item) {
          setState(() {
            periodName = item["NAME"];
            periodNo = item["ID"];
          });
          _getLeaveDays();
        });
      }),
      CustomWidgets.getCircle(total, left, used),
    ];
    for (var i = 0; i < child.length; i++) {
      var e = child[i];
      var count = i + 1;
      widgets.add(Column(children: <Widget>[
        CustomWidgets.getDiv(),
        CustomWidgets.getChildTitle("休假明细($count)"),
        CustomWidgets.getSelect("开始时间", e["leavestarttime"], () {
          DatePicker.showDatePicker(context,pickerMode: DateTimePickerMode.datetime, onConfirm:(dateTime,selectedIndex){
            setState(() {
              e["leavestarttime"]=dateTime.toIso8601String().replaceAll("T", " ").replaceAll(".000", "");
            });
          });
        }),
        CustomWidgets.getSelect("结束时间", e["leaveendtime"], () {
          DatePicker.showDatePicker(context,pickerMode: DateTimePickerMode.datetime, onConfirm:(dateTime,selectedIndex){
            setState(() {
              e["leaveendtime"]=dateTime.toIso8601String().replaceAll("T", " ").replaceAll(".000", "");
            });
          });
        }),
        CustomWidgets.getInput("休假天数", e["leavedays"], (str) {
          e["leavedays"] = str;
        }),
        CustomWidgets.getInput("休假事由", e["leavereason"], (str) {
          e["leavereason"] = str;
        }),
        CustomWidgets.getSelect("工作交接人", e["worktransferName"], () async {
          var result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return SelectPeople();
          }));
          setState(() {
            e["worktransferName"] = result["name"];
            e["worktransfer"] = result["no"];
          });
        }),
        CustomWidgets.getInput("联系方式", e["phonenum"], (str) {
          e["phonenum"] = str;
        }),
      ]));
    }

    if (firstLoad) {
      firstLoad = false;
      Info.post("getLeaveTypeAndCheckPeriodList",
          {"userid": Info.userId, "orgno": Info.orgNo}).then((resp) {
        this.leavetype = resp["leavetype"];
        this.checkperiod = resp["checkperiod"];
      });
    }

    return ListView(
      children: widgets,
    );
  }

  addNewChildItem() {
    setState(() {
      child.add({
        "leavestarttime": "",
        "leaveendtime": "",
        "leavedays": "",
        "leavereason": "",
        "worktransfer": "",
        "worktransferName": "",
        "phonenum": "",
      });
    });
  }

  _getLeaveDays() {
    if (typeNo == null || periodNo == null) {
      return;
    }

    Info.post("getLeaveDays", {
      "userid": Info.userId,
      "orgno": Info.orgNo,
      "leavetype": typeNo,
      "checkperiod": periodNo,
    }).then((resp) {
      print(resp);
      setState(() {
        total = resp["currentperioddays"];
        left = resp["lefttotaldays"];
        used = resp["useddays"];
      });
    });
  }
}

class VacationDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VacationDetailState();
  }
}

class _VacationDetailState extends State<VacationDetail> {
  String pkvalue;

  var cirlcles = ["0", "0", "0"];

  var content = [];

  var per = {"leavetype": "年假", "checkperiod": "2020年考勤期间"};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (pkvalue == null) {
      Map args = ModalRoute.of(context).settings.arguments;
      pkvalue = args["pkvalue"];

      var params = {"leaveno": pkvalue};
      Info.post("getLeaveInfo", params).then((value) {
        print(value);
        setState(() {
          _setData(value["info"]);
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("休假申请详情"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.black12,
                  width: 10,
                ),
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
            ),
            height: 50,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  per["leavetype"],
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 16),
                ),
                Text(
                  per["checkperiod"],
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 16),
                ),
              ],
            ),
          ),
          CustomWidgets.getCircle(cirlcles[0], cirlcles[1], cirlcles[2]),
          Column(
            children: content.map((e) {
              if (e["type"] == 0) {
                return CustomWidgets.getDiv();
              } else if (e["type"] == 1) {
                return CustomWidgets.getDetailItem(e["label"], e["text"]);
              } else {
                return CustomWidgets.getChildTitle(e["label"]);
              }
            }).toList(),
          )
        ],
      ),
    );
  }

  void _setData(dynamic info) {
    this.cirlcles[0] = info["leavetotaldays"];
    this.cirlcles[1] = info["leaveleft"];
    this.cirlcles[2] = info["leaveused"];
    // 主表
    this.content = [];
    this.content.add({"type": 0});
    this.content.add({"type": 1, "label": "编号：", "text": info["leaveid"]});
    this.content.add({"type": 1, "label": "状态：", "text": info["status"]});
    this.content.add({"type": 1, "label": "休假单名称：", "text": info["leavename"]});
    this.content.add({"type": 1, "label": "申请日期：", "text": info["leavetime"]});
    String a;
    for (var i = 0; i < info["leaves"].length; i++) {
      var count = i + 1;
      var item = info["leaves"][i];
      this.content.add({"type": 0});
      this.content.add({"type": 2, "label": "休假明细($count)"});
      this
          .content
          .add({"type": 1, "label": "开始时间：", "text": item["leavestarttime"]});
      this
          .content
          .add({"type": 1, "label": "结束时间：", "text": item["leaveendtime"]});
      this
          .content
          .add({"type": 1, "label": "休假天数：", "text": item["leavedays"]});
      this
          .content
          .add({"type": 1, "label": "休假事由：", "text": item["leavereason"]});
      this
          .content
          .add({"type": 1, "label": "工作交接人：", "text": item["worktransfer"]});
      this.content.add({"type": 1, "label": "假期电话：", "text": item["phonenum"]});
    }
  }
}

class SelectPeople extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("选择人员"),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return FlatButton(
                child: Text("胡礼飞$index"),
                onPressed: () {
                  Navigator.pop(context, {"name": "胡礼飞", "no": "HULIFEI"});
                },
              );
            }));
  }
}

