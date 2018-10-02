import 'dart:async' show Future, StreamSubscription;
import 'package:firebase_database/firebase_database.dart' show Event;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemChrome, SystemUiOverlayStyle;
import 'package:ilect_app/catalog.dart';
import 'package:ilect_app/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  SecondPage({Key key, @required this.category}) : super(key: key);

  final String category;

  @override
  _SecondPageState createState() => _SecondPageState();
}

class ThirdPage extends StatefulWidget {
  ThirdPage({Key key, @required this.category, @required this.name})
      : super(key: key);

  final String category, name;

  @override
  _ThirdPageState createState() => _ThirdPageState();
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
        Provider().cardDataStreamSubscription(schema0).listen(onCategoryAdded);
  }

  void onCategoryAdded(Event event) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _items.add(CardData.fromSnapshot(event.snapshot));
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
  String _str = '';

  @override
  void dispose() {
    _onObjectAddedSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _items = List();
    switch (widget.category) {
      case eat:
        {
          _str = schema1;
        }
        break;
      case go:
        {
          _str = schema2;
        }
        break;
      case listen:
        {
          _str = schema3;
        }
        break;
      case watch:
        {
          _str = schema4;
        }
        break;
    }
    _onObjectAddedSubscription =
        Provider().cardDataStreamSubscription(_str).listen(onObjectAdded);
  }

  void onObjectAdded(Event event) {
    setState(() {
      _items.add(CardData.fromSnapshot(event.snapshot));
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
      bottomNavigationBar:
          Catalog().bottomAppBar(widget.category, widget.category),
    );
  }
}

class _ThirdPageState extends State<ThirdPage> {
  List<Widget> _items;

  Future _launchBrowser() async {
    List ls = [
      youtubeUrl,
      '%E0%B8%99%E0%B8%B4%E0%B8%97%E0%B8%B2%E0%B8%99'
    ]; // %+UTF-8 URL Encoding
    String url = ls.join();
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget build(BuildContext context) {
    switch (widget.category) {
      case eat:
      case go:
        {
          _items = [
            Catalog().searchListTile(gmapsIcon, gmaps),
            Catalog().searchListDivider(),
            Catalog().searchListTile(amapsIcon, amaps),
            Catalog().searchListDivider(),
            Catalog().searchListTile(chromeIcon, chrome),
            Catalog().searchListDivider(),
            Catalog().searchListTile(safariIcon, safari),
            Catalog().searchListDivider(),
          ];
//          String str = gmapsUrl + widget.name;
//          url = str.substring(0);
        }
        break;
      case listen:
      case watch:
        {
          _items = [
            Catalog().searchListTile(youtubeIcon, youtube),
            Catalog().searchListDivider(),
            Catalog().searchListTile(chromeIcon, chrome),
            Catalog().searchListDivider(),
//            Catalog().searchListTile(safariIcon, safari),
            Material(
              child: InkWell(
                child: Column(
                  children: <Widget>[
                    Container(height: 7.0),
                    ListTile(
                      leading: Image.asset(safariIcon, scale: 3.5),
                      title: Text(safari,
                          style:
                              TextStyle(fontSize: 20.0, letterSpacing: -1.0)),
                      trailing: Icon(
                        CupertinoIcons.forward,
                        color: Color(0xFFC7C7CC),
                        size: 31.0,
                      ),
                    ),
                    Container(height: 7.0),
                  ],
                ),
                onTap: () => setState(() {
                      _launchBrowser();
                    }),
              ),
              type: MaterialType.transparency,
            ),
            Catalog().searchListDivider(),
          ];
//          String str = youtubeUrl + widget.name;
//          url = str;
        }
        break;
    }
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
                SliverSafeArea(
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _items,
                    ),
                  ),
                  top: false,
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Text(
                  widget.name
                      .substring(0, widget.name.lastIndexOf(pattern) + 1),
                  style: Catalog().textStyleSubtitleNonIOS(),
                ),
                Text(
                  widget.name.substring(widget.name.lastIndexOf(pattern) + 1),
                  style: Catalog().textStyleSubtitle(),
                )
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
