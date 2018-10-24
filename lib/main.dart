import 'dart:async' show StreamSubscription;
import 'dart:io' show File, Platform;
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_database/firebase_database.dart' show Event;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalMaterialLocalizations;
import 'package:ilect_app/catalog.dart';
import 'package:ilect_app/provider.dart';

void main() => runApp(ILectApp());

class ILectApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return DynamicTheme(
      data: (theme) {
        return ThemeData(
          cursorColor: Catalog().defaultColor,
          primaryColor: Colors.white,
          primaryTextTheme: (Platform.isIOS)
              ? null
              : TextTheme(
                  title: TextStyle(fontWeight: FontWeight.w500),
                ),
          textTheme: TextTheme(
            button: TextStyle(fontWeight: FontWeight.w500),
            title: TextStyle(fontWeight: FontWeight.w500),
          ),
        );
      },
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          builder: (context, navigator) => Theme(child: navigator, data: theme),
          home: HomePage(title: ConstantData().title),
          localizationsDelegates: [
            LocalizationsDataDelegate(),
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('th')],
          // This is the theme of your application.
          theme: theme,
          title: ConstantData().title,
        );
      },
    );
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Catalog().feedbackWidget();
}

class HomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State.
  HomePage({Key key, this.title}) : super(key: key);

  // Fields in a Widget subclass are always marked "final".
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class PPPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationData.of(context, Tag.privacy)),
      ),
      body: Scrollbar(
        child: Center(),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  SecondPage({Key key, @required this.category}) : super(key: key);

  final String category;

  @override
  _SecondPageState createState() => _SecondPageState();
}

class SystemInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationData.of(context, Tag.sysinfo)),
      ),
      body: Scrollbar(
        child: ListView(
          children: Catalog().systemInfoList(context),
        ),
      ),
    );
  }
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
        title: Text(LocalizationData.of(context, Tag.service)),
      ),
      body: Scrollbar(
        child: Center(),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<Event> _onIndexSubscription;
  var _items = List<CardData>();

  @override
  void dispose() {
    _onIndexSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Provider().checkInternet(context);
    _onIndexSubscription = Provider()
        .cardDataStreamSubscription(ConstantData().schema0)
        .listen(onIndexAdded);
  }

  // This call to setState tells the Flutter framework that something has
  // changed in this State, which causes it to rerun the build method below
  // so that the display can reflect the updated values. If we changed
  // without calling setState(), then the build method would not be
  // called again, and so nothing would appear to happen.
  void onIndexAdded(Event event) =>
      setState(() => _items.add(CardData.fromSnapshot(event.snapshot)));

  // This method is rerun every time setState is called, for instance as done
  // by the method above.
  // The Flutter framework has been optimized to make rerunning build methods
  // fast, so that you can just rebuild anything that needs updating rather
  // than having to individually change instances of widgets.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: GridView.count(
          children: List.generate(
            _items.length,
            (i) => Catalog().cardWidget(i, _items),
          ),
          crossAxisCount: 2,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
      bottomNavigationBar: Catalog().bottomAppBarExtended(widget.title),
    );
  }
}

class _SecondPageState extends State<SecondPage> {
  StreamSubscription<Event> _onObjectSubscription;
  var _items = List<CardData>();

  @override
  void dispose() {
    _onObjectSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _onObjectSubscription = Provider()
        .cardDataStreamSubscription(Provider().selectSchema(widget.category))
        .listen(onObjectAdded);
  }

  void onObjectAdded(Event event) =>
      setState(() => _items.add(CardData.fromSnapshot(event.snapshot)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: ListView(
          children: List.generate(
            _items.length,
            (i) => Catalog().cardWidget(i, _items),
          ),
          padding: EdgeInsets.only(
            bottom: 6.0,
            left: 4.0,
            right: 4.0,
            top: 20.0,
          ),
        ),
      ),
      bottomNavigationBar: Catalog().bottomAppBar(
        widget.category,
        widget.category,
      ),
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
                  largeTitle: Text(LocalizationData.of(context, Tag.search)),
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
              child: Row(children: Catalog().splitString(false, widget.name)),
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
