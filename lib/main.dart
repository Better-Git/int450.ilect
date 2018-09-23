import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

void main() => runApp(new ILectApp());

class ILectApp extends StatelessWidget {
  final String title = 'iLect';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return new MaterialApp(
      home: new HomePage(
        title: this.title,
      ),
      theme: new ThemeData(
        // This is the theme of your application.
        primaryColor: Colors.white,
      ),
      title: this.title,
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Future<bool> _onHardwareBackPressed() {
    return showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
            actions: <Widget>[
              new FlatButton(
                child: new Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              new FlatButton(
                child: new Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
//                  exit(0);
                textColor: Colors.red,
              ),
            ],
            content: new Text(
                'Are you sure you want to exit iLect?\n\nApp may still be suspended via "Recent Apps"'),
            title: new Text('Confirm Exit'),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new WillPopScope(
      child: new Scaffold(
        body: new Container(
          child: new GridView.count(
            children: new List.generate(4, (i) => new _CategoryCard(i)),
            controller: new ScrollController(keepScrollOffset: false),
            crossAxisCount: 2,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          ),
        ),
//        floatingActionButton: new FloatingActionButton(
//          child: new Icon(Icons.add),
//          onPressed: _incrementCounter,
//          tooltip: 'Increment',
//        ),
//        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: new BottomAppBar(
          child: new Container(
            child: new Row(
              children: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.menu),
                  onPressed: () => showModalBottomSheet<Null>(
                        builder: (BuildContext context) => new _BottomDrawer(),
                        context: context,
                      ),
                ),
                new Text(
                  widget.title,
                  style: Theme.of(context).textTheme.title,
                ),
                new IconButton(
                  icon: new Icon(Icons.share),
                  onPressed: () {
                    Share.share('ฉันได้ใช้แอป iLect แล้วนะ\nอยากจะให้เพื่อนๆมาลองใช้กัน\n\nดาวน์โหลดได้ที่ ...');
                  },
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            decoration: new BoxDecoration(
              border: new Border(
                top: new BorderSide(color: Colors.blue, width: 2.0),
              ),
            ),
          ),
        ),
      ),
      onWillPop: _onHardwareBackPressed,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  _CategoryCard(int i) : _index = i;

  int _index = 0;

  final images = [
    'https://clipartmagic.com/wp-content/uploads/2018/01/free-clip-art-eyes-watching-pc5d4jgei.jpg',
    'https://clipartmagic.com/wp-content/uploads/2018/01/ear-listening-clipart-clipart-of-an-ear-listening.jpg',
    'https://images.clipartuse.com/c4db394b57877fbce47b31c89f73cfa2_hungry-man-clipart-clip-art-library_643-550.png',
    'https://scientiasalon.files.wordpress.com/2015/04/101.jpg',
  ];

  final actions = [
    'ดู',
    'ฟัง',
    'หิว',
    'ไป',
  ];

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Stack(
        children: <Widget>[
          new Positioned.fill(
            child: new Padding(
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    child: new Image.network(images[_index]),
                  ),
                  new Padding(
                    child: new Text(
                      actions[_index],
                      style: TextStyle(fontSize: 30.0),
                    ),
                    padding: new EdgeInsets.only(bottom: 11.0, top: 11.0),
                  ),
                ],
              ),
              padding: new EdgeInsets.only(top: 19.0),
            ),
          ),
          new Positioned.fill(
            child: new Material(
              child: new InkWell(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                onTap: () {},
                splashColor: Color.fromARGB(30, 100, 100, 100),
              ),
              color: Colors.transparent,
            ),
          ),
        ],
      ),
      elevation: 0.5,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(38.0),
        side: new BorderSide(color: Colors.blue, width: 2.0),
      ),
    );
  }
}

class _BottomDrawer extends StatelessWidget {
//  bool _downloaded = false;

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
//          new SwitchListTile(
//            onChanged: (bool value) {
//              (() {
//                _downloaded != value;
//              });
//            },
//            secondary: new Icon(Icons.cloud_off),
//            title: new Text('Offline Pictures'),
//            value: _downloaded,
//          ),
//          new Divider(
//            height: 5.0,
//          ),
        new ListTile(
          onTap: () {},
          title: new Text('Send Feedback'),
        ),
        new Divider(
          height: 5.0,
        ),
        new AboutListTile(
          aboutBoxChildren: [
            new Padding(
                child: new Column(
                  children: <Widget>[
                    new FlatButton(
                      child: new Text('Terms of Service'),
                      onPressed: () {},
                      textColor: Colors.black87,
                    ),
                    new FlatButton(
                      child: new Text('Privacy Policy'),
                      onPressed: () {},
                      textColor: Colors.black87,
                    ),
                  ],
                ),
                padding: new EdgeInsets.only(top: 40.0)),
          ],
          applicationIcon: new Icon(Icons.account_circle),
          applicationLegalese:
              '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
          applicationName: 'iLect',
          applicationVersion: 'version 0.2',
          icon: new Icon(Icons.info_outline),
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}
