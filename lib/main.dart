// Copyright 2018 School of Information Technology, KMUTT. All rights reserved.

import 'dart:async' show Timer;

import 'package:async/async.dart' show StreamZip;
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_database/firebase_database.dart' show Event;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalMaterialLocalizations;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'catalog.dart';
import 'provider.dart';

void main() => runApp(ILectApp());

class ILectApp extends StatelessWidget {
  // This widget is the application root.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return DynamicTheme(
      data: (_) => ProviderThemeData().theme,
      themedWidgetBuilder: (_, theme) {
        return MaterialApp(
          builder: (_, widget) => Theme(child: widget, data: theme),
          debugShowCheckedModeBanner: false,
          home: HomePage(),
          localizationsDelegates: [
            LocalizationDataDelegate(),
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('th')],
          theme: theme,
          title: ConstantData().title,
        );
      },
    );
  }
}

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Catalog().feedbackWidget();
}

class HomePage extends StatefulWidget {
  // (This comment originated from New Flutter Project... template.)
  //
  // This widget is stateful, meaning that it has a State object (defined below)
  // that can contain fields that affect how it looks.
  // This class is the configuration for the state. It can hold the values
  // provided by the parent and used by the build method of the State.
  static bool canShowSnackBar = false;
  static var list = List<CardData>();

  @override
  _HomePageState createState() => _HomePageState();
}

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocalizationData.of(context, Tag.privacy))),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            child: Text(LocalizationData.of(context, Tag.privacy0)),
            padding: EdgeInsets.all(10.0),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  SecondPage({Key key, @required this.category}) : super(key: key);

  final String category;
  static final slidableController = SlidableController();

  @override
  _SecondPageState createState() => _SecondPageState();
}

class ServiceTermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocalizationData.of(context, Tag.service))),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            child: Text(LocalizationData.of(context, Tag.service0)),
            padding: EdgeInsets.all(10.0),
          ),
        ),
      ),
    );
  }
}

class SystemInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocalizationData.of(context, Tag.sysinfo))),
      body: Scrollbar(
        child: ListView(children: Catalog().toSystemInfoListTile(context)),
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

class _FavoritePageState extends State<FavoritePage> {
  List<CardData> _indices = HomePage.list;
  var _objects = List<List<CardData>>(), _streams = List<Stream<Event>>();

  @override
  void initState() {
    super.initState();
    _indices.forEach(
      (index) => _streams.add(Provider().cardDataStream(index.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        builder: (_, snapshot) {
          if (Catalog().favoriteList().isNotEmpty && snapshot.hasData) {
            var _streamList = List<Event>.from(snapshot?.data ?? []);
            if (_streamList.isNotEmpty) {
              var _discardedIndexList = List(),
                  _objectList = List<List<CardData>>();
              _indices.forEach((index) {
                if (Catalog().favoriteList().every((item) {
                  return index.name != item[0];
                })) _discardedIndexList.add(_indices.indexOf(index));
              });
              if (_discardedIndexList.isNotEmpty) {
                _discardedIndexList.reversed.forEach((index) {
                  if (index < _streams.length && index < _streamList.length) {
                    _streams.removeAt(index);
                    _streamList.removeAt(index);
                  }
                  _indices.removeAt(index);
                });
              }
              _streamList.forEach((stream) {
                int _index = 0;
                List _list = stream?.snapshot?.value ?? [];
                if (_list.isNotEmpty) {
                  var _cardDataList = List<CardData>(),
                      _eventList = List<CardData>();
                  _list = _list.sublist(1);
                  _list.forEach((item) {
                    _eventList.add(CardData.fromMap(_index, Map.from(item)));
                    _index++;
                  });
                  _eventList.forEach((snapshot) {
                    if (Catalog().favoriteList().any((item) {
                      return (snapshot.name ?? snapshot.keyword) == item[1];
                    })) _cardDataList.add(snapshot);
                  });
                  if (_cardDataList.isNotEmpty) _objectList.add(_cardDataList);
                }
              });
              if (_indices.length == _objectList.length) _objects = _objectList;
            }
          }
          return (Catalog().favoriteList().isEmpty || !snapshot.hasData)
              ? Catalog().infoWidget(true, snapshot, Catalog().favoriteList())
              : Column(
                  children: <Widget>[
                    SafeArea(child: Catalog().favoriteInfoRow(), top: true),
                    Expanded(
                      child: Scrollbar(
                        child: CustomScrollView(
                          slivers: List.generate(
                            _indices.length,
                            (i) {
                              return SliverStickyHeader(
                                header: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              _indices[i].name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline,
                                            ),
                                            color: Colors.white,
                                            height: 55.0,
                                            padding: EdgeInsets.all(13.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: ConstantData().dividerColor,
                                      height: 1.0,
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                                sliver: SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 3.0,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildListDelegate(
                                      List.generate(
                                        _objects[i].length,
                                        (j) {
                                          return Padding(
                                            child: Catalog().cardWidget(
                                              j,
                                              _objects[i],
                                              this,
                                              _indices[i].name,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 2.0,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        },
        stream: StreamZip(_streams),
      ),
      bottomNavigationBar: Catalog().bottomAppBar(
        LocalizationData.of(context, Tag.favorite),
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Provider().checkInternet(context);
  }

  // (This comment originated from New Flutter Project... template.)
  //
  // This method is rerun every time setState() is called, which tells the
  // Flutter framework that something has changed in this State so that the
  // display can reflect the updated values. If we changed without calling
  // setState(), then build() would not be called again, and so nothing would
  // appear to happen.
  //
  // The Flutter framework has been optimized to make rerunning build methods
  // fast, so that you can just rebuild anything that needs updating rather
  // than having to individually change instances of widgets.
  @override
  Widget build(BuildContext context) {
    Catalog().readFavoriteValue();
    if (HomePage.canShowSnackBar) {
      Timer(
        Duration(milliseconds: 500),
        () {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(LocalizationData.of(context, Tag.snackbar)),
          ));
        },
      );
      HomePage.canShowSnackBar = false;
    }
    return Scaffold(
      body: StreamBuilder(
        builder: (_, snapshot) {
          Catalog().readCardDataList(snapshot, HomePage.list);
          return (HomePage.list.isEmpty || !snapshot.hasData)
              ? Catalog().infoWidget(false, snapshot, HomePage.list)
              : SafeArea(
                  child: Scrollbar(
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverPadding(
                          padding:
                              EdgeInsets.only(left: 4.0, right: 4.0, top: 2.0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              <Widget>[Catalog().favoriteButton()],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                            bottom: 6.0,
                            left: 4.0,
                            right: 4.0,
                          ),
                          sliver: SliverGrid.count(
                            children: List.generate(
                              HomePage.list.length,
                              (i) => Catalog().cardWidget(i, HomePage.list),
                            ),
                            crossAxisCount: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  top: true,
                );
        },
        stream: Provider().cardDataStream(),
      ),
      bottomNavigationBar: Catalog().bottomAppBarOverride(ConstantData().title),
      key: _scaffoldKey,
    );
  }
}

class _SecondPageState extends State<SecondPage> {
  var _list = List<CardData>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        builder: (_, snapshot) {
          Catalog().readCardDataList(snapshot, _list);
          return (_list.isEmpty || !snapshot.hasData)
              ? Catalog().infoWidget(false, snapshot, _list)
              : SafeArea(
                  child: Scrollbar(
                    child: ListView(
                      children: List.generate(
                        _list.length,
                        (i) => Catalog()
                            .cardWidget(i, _list, this, widget.category),
                      ),
                      padding: EdgeInsets.only(
                        bottom: 6.0,
                        left: 4.0,
                        right: 4.0,
                        top: 4.0,
                      ),
                    ),
                  ),
                  top: true,
                );
        },
        stream: Provider().cardDataStream(widget.category),
      ),
      bottomNavigationBar: Catalog().bottomAppBar(widget.category),
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
                      Catalog().searchList(this, widget.category),
                    ),
                  ),
                  top: false,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              child: Row(children: Catalog().toSplitString(false, widget.name)),
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
