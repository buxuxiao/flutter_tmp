import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterapp1/info.dart';
import 'package:flutterapp1/widgets.dart';

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

class VactionAdd extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VactionAddState();
  }
}

class _VactionAddState extends State<VactionAdd> {
  var firstLoad = true;

  String name, typeNo, typeName, periodNo, periodName;
  var total = "0", left = "0", used = "0";

  var child = [
    {
      "leavestarttime": "2020-12-12 12:12",
      "leaveendtime": "2020-11-12 12:12",
      "leavedays": "2",
      "leavereason": "回家吃饭",
      "worktransfer": "SYS",
      "worktransferName": "系统管理员",
      "phonenum": "1234567890",
    },
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
        CustomWidgets.getSelect("开始时间", e["leavestarttime"], () {}),
        CustomWidgets.getSelect("结束时间", e["leaveendtime"], () {}),
        CustomWidgets.getInput("休假天数", e["leavedays"], (str) {}),
        CustomWidgets.getInput("休假事由", e["leavereason"], (str) {}),
        CustomWidgets.getSelect("工作交接人", e["worktransferName"], () {}),
        CustomWidgets.getInput("联系方式", e["phonenum"], (str) {}),
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

    return Scaffold(
      appBar: AppBar(
        title: Text("新建休假申请"),
        centerTitle: true,
      ),
      body: ListView(
        children: widgets,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewChildItem();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
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

/****************************************************/

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Wrap(
          children: <Widget>[
            Text(
              'You have click button times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            FlatButton(
              child: Text('jump new route11'),
              textColor: Colors.blue,
              onPressed: () {
                Navigator.pushNamed(context, "new_page", arguments: "hello");
              },
            ),
            FlatButton(
              child: Text("scaffold"),
              onPressed: () async {
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (build) {
                  return ScaffoldRoute();
                }));

              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Route extends StatelessWidget {
  _onPressed() {}

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments;
    print("1234567890");
    print(args);
    return Scaffold(
        appBar: AppBar(
          title: Text('hello'),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "用户名",
                  hintText: "用户名或邮箱",
                  prefixIcon: Icon(Icons.person)),
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "您的登录密码",
                  prefixIcon: Icon(Icons.lock)),
              obscureText: true,
            ),
          ],
        ));
  }
}

class ParentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ParentWidget();
  }
}

class _ParentWidget extends State<ParentWidget> {
  bool _active = false;

  _handleTap(newValue) {
    setState(() {
      _active = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BoxB(active: _active, valueChanged: _handleTap),
    );
  }
}

class BoxB extends StatefulWidget {
  BoxB({Key key, @required this.active, @required this.valueChanged})
      : super(key: key);

  bool active;
  ValueChanged<bool> valueChanged;

  @override
  State<StatefulWidget> createState() {
    return _BoxBState();
  }
}

class _BoxBState extends State<BoxB> {
  bool isDown = false;

  _handlTapState(state) {
    setState(() {
      isDown = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.valueChanged(!widget.active);
        },
        onTapDown: (d) {
          _handlTapState(true);
        },
        onTapUp: (d) {
          _handlTapState(false);
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
              color: widget.active ? Colors.green : Colors.grey,
              border: isDown ? Border.all(color: Colors.red, width: 10) : null),
        ));
  }
}

class ScaffoldRoute extends StatefulWidget {
  @override
  _ScaffoldRouteState createState() => _ScaffoldRouteState();
}

class _ScaffoldRouteState extends State<ScaffoldRoute> {
  int _selectedIndex = 1;
  String str = "AQWERTYUIOPLKJJHGFDSAZXCCVBNM";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //导航栏
        title: Text("App Name"),
        actions: <Widget>[
          //导航栏右侧菜单
          IconButton(icon: Icon(Icons.share), onPressed: () {}),
        ],
      ),
      //  drawer: new MyDrawer(), //抽屉
      bottomNavigationBar: BottomNavigationBar(
        // 底部导航
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.business), title: Text('Business')),
          BottomNavigationBarItem(
              icon: Icon(Icons.school), title: Text('School')),
        ],
        currentIndex: _selectedIndex,
        fixedColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
          //悬浮按钮
          child: Icon(Icons.add),
          onPressed: _onAdd),
      body: Scrollbar(
        child: SingleChildScrollView(
            child: Center(
          child: Column(
            children: str
                .split("")
                //每一个字母都用一个Text显示,字体为原来的两倍
                .map((c) => Text(
                      c,
                      textScaleFactor: 2.0,
                    ))
                .toList(),
          ),
        )),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAdd() {}
}
