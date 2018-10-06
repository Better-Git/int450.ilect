import 'dart:async' show StreamSubscription;
import 'package:firebase_database/firebase_database.dart' show Event;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;
import 'package:ilect_app/catalog.dart';
import 'package:ilect_app/provider.dart';

void main() => runApp(ILectApp());

class ILectApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      home: HomePage(title: ConstantData().title),
      // This is the theme of your application.
      theme: ThemeData(primaryColor: Colors.white),
      title: ConstantData().title,
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
        title: Text(ConstantData().feedback.substring(5)),
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
        title: Text(ConstantData().pp),
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
        title: Text(ConstantData().tos),
      ),
      body: Center(),
    );
  }
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<Event> _onCategoryAddedSubscription;
  var _items = List<CardData>();

  @override
  void dispose() {
    _onCategoryAddedSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _onCategoryAddedSubscription = Provider()
        .cardDataStreamSubscription(ConstantData().schema0)
        .listen(onCategoryAdded);
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
  StreamSubscription<Event> _onObjectAddedSubscription;
  var _items = List<CardData>();

  @override
  void dispose() {
    _onObjectAddedSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _onObjectAddedSubscription = Provider()
        .cardDataStreamSubscription(Provider().selectSchema(widget.category))
        .listen(onObjectAdded);
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
  @override
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
                  largeTitle: Text(ConstantData().search),
                ),
                SliverSafeArea(
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      Catalog().searchList(widget.category),
                    ),
                  ),
                  top: false,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              child: Row(
                children: <Widget>[
                  Text(
                    widget.name.substring(
                        0, widget.name.lastIndexOf(ConstantData().pattern) + 1),
                    style: Catalog().textStyleSubtitleNonIOS(),
                  ),
                  Text(
                    widget.name.substring(
                        widget.name.lastIndexOf(ConstantData().pattern) + 1),
                    style: Catalog().textStyleSubtitle(),
                  )
                ],
              ),
              padding: EdgeInsets.only(left: 16.0),
            ),
            top: true,
          ),
        ],
      ),
      bottomNavigationBar: Catalog().bottomAppBar(ConstantData().title),
    );
  }
}
