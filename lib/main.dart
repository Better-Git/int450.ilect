import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ilect_app/catalog.dart';
import 'package:ilect_app/provider.dart';

void main() => runApp(new ILectApp());

class ILectApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      home: HomePage(title: title),
      // This is the theme of your application.
      theme: ThemeData(primaryColor: Colors.white),
      title: title,
    );
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {},
          ),
        ],
        title: Text(feedback.substring(5)),
      ),
      body: Center(),
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
  _HomePageState createState() => _HomePageState();
}

class PPPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pp),
      ),
      body: Center(),
    );
  }
}

class SecondPage extends StatefulWidget {
  SecondPage({Key key, @required this.categoryName}) : super(key: key);

  final String categoryName;

  @override
  _SecondPageState createState() => _SecondPageState();
}

class ThirdPage extends StatelessWidget {
  ThirdPage({Key key, @required this.name}) : super(key: key);

  final String name;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CupertinoPageScaffold(
            child: CustomScrollView(
              physics: NeverScrollableScrollPhysics(),
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  largeTitle: Text(search),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          child: Column(
                            children: <Widget>[
                              Container(height: 7.0),
                              ListTile(
                                leading: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/YouTube_full-color_icon_%282017%29.svg/200px-YouTube_full-color_icon_%282017%29.svg.png',
                                  scale: 3.0,
                                ),
                                title: Text(
                                  'YouTube',
                                  style: TextStyle(
                                      fontSize: 20.0, letterSpacing: -1.0),
                                ),
                              ),
                              Container(height: 7.0),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute<void>(
                              builder: (BuildContext context) => ToSPage(),
                            ));
                          },
                        ),
                      ),
                      Divider(height: 5.0),
                      ListTile(
                        title: Text('(408) 555-1212',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        leading: Icon(
                          Icons.contact_phone,
                          color: Colors.blue[500],
                        ),
                        onTap: () {},
                      ),
                      ListTile(
                        title: Text('costa@example.com'),
                        leading: Icon(
                          Icons.contact_mail,
                          color: Colors.blue[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                        color: CupertinoColors.inactiveGray,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
                Container(height: 78.0),
                Column(
                  children: <Widget>[],
                ),
              ],
            ),
            padding: EdgeInsets.only(left: 16.0, top: 31.0),
          ),
        ],
      ),
      bottomNavigationBar: Catalog().bottomAppBar(title),
    );
  }
}

class ToSPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tos),
      ),
      body: Center(),
    );
  }
}

class _HomePageState extends State<HomePage> {
  List<CardData> _items;
  StreamSubscription<Event> _onCategoryAddedSubscription;

  @override
  void dispose() {
    _onCategoryAddedSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _items = List();
    _onCategoryAddedSubscription =
        Provider().cardDataStreamSubscription(category).listen(onCategoryAdded);
  }

  void onCategoryAdded(Event event) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _items.add(CardData.fromSnapshot(false, event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Container(
        child: GridView.count(
          children: List.generate(
              _items.length, (i) => Catalog().categoryCard(i, _items)),
          controller: ScrollController(keepScrollOffset: false),
          crossAxisCount: 2,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
        ),
      ),
      bottomNavigationBar: Catalog().bottomAppBarExtended(true, widget.title),
    );
  }
}

class _SecondPageState extends State<SecondPage> {
  List<CardData> _items;
  StreamSubscription<Event> _onObjectAddedSubscription;
  String str = '';

  @override
  void dispose() {
    _onObjectAddedSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _items = List();
    switch (widget.categoryName) {
      case 'ดู':
        {
          str = 'looking';
        }
        break;
      case 'ฟัง':
        {
          str = 'listen';
        }
        break;
      case 'หิว':
        {
          str = 'Hungry';
        }
        break;
      case 'ไป':
        {
          str = 'go';
        }
        break;
    }
    _onObjectAddedSubscription =
        Provider().cardDataStreamSubscription(str).listen(onObjectAdded);
  }

  void onObjectAdded(Event event) {
    setState(() {
      _items.add(CardData.fromSnapshot(true, event.snapshot));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: List.generate(
              _items.length, (i) => Catalog().objectCard(i, _items)),
        ),
      ),
      bottomNavigationBar: Catalog().bottomAppBar(widget.categoryName),
    );
  }
}
