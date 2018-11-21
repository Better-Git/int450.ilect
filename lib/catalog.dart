// Copyright 2018 School of Information Technology, KMUTT. All rights reserved.

import 'dart:async' show Timer;
import 'dart:io' show File, Platform;
import 'dart:math' show max;

import 'package:battery/battery.dart';
import 'package:collection/collection.dart';
import 'package:device_info/device_info.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart' show HomePage, SecondPage;
import 'provider.dart';

String _query;

class Catalog {
  List _systemInfoList(BuildContext context) =>
      _SystemInfoListTileState.override()._systemInfoDynamicList(context);

  List favoriteList() => _CardWidget._favorites;

  List<Widget> searchList(parent, String category) {
    _SearchListTile._category = category;
    _SearchListTile._parent = parent;
    return _SearchListTile.override()._searchListTileDynamicList();
  }

  List<Widget> toSplitString(bool isCard, String message) {
    List<String> _listString = message.split(' ');
    var _listText = List<Widget>();
    for (int _i = 0; _i < _listString.length; _i++) {
      _listText.add(
        Text(
          _listString[_i],
          style: (_listString[_i].contains(ConstantData().thaiPattern))
              ? (isCard) ? _textStyleCard(false) : _textStyleSubtitleTH()
              : (isCard)
                  ? TextStyle(
                      fontSize: 30.0,
                      letterSpacing: (!Platform.isIOS) ? null : -1.0,
                    )
                  : _textStyleSubtitle(),
        ),
      );
      if (_i < _listString.length - 1) {
        _listText.add(
          Text(
            (isCard)
                ? String.fromCharCode(0x00A0) + String.fromCharCode(0x00A0)
                : String.fromCharCode(0x00A0),
          ),
        );
      }
    }
    return _listText;
  }

  List<Widget> toSystemInfoListTile(BuildContext context) {
    var _items = List<Widget>(), _list = _systemInfoList(context);
    for (var _item in _list) {
      _items.add(_SystemInfoListTile(content: _item, context: context));
    }
    return _items;
  }

  TextStyle _textStyleBottomAppBar(BuildContext context, String message) {
    return (!Platform.isIOS ||
            (message == ConstantData().title) ||
            (message == ConstantData().favoriteButton0))
        ? Theme.of(context).textTheme.title
        : TextStyle(
            fontFamily: ConstantData().font,
            fontSize: 30.0,
            height: 1.5,
          );
  }

  TextStyle _textStyleCard(bool isHomePage) {
    return (!Platform.isIOS)
        ? TextStyle(fontSize: 30.0)
        : (isHomePage)
            ? TextStyle(
                fontFamily: ConstantData().font,
                fontSize: 40.0,
                height: 1.2,
              ) // _IndexCard
            : TextStyle(
                fontFamily: ConstantData().font,
                fontSize: 44.25,
                height: 1.55,
              ); // _ObjectCard
  }

  TextStyle _textStyleSubtitle() {
    return TextStyle(
      color: CupertinoColors.inactiveGray,
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.4,
    );
  }

  TextStyle _textStyleSubtitleTH() {
    return TextStyle(
      color: CupertinoColors.inactiveGray,
      fontFamily: ConstantData().font,
      fontSize: 26.0,
      fontWeight: FontWeight.bold,
      height: 1.45,
    );
  }

  Widget _backIcon() =>
      (!Platform.isIOS) ? Icon(Icons.arrow_back) : Icon(Icons.arrow_back_ios);

  Widget bottomAppBar(String title) => _BottomAppBar(title);

  Widget bottomAppBarOverride(String title) => _BottomAppBar.override(title);

  Widget cardWidget(int i, List list, [parent, String category]) =>
      _CardWidget(i, list, parent, category);

  Widget favoriteButton() => _FavoriteButton();

  Widget favoriteInfoRow() => _FavoriteInfoRow();

  Widget feedbackWidget() => _FeedbackWidget();

  Widget infoWidget(bool isFavoritePage, AsyncSnapshot snapshot, List list) =>
      _InfoWidget(isFavoritePage, snapshot, list);

  void _cursorColor(BuildContext context, Color color) =>
      DynamicTheme.of(context).setThemeData(ProviderThemeData(color).theme);

  void _showAlertErrorDialog(BuildContext context, String content,
      [bool isSearchAlert]) {
    (!Platform.isIOS)
        ? showDialog(
            builder: (_) => _ErrorDialog(content),
            context: context,
          )
        : showCupertinoDialog(
            builder: (context) {
              return (isSearchAlert ?? true)
                  ? _SearchAlertDialog(context, content)
                  : _ErrorDialog(content);
            },
            context: context,
          );
  }

  void readCardDataList(AsyncSnapshot snapshot, List list) =>
      _CardWidget._readCardDataList(snapshot, list);

  void readFavoriteValue() => _CardWidget._readFavoriteValue();

  void showWarningDialog(BuildContext context, String content,
      {bool override, bool dismissible, String title}) {
    (!Platform.isIOS || (override ?? false))
        ? showDialog(
            barrierDismissible: (dismissible ?? false) ? true : false,
            builder: (_) {
              return (override ?? false)
                  ? _ErrorDialog.override(content)
                  : _ErrorDialog.extend(content, title);
            },
            context: context,
          )
        : showCupertinoDialog(
            builder: (_) => _ErrorDialog.extend(content, title),
            context: context,
          );
  }
}

class _BottomAppBar extends StatelessWidget {
  _BottomAppBar(String title)
      : _isOverridden = false,
        _title = title;
  _BottomAppBar.override(String title)
      : _isOverridden = true,
        _title = title;

  final bool _isOverridden;
  final String _title;

  void _share(BuildContext context) {
    Share.share(LocalizationData.of(context, Tag.share));
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Material(
        child: Container(
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  showRoundedModalBottomSheet(
                    builder: (_) => _BottomDrawer(),
                    color: Colors.white,
                    context: context,
                    radius: 20.0,
                  );
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
              (_isOverridden || (_title != ConstantData().title))
                  ? Text(
                      _title,
                      style: Catalog()._textStyleBottomAppBar(context, _title),
                    )
                  : Tooltip(
                      child: FlatButton(
                        child: Text(
                          _title,
                          style:
                              Catalog()._textStyleBottomAppBar(context, _title),
                        ),
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                            ModalRoute.withName(Navigator.defaultRouteName),
                          );
                        },
                        padding: EdgeInsets.all(11.5),
                        shape: StadiumBorder(),
                      ),
                      message: LocalizationData.of(context, Tag.tooltip0),
                    ),
              (_isOverridden)
                  ? IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () => _share(context),
                      tooltip: LocalizationData.of(context, Tag.tooltip1),
                    )
                  : IconButton(
                      icon: Catalog()._backIcon(),
                      onPressed: () => Navigator.pop(context),
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                    ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.blue, width: 2.0)),
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}

class _BottomDrawer extends StatelessWidget {
//  static bool _offline = false;

  _onWillPop(BuildContext context) {
    Navigator.pop(context);
    Timer(
      Duration(milliseconds: 305),
      () => FlutterStatusbarcolor.setStatusBarColor(Colors.white),
    );
    return Future<bool>.value(false);
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return WillPopScope(
      child: Material(
        child: Column(
          children: <Widget>[
//            SwitchListTile(
//              onChanged: (value) => _offline = value,
//              secondary: Icon(Icons.cloud_off),
//              title: Text(LocalizationData.of(context, Tag.offline)),
//              value: _offline,
//            ),
//            Divider(height: 1.0),
            ListTile(
              onTap: () {
                Catalog()._systemInfoList(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConstantData().feedbackPage,
                  ),
                );
              },
              title: Text(LocalizationData.of(context, Tag.feedback)),
            ),
            Divider(height: 1.0),
            AboutListTile(
              aboutBoxChildren: [
                Padding(
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                        child: Text(LocalizationData.of(context, Tag.service)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConstantData().servicePage,
                            ),
                          );
                        },
                        textColor: Colors.black87,
                      ),
                      FlatButton(
                        child: Text(LocalizationData.of(context, Tag.privacy)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConstantData().privacyPage,
                            ),
                          );
                        },
                        textColor: Colors.black87,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(top: 40.0),
                ),
              ],
              applicationIcon:
                  Image.asset(ConstantData().ilectIcon, scale: 6.5),
              applicationLegalese: LocalizationData.of(context, Tag.copyright),
              applicationName: ConstantData().title,
              applicationVersion: ConstantData().version,
              icon: Icon(Icons.info_outline),
            ),
            Divider(height: 1.0),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      onWillPop: () => _onWillPop(context),
    );
  }
}

class _CardWidget extends StatelessWidget {
  _CardWidget(int i, List list, [parent, String category])
      : _parent = parent,
        _index = i,
        _items = list,
        _category = category;

  final _parent;
  final int _index;
  final List<CardData> _items;
  final String _category;
  static var _favorites = List(),
      _keys = List<GlobalObjectKey<SlidableState>>();

  static void _readCardDataList(AsyncSnapshot snapshot, List list) {
    if (snapshot.hasData) {
      int _index = 0;
      List _list = snapshot?.data?.snapshot?.value ?? [];
      list.clear();
      if (_list.isNotEmpty) {
        _list = _list.sublist(1);
        _list.forEach((item) {
          list.add(CardData.fromMap(_index, Map.from(item)));
          _index++;
        });
      }
    }
  }

  static void _readFavoriteValue() async {
    var _prefs = await SharedPreferences.getInstance();
    _prefs.getKeys().forEach((key) {
      if (_favorites.length < _prefs.getKeys().length) {
        _favorites.add(_prefs.getStringList(key));
      }
    });
  }

  _readFavoriteKey() async {
    var _nums = List<int>(), _prefs = await SharedPreferences.getInstance();
    int _lastIndex = -1;
    if (_prefs.getKeys().isNotEmpty) {
      _prefs.getKeys().forEach((key) {
        if (key.contains('${Tag.favorite}')) {
          _nums.add(int.parse(key.substring(12)));
        }
      });
    }
    if (_nums.isNotEmpty) _lastIndex = _nums.reduce(max);
    return Future<int>.value(_lastIndex + 1);
  }

  Widget _buildCardWidget(bool isHomePage) {
    String _text = _items[_index].name ?? _items[_index].keyword;
    return Card(
      child: Stack(
        children: <Widget>[
          (isHomePage)
              ? Positioned.fill(
                  child: Padding(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Image.network(
                            Provider().createImageUrl(_items[_index]),
                          ),
                        ),
                        Padding(
                          child: Text(
                            _items[_index].name,
                            style: Catalog()._textStyleCard(true),
                          ),
                          padding: EdgeInsets.only(bottom: 11.0, top: 11.0),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.only(top: 19.0),
                  ),
                ) // IndexCard
              : Padding(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        child: Image.network(
                          Provider().createImageUrl(_items[_index], _category),
                        ),
                        padding: EdgeInsets.only(
                          bottom: 15.0,
                          left: 16.0,
                          right: 16.0,
                          top: 18.0,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (_, size) {
                          TextPainter _overflowTextPainter = TextPainter(
                            maxLines: 1,
                            text: TextSpan(
                              style: Catalog()._textStyleCard(false),
                              text: _text,
                            ),
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.ltr,
                          );
                          Widget _title = Row(
                            children: Catalog().toSplitString(true, _text),
                            mainAxisAlignment: MainAxisAlignment.center,
                          );
                          _overflowTextPainter.layout(maxWidth: size.maxWidth);
                          return (!_overflowTextPainter.didExceedMaxLines)
                              ? _title
                              : _MarqueeWidget(
                                  child: Row(
                                    children: <Widget>[
                                      _title,
                                      Container(width: 30.0),
                                      _title,
                                    ],
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(15.0),
                ), // ObjectCard
          _RippleCardEffect(
            (isHomePage) ? _items[_index].name : _items[_index].keyword,
            _category,
          ),
        ],
      ),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(38.0),
        side: BorderSide(color: Colors.blue, width: 2.0),
      ),
    );
  }

  void _insertFavoriteKeyValue(String name) async {
    var _prefs = await SharedPreferences.getInstance();
    int _i = await _readFavoriteKey();
    bool _listEqual(String key) =>
        ListEquality().equals(_prefs.getStringList(key), [_category, name]);
    (_prefs.getKeys().any((key) => _listEqual(key)))
        ? _prefs.remove(_prefs.getKeys().where((key) => _listEqual(key)).join())
        : _prefs.setStringList('${Tag.favorite}$_i', [_category, name]);
    _favorites.clear();
    Timer(
      Duration(milliseconds: 250),
      () {
        _parent.setState(() {
          _prefs.getKeys().forEach((key) {
            _favorites.add(_prefs.getStringList(key));
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _hasCategory = _category?.trim()?.isNotEmpty ?? false,
        _isAdded = _favorites.any((item) {
      return (item[0] == _category) &&
          (item[1] == _items[_index].name ?? _items[_index].keyword);
    });
    var _slidableKey = GlobalObjectKey<SlidableState>(_items[_index].token);
    if (_hasCategory) {
      _keys.clear();
      _items.forEach((item) {
        if (_keys.length < _items.length) {
          _keys.add(GlobalObjectKey<SlidableState>(item.token));
        }
      });
    }
    return (!_hasCategory)
        ? _buildCardWidget(true)
        : Slidable(
            actionExtentRatio: 0.25,
            child: _buildCardWidget(false),
            controller: SecondPage.slidableController,
            delegate: SlidableDrawerDelegate(),
            key: _slidableKey,
            secondaryActions: <Widget>[
              Stack(
                children: <Widget>[
                  IconSlideAction(
                    caption: ((_isAdded)
                            ? LocalizationData.of(context, Tag.favorite1)
                            : LocalizationData.of(context, Tag.favorite2)) +
                        LocalizationData.of(context, Tag.favorite),
                    color: (_isAdded) ? Colors.grey[200] : Colors.amber[400],
                    icon: (_isAdded) ? Icons.star_border : Icons.star,
                  ),
                  Positioned.fill(
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          _insertFavoriteKeyValue(
                            _items[_index].name ?? _items[_index].keyword,
                          );
                          _slidableKey.currentState.close();
                        },
                        splashColor: Colors.transparent,
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}

class _ConfirmDialog extends StatelessWidget {
  _ConfirmDialog(BuildContext context, String content, String url)
      : _context = context,
        _content = content,
        _url = url;

  final BuildContext _context;
  final String _content, _url;

  String _selectToastMessage() {
    String _message = LocalizationData.of(_context, Tag.toast);
    switch (_content) {
      case ConstantData.gmaps:
      case ConstantData.youtube:
        _message += _content;
        break;
    }
    return _message;
  }

  @override
  Widget build(BuildContext context) {
    String _open = LocalizationData.of(_context, Tag.toast).trim(),
        _title = LocalizationData.of(_context, Tag.search) +
            ((!Platform.isIOS) ? ' \"$_content\"?' : ' \“$_content\”?');
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return AlertDialog(
      actions: (!Platform.isIOS)
          ? <Widget>[
              FlatButton(
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
                onPressed: () => _BottomDrawer()._onWillPop(context),
              ),
              FlatButton(
                child: Text(_open.toUpperCase()),
                onPressed: () {
                  _SearchListTile.override()._launchUrl(
                    _context,
                    _url,
                    message: _selectToastMessage(),
                  );
                  _BottomDrawer()._onWillPop(context);
                },
              ),
            ]
          : <Widget>[
              CupertinoButton(
                child: Text(
                  (!Provider().isEN(context))
                      ? MaterialLocalizations.of(context).cancelButtonLabel
                      : 'Cancel',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                  ),
                ),
                onPressed: () => _BottomDrawer()._onWillPop(context),
                padding: EdgeInsets.symmetric(horizontal: 6.0),
              ),
              CupertinoButton(
                child: Text(
                  _open,
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                onPressed: () {
                  _SearchListTile.override()._launchUrl(
                    _context,
                    _url,
                    forceSafariVC: false,
                  );
                  _BottomDrawer()._onWillPop(context);
                },
              ),
            ],
      content: Text(
        _title,
        style: (!Platform.isIOS)
            ? null
            : TextStyle(
                color: Colors.black,
                fontSize: 17.0,
                letterSpacing: -0.5,
              ),
      ),
      contentPadding: (!Platform.isIOS)
          ? EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0)
          : EdgeInsets.only(left: 19.5, top: 18.0),
      shape: (!Platform.isIOS)
          ? null
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  _ErrorDialog(String content)
      : _isExtended = false,
        _isOverridden = false,
        _content = content,
        _title = '';
  _ErrorDialog.extend(String content, String title)
      : _isExtended = true,
        _isOverridden = false,
        _content = content,
        _title = title;
  _ErrorDialog.override(String content)
      : _isExtended = true,
        _isOverridden = true,
        _content = content,
        _title = '';

  final bool _isExtended, _isOverridden;
  final String _content, _title;

  @override
  Widget build(BuildContext context) {
    String _text = (_isExtended)
        ? _content
        : LocalizationData.of(context, Tag.error1) + _content;
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return (!Platform.isIOS || _isOverridden)
        ? AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text(
                  (_isExtended)
                      ? MaterialLocalizations.of(context).okButtonLabel
                      : MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel
                          .toUpperCase(),
                ),
                onPressed: () => _BottomDrawer()._onWillPop(context),
              ),
            ],
            content: Text(_text),
            title: (_isOverridden)
                ? null
                : (_isExtended)
                    ? Text(_title)
                    : Row(
                        children: <Widget>[
                          Icon(Icons.warning, color: Colors.black54),
                          Text('  ${LocalizationData.of(context, Tag.error0)}'),
                        ],
                      ),
          )
        : CupertinoAlertDialog(
            actions: <Widget>[
              Row(),
              Divider(color: Colors.black45, height: 0.0),
              Stack(
                children: <Widget>[
                  CupertinoDialogAction(
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    isDefaultAction: true,
                    onPressed: () {},
                  ),
                  Positioned.fill(
                    child: Material(
                      child: InkWell(
                        onTap: () => _BottomDrawer()._onWillPop(context),
                        splashColor: Colors.transparent,
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ],
            content: Text(_text),
            title: Text(
              (_isExtended) ? _title : LocalizationData.of(context, Tag.error0),
            ),
          );
  }
}

class _FavoriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Container(
        child: RaisedButton.icon(
          color: Colors.white,
          elevation: 0.5,
          highlightElevation: 0.5,
          icon: Icon(Icons.star),
          label: Text(
            LocalizationData.of(context, Tag.favorite),
            style: TextStyle(fontSize: 18.0),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConstantData().favoritePage,
              ),
            );
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38.0),
            side: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
        height: 50.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
    );
  }
}

class _FavoriteInfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Row(
              children: <Widget>[
                Padding(
                  child: Icon(Icons.info_outline),
                  padding: EdgeInsets.symmetric(horizontal: 4.5),
                ),
                Padding(
                  child: Text(LocalizationData.of(context, Tag.favorite0)),
                  padding: EdgeInsets.only(
                    bottom: (Provider().isEN(context)) ? 0.0 : 2.5,
                    left: 7.0,
                    top: (Provider().isEN(context)) ? 1.0 : 0.0,
                  ),
                ),
              ],
            ),
            color: Colors.grey[200],
            height: 38.0,
          ),
        ),
      ],
    );
  }
}

class _FeedbackFieldIOS extends StatelessWidget {
  _FeedbackFieldIOS(parent) : _parent = parent;

  final _parent;
  static String _email = '', _feedback = '';

  @override
  Widget build(BuildContext context) {
    String _error = _parent._warning, _helper = _parent._note;
    return Flexible(
      child: Column(
        children: <Widget>[
          Padding(
            child: Stack(
              children: <Widget>[
                Container(
                  child: Text(
                    LocalizationData.of(context, Tag.feedback0),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14.5,
                      letterSpacing: -0.5,
                    ),
                  ),
                  padding: EdgeInsets.only(top: 7.5),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _parent._emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 7.5,
                            ),
                            counterText: '',
                            errorText: _error,
                            helperText: _helper,
                            hintStyle: TextStyle(
                              color: Colors.black26,
                              letterSpacing: -0.5,
                            ),
                            hintText:
                                LocalizationData.of(context, Tag.feedback1),
                          ),
                          focusNode: _parent._emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          maxLength: 108,
                          maxLines: null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                              _parent._feedbackFocus,
                            );
                          },
                          onSaved: (value) => _email = value,
                          style: TextStyle(color: Colors.black, fontSize: 14.5),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            return (_parent._validateEmail(value) == null)
                                ? null
                                : _error;
                          },
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(left: 55.0, right: 30.0),
                ),
                (_error == null)
                    ? Container()
                    : Positioned(
                        child: Icon(
                          Icons.error_outline,
                          color: ConstantData().errorColor,
                        ),
                        right: 10.0,
                        top: 6.5,
                      ),
              ],
            ),
            padding: EdgeInsets.only(left: 20.0, top: 10.15),
          ),
          Padding(
            child: Divider(color: ConstantData().dividerColor, height: 0.0),
            padding: (_error == null && _helper == null)
                ? EdgeInsets.zero
                : EdgeInsets.only(top: 11.25),
          ),
          Padding(
            child: TextFormField(
              controller: _parent._feedbackController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 7.5),
                hintStyle: TextStyle(
                  color: Colors.black54,
                  letterSpacing: -0.5,
                ),
                hintText: LocalizationData.of(context, Tag.feedback3),
              ),
              focusNode: _parent._feedbackFocus,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onSaved: (value) => _feedback = value,
              style: TextStyle(color: Colors.black, fontSize: 16.5),
              textInputAction: TextInputAction.done,
              validator: (value) => (value.trim().isNotEmpty) ? null : '',
            ),
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 8.32),
          ),
        ],
      ),
      flex: 0,
    );
  }
}

class _FeedbackNoteIOS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: LocalizationData.of(context, Tag.feedback5)),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConstantData().sysinfoPage,
                      ),
                    );
                  },
                style: TextStyle(color: ConstantData().defaultColor),
                text: LocalizationData.of(context, Tag.feedback6),
              ),
              TextSpan(text: LocalizationData.of(context, Tag.feedback7)),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConstantData().privacyPage,
                      ),
                    );
                  },
                style: TextStyle(color: ConstantData().defaultColor),
                text: LocalizationData.of(context, Tag.privacy),
              ),
              TextSpan(text: (!Provider().isEN(context)) ? 'และ' : ' and '),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConstantData().servicePage,
                      ),
                    );
                  },
                style: TextStyle(color: ConstantData().defaultColor),
                text: LocalizationData.of(context, Tag.service),
              ),
              TextSpan(text: (!Provider().isEN(context)) ? null : '.'),
            ],
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
      color: ConstantData().tileColor,
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.symmetric(vertical: 10.0),
    );
  }
}

class _FeedbackScreenshotIOS extends StatelessWidget {
  _FeedbackScreenshotIOS(parent, File image)
      : _parent = parent,
        _image = image;

  final _parent;
  final File _image;

  void _getImage() async {
    File _img = await ImagePicker.pickImage(source: ImageSource.gallery);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    _parent.setState(() => _parent._image = _img);
  }

  @override
  Widget build(BuildContext context) {
    bool _hasNotImage = (_image == null);
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                ListTile(
                  contentPadding: (_hasNotImage) ? null : EdgeInsets.all(0.0),
                  leading: (_hasNotImage)
                      ? null
                      : Image.file(
                          _image,
                          fit: BoxFit.cover,
                          height: 56.0,
                          width: 59.0,
                        ),
                  title: Text(
                    LocalizationData.of(context, Tag.feedback4),
                    style: TextStyle(fontSize: 15.0, letterSpacing: -0.5),
                  ),
                  trailing:
                      (!_hasNotImage) ? null : Icon(Icons.add_photo_alternate),
                ),
                Positioned(
                  child: (_hasNotImage)
                      ? Container()
                      : Icon(
                          Icons.check,
                          color: CupertinoColors.activeBlue,
                          size: 26.5,
                        ),
                  right: 14.5,
                  top: 13.5,
                ),
                Positioned.fill(
                  child: Material(
                    child: InkWell(
                      onTap: _getImage,
                      splashColor: Colors.transparent,
                    ),
                    color: Colors.transparent,
                  ),
                ),
              ],
            ),
            color: Color(0xFFF5F5F5),
            margin: EdgeInsets.all(20.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      ),
    );
  }
}

class _FeedbackWidget extends StatefulWidget {
  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<_FeedbackWidget> {
  final _emailController = TextEditingController(),
      _emailFocus = FocusNode(),
      _feedbackController = TextEditingController(),
      _feedbackFocus = FocusNode(),
      _formKey = GlobalKey<FormState>();
  final String _email =
          ConstantData().feedbackPage1.substring(0, 5).toLowerCase(),
      _feedback = ConstantData().feedback.substring(5).toLowerCase(),
      _screenshot = ConstantData().feedbackPage3.toLowerCase();
  bool _isCursorDirty = false, _isEmailValid = true, _isFeedbackDirty = false;
  Color _sendIconColor = Colors.grey;
  File _image;
  String _note, _warning;

  _onBackPressed(bool canCallSnackBar) {
    _isCursorDirty = false;
    _isEmailValid = true;
    _isFeedbackDirty = false;
    Catalog()._cursorColor(context, ConstantData().defaultColor);
    if (canCallSnackBar) {
      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
      HomePage.canShowSnackBar = true;
    } else {
      Navigator.pop(context);
    }
    return Future<bool>.value(false);
  }

  bool _isIPAddress(String input, [bool isIPv6]) {
    int _discardedDelimiter = ((isIPv6 ?? false) ? '.' : ':').codeUnitAt(0);
    var _chars = List(), _nums = List();
    for (int _i = (!(isIPv6 ?? false)) ? 46 : 48;
        _i < ((!(isIPv6 ?? false)) ? 58 : 103);
        _i++) {
      if ((_i > 47) && (_i < 58)) _nums.add(String.fromCharCode(_i));
      if (((_i != _discardedDelimiter) && (_i != 47)) &&
          ((_i < 59) ||
              ((_i > 64) && (_i < 71)) ||
              ((_i > 96) && (_i < 103)))) {
        _chars.add(String.fromCharCode(_i));
      }
    }
    if (_nums.any((num) => input.startsWith(num)) &&
        input.split('').every((value) => _chars.contains(value))) {
      for (int _i = 0; _i < input.length; _i++) {
        if ((isIPv6 ?? false)) {
          if ((_i + 1 >= input.length) || (_i + 2 >= input.length)) break;
          String _check = input[_i] + input[_i + 1] + input[_i + 2];
          if (':'.allMatches(_check).length > 2) return false;
        } else {
          if ((_i + 1 >= input.length)) break;
          String _check = input[_i] + input[_i + 1];
          if ('.'.allMatches(_check).length > 1) return false;
        }
      }
      if ((!(isIPv6 ?? false)) &&
          (!_nums.any((num) => input.endsWith(num)) ||
              (input.split('.').length != 4))) return false;
      return true;
    } else {
      return false;
    }
  }

  bool _isIPv4Address(String address) {
    var _octets = List();
    address.split('.').forEach((i) => _octets.add(int.parse(i)));
    if (((_octets[0] > 0) && (_octets[0] < 10)) ||
        ((_octets[0] > 10) && (_octets[0] < 127)) ||
        ((_octets[0] > 128) && (_octets[0] < 224))) {
      switch (_octets[0]) {
        case 100:
          if ((_octets[1] < 64) || (_octets[1] > 127)) continue validCase;
          break;
        case 169:
          if (_octets[1] != 254) continue validCase;
          break;
        case 172:
          if ((_octets[1] < 16) || (_octets[1] > 3)) continue validCase;
          break;
        case 192:
          if (((_octets[1] != 0) || ((_octets[2] != 0) && (_octets[2] != 2))) &&
              ((_octets[1] != 88) || (_octets[2] != 99)) &&
              (_octets[1] != 168)) continue validCase;
          break;
        case 198:
          if (((_octets[1] < 18) || (_octets[1] > 19)) &&
              ((_octets[1] != 51) || (_octets[2] != 100))) continue validCase;
          break;
        case 203:
          if ((_octets[1] != 0) || (_octets[2] != 113)) continue validCase;
          break;
        validCase:
        default:
          if ((_octets[1] < 256) &&
              (_octets[2] < 256) &&
              (_octets[3] < 255) &&
              (_octets[3] != 0)) return true;
          break;
      }
    }
    return false;
  }

  bool _isIPv6Address(String address) {
    List<String> _allocatedBasePrefixes = [
      '2001',
      '2003',
      '2400',
      '2600',
      '2610',
      '2620',
      '2800',
      '2a00',
      '2c00',
    ];
    var _allocatedPrefixes = List(), _hextets = List();
    for (String _prefix in _allocatedBasePrefixes) {
      for (int _i = 1; _i < 16; _i++) {
        if (_prefix.endsWith('00')) {
          _hextets.add(_prefix.substring(0, 3) + _iterateIntToHex(_i));
        }
      }
    }
    _allocatedPrefixes = List.from(_allocatedBasePrefixes)..addAll(_hextets);
    _allocatedPrefixes.sort();
    _hextets.clear();
    address.split(':').forEach((hex) {
      _hextets.add(hex.toLowerCase().padLeft(4, '0'));
    });
    if (_hextets.length != 8) {
      for (int _i = 0; _i < 9; _i++) {
        if (_hextets.length == 8) break;
        if (_hextets.indexOf('0000') == -1) return false;
        _hextets.insert(_hextets.indexOf('0000'), '0000');
      }
    }
    if (_allocatedPrefixes.contains(_hextets[0]) &&
        _hextets.every((value) => value.length < 5)) {
      switch (_hextets[0]) {
        case '2001':
          if (_prefixList('0001', '0fff').contains(_hextets[1])) {
            if ((!((_hextets[1] == '0001') &&
                    _hextets.getRange(2, 6).every((value) => value == '0000') &&
                    (_hextets[7] == '0001'))) &&
                (!((_hextets[1] == '0002') && (_hextets[2] == '0000'))) &&
                (_hextets[1] != '0003') &&
                (!((_hextets[1] == '0004') && (_hextets[2] == '0112'))) &&
                (_hextets[1] != '0005') &&
                (!_prefixList('0010', '002f').contains(_hextets[1])) &&
                (_hextets[1] != '0db8')) {
              continue validCase;
            }
          } else if (_prefixList('1200', '3bff').contains(_hextets[1]) ||
              _prefixList('4000', '4dff').contains(_hextets[1]) ||
              _prefixList('5000', '5fff').contains(_hextets[1]) ||
              _prefixList('8000', 'bfff').contains(_hextets[1])) {
            continue validCase;
          }
          break;
        case '2003':
          if (_prefixList('0000', '3fff').contains(_hextets[1])) {
            continue validCase;
          }
          break;
        case '2610':
        case '2620':
          if (_prefixList('0000', '01ff').contains(_hextets[1])) {
            continue validCase;
          }
          break;
        validCase:
        default:
          return true;
          break;
      }
    }
    return false;
  }

  bool _validateDomainPart(String domainPart) {
    if (domainPart.isNotEmpty) {
      // No digit and special ASCII chars at first and last.
      if (!domainPart.startsWith(ConstantData().nonDomainPattern) &&
          !domainPart[domainPart.length - 1].contains(
            ConstantData().nonDomainPattern,
          )) {
        int _realTLDDotIndex = domainPart.lastIndexOf('.');
        bool _isTLDDotTyped = (_realTLDDotIndex > -1);
        String _tld = domainPart.substring(_realTLDDotIndex + 1);
        // No digits and special ASCII chars at TLD
        // and the minimum length is a language code.
        if (_isTLDDotTyped &&
            (_tld.length > 1) &&
            !_tld.contains(ConstantData().nonDomainPattern)) {
          String _subDomain = domainPart.substring(0, _realTLDDotIndex);
          // No digits and special ASCII chars at any NLD
          if (!_subDomain.startsWith('.') &&
              !_subDomain.endsWith('.') &&
              _subDomain.split('.').every((value) {
                return value.isNotEmpty &&
                    !value.contains(ConstantData().nonSubDomainPattern) &&
                    (value.length < 64);
              })) return true;
        }
      } else if (domainPart.startsWith('[') && domainPart.endsWith(']')) {
        int _realBracketIndex = domainPart.lastIndexOf('[');
        bool _isBracketTyped = (_realBracketIndex > -1);
        String _address =
            domainPart.substring(_realBracketIndex + 1, domainPart.length - 1);
        if (_isBracketTyped) {
          // IPv4 check
          if (_isIPAddress(_address) &&
              _isIPv4Address(_address) &&
              ('.'.allMatches(_address).length == 3)) {
            return true;
          } else
          // IPv6 check
          if (_isIPAddress(_address, true) &&
              _isIPv6Address(_address) &&
              (':'.allMatches(_address).length > 1) &&
              (':'.allMatches(_address).length < 8)) {
            return true;
          } else {
            _warning = LocalizationData.of(context, Tag.feedback9);
          }
        }
      }
    }
    return false;
  }

  bool _validateLocalPart(String localPart) {
    if (localPart.isNotEmpty && localPart.length < 65) {
      // Validate dot-string
      if (!localPart.startsWith(ConstantData().nonLocalWithDotPattern) &&
          !localPart[localPart.length - 1].contains(
            ConstantData().nonLocalWithDotPattern,
          )) {
        if (localPart.contains('.') &&
            localPart.split('.').every((value) {
              return value.isNotEmpty &&
                  !value.contains(ConstantData().nonLocalWithoutDotPattern);
            })) {
          return true;
        } else if (localPart.split('').every((value) {
          return !value.contains(ConstantData().nonLocalWithDotPattern);
        })) {
          return true;
        }
      } else
      // Validate quoted-string
      if (localPart.startsWith('\"') && localPart.endsWith('\"')) {
        String _quote = localPart.substring(1, localPart.length - 1);
        if (_quote.contains('\"')) {
          int _startIndex = 0;
          var _indices = List(), _list = List();
          for (int _i = 0; _i < _quote.length; _i++) {
            if ((_quote[_i] == '\"') || (_quote[_i] == '\\')) {
              _indices.add(_i);
            }
          }
          _indices.add(404);
          for (int _j = 0; _j < _indices.length; _j++) {
            if (_indices[_j] == 404) break;
            if (_indices[_j] + 1 != _indices[_j + 1]) {
              _list.add(_quote.substring(_startIndex, _indices[_j] + 1));
              _startIndex = _indices[_j + 1];
            }
          }
          if (!_list.any((value) => value == '\\') &&
              !_list.any((value) => value.startsWith('"')) &&
              !_list.any((value) => value.endsWith('"\\')) &&
              _list.every((value) {
                return (('"'.allMatches(value).length % 2 == 0) &&
                        ('\\'.allMatches(value).length % 2 == 0)) ||
                    (('"'.allMatches(value).length % 2 != 0) &&
                        ('\\'.allMatches(value).length % 2 != 0));
              })) return true;
        } else {
          if ('\\'.allMatches(_quote).length % 2 == 0) return true;
        }
      }
    }
    return false;
  }

  int _iterateHexToInt(String hex) {
    int _i;
    switch (hex) {
      case 'a':
        _i = 10;
        break;
      case 'b':
        _i = 11;
        break;
      case 'c':
        _i = 12;
        break;
      case 'd':
        _i = 13;
        break;
      case 'e':
        _i = 14;
        break;
      case 'f':
        _i = 15;
        break;
      default:
        _i = int.parse(hex);
        break;
    }
    return _i;
  }

  List _prefixList(String startValue, String endValue) {
    var _end = endValue.split(''),
        _list = List(),
        _start = startValue.split('');
    for (int _i = _iterateHexToInt(_start[0]); _i < 16; _i++) {
      String _first = _iterateIntToHex(_i);
      int _j = (_first == _start[0]) ? _iterateHexToInt(_start[1]) : 0;
      for (; _j < 16; _j++) {
        String _second = _iterateIntToHex(_j);
        int _k = ((_first == _start[0]) && (_second == _start[1]))
            ? _iterateHexToInt(_start[2])
            : 0;
        for (; _k < 16; _k++) {
          String _third = _iterateIntToHex(_k);
          int _l = ((_first == _start[0]) &&
                  (_second == _start[1]) &&
                  (_third == _start[2]))
              ? _iterateHexToInt(_start[3])
              : 0;
          for (; _l < 16; _l++) {
            String _last = _iterateIntToHex(_l),
                _value = '$_first$_second$_third$_last';
            _list.add(_value);
            if ((_first == _end[0]) &&
                (_second == _end[1]) &&
                (_third == _end[2]) &&
                (_last == _end[3])) break;
          }
          if ((_first == _end[0]) &&
              (_second == _end[1]) &&
              (_third == _end[2])) break;
        }
        if ((_first == _end[0]) && (_second == _end[1])) break;
      }
      if (_first == _end[0]) break;
    }
    return _list;
  }

  String _feedbackSubString(BuildContext context) {
    return (Platform.isIOS && Provider().isEN(context))
        ? LocalizationData.of(context, Tag.feedback).substring(5)
        : LocalizationData.of(context, Tag.feedback);
  }

  String _iterateIntToHex(int i) {
    String _hex;
    switch (i) {
      case 10:
        _hex = 'a';
        break;
      case 11:
        _hex = 'b';
        break;
      case 12:
        _hex = 'c';
        break;
      case 13:
        _hex = 'd';
        break;
      case 14:
        _hex = 'e';
        break;
      case 15:
        _hex = 'f';
        break;
      default:
        _hex = i.toString();
        break;
    }
    return _hex;
  }

  String _validateEmail(String deFacto) {
    var _quoteMarks = List();
    String _email = _emailController.text;
    int _realAtSignIndex = _email.lastIndexOf('@');
    bool _isAtSignTyped = (_realAtSignIndex > -1), _isValid = false;
    _isCursorDirty = (_email.length > 0);

    // Replace any variant of quote marks to straight double quotes (").
    for (int _i = 39; _i < 65093; _i++) {
      if ((_i == 39) ||
          (_i == 171) ||
          (_i == 187) ||
          ((_i > 8215) && (_i < 8224)) ||
          ((_i > 8248) && (_i < 8251)) ||
          ((_i > 12295) && (_i < 12304)) ||
          ((_i > 65088) && (_i < 65093))) {
        _quoteMarks.add(String.fromCharCode(_i));
      }
    }
    _quoteMarks.forEach((char) => _email = _email.replaceAll(char, '"'));

    if (_isAtSignTyped) {
      String _local = _email.substring(0, _realAtSignIndex);
      String _domain = _email.substring(_realAtSignIndex + 1);
      // Validate local part
      if (_validateLocalPart(_local)) {
        // Validate domain part
        _isValid = _validateDomainPart(_domain);
      }
      if (!_domain.endsWith(']')) _warning = null;
    }

    if (!_isCursorDirty || _isValid) {
      if (_isAtSignTyped) {
        ((_email.substring(0, _realAtSignIndex).length > 32) ||
                (_email.substring(_realAtSignIndex + 1).length > 32))
            ? _note = LocalizationData.of(context, Tag.feedback2)
            : _note = null;
      }
      _isEmailValid = true;
      _warning = null;
    } else {
      _isEmailValid = false;
      _warning ??= LocalizationData.of(context, Tag.feedback8);
    }
    return _warning;
  }

  void _cursorSendIconColor() {
    bool _isFeedbackNotEmpty = _feedbackController.text.trim().isNotEmpty;
    (!_isFeedbackDirty)
        ? (_emailFocus.hasFocus)
            ? (_isEmailValid)
                ? Catalog()._cursorColor(context, ConstantData().defaultColor)
                : Catalog()._cursorColor(context, ConstantData().errorColor)
            : Catalog()._cursorColor(context, ConstantData().defaultColor)
        : (_feedbackFocus.hasFocus)
            ? (_isFeedbackNotEmpty)
                ? Catalog()._cursorColor(context, ConstantData().defaultColor)
                : Catalog()._cursorColor(context, ConstantData().errorColor)
            : (_isEmailValid)
                ? Catalog()._cursorColor(context, ConstantData().defaultColor)
                : Catalog()._cursorColor(context, ConstantData().errorColor);
    setState(() {
      _sendIconColor =
          (_isEmailValid && _isFeedbackNotEmpty) ? Colors.black : Colors.grey;
    });
  }

  void _displayUploadDialog(StorageUploadTask task) {
    (!Platform.isIOS)
        ? showDialog(
            barrierDismissible: false,
            builder: (_) => _UploadDialog(task),
            context: context,
          )
        : showCupertinoDialog(
            builder: (_) => _UploadDialog(task),
            context: context,
          );
  }

  void _insertFeedback() async {
    var _feedbackFolder = FirebaseStorage.instance.ref().child(_feedback),
        _feedbackSchema = Provider().cardDataDatabaseReference(_feedback),
        _list = Catalog()._systemInfoList(context),
        _map = {
      _email: _FeedbackFieldIOS._email,
      _feedback: _FeedbackFieldIOS._feedback,
    };
    String _id, _name, _path, _type;
    StorageUploadTask _task;
    List _data = (await _feedbackSchema.once()).value;
    _id = (_data?.length)?.toString() ?? 1.toString();
    _list.forEach((value) {
      if (_list.indexOf(value) % 2 == 0) {
        _map[value.toLowerCase()] = _list[_list.indexOf(value) + 1];
      }
    });

    // Upload any image into Firebase Storage
    // and add a value (_path) for the next step.
    if (_image != null) {
      _name = _image.path.replaceAll(_image.parent.path, '').substring(1);
      _type = 'image/${_name.substring(_name.lastIndexOf('.') + 1)}';
      _task = _feedbackFolder.child(_name).putFile(
            _image,
            StorageMetadata(contentType: _type),
          );
      FlutterStatusbarManager.setNetworkActivityIndicatorVisible(true);
      _displayUploadDialog(_task);
      _UploadDialog._progress = 0.0;
      _path = await (await _task.onComplete).ref?.getDownloadURL();
    }
    _map[_screenshot] = _path ?? '';

    // Set all values (_map) into Firebase Realtime Database
    // with a number (_id) as an index.
    _feedbackSchema.child(_id).set(_map).then((_) {
      _FeedbackFieldIOS._email = '';
      _FeedbackFieldIOS._feedback = '';
      _onBackPressed(true);
    }).catchError((_) {
      Catalog().showWarningDialog(
        context,
        LocalizationData.of(context, Tag.error2),
        title: LocalizationData.of(context, Tag.error0),
      );
    }, test: (error) => error is! AssertionError);
  }

  void _invalidateHandleTap() {
    FocusNode _focus;
    if (_isCursorDirty && !_isEmailValid) {
      _focus = _emailFocus;
      _isFeedbackDirty = false;
      Catalog().showWarningDialog(context, _warning, override: true);
    } else {
      _focus = _feedbackFocus;
      _isFeedbackDirty = true;
      Catalog().showWarningDialog(
        context,
        LocalizationData.of(context, Tag.feedback10),
        override: true,
      );
    }
    Catalog()._cursorColor(context, ConstantData().errorColor);
    if (_focus.hasFocus) _focus.unfocus();
    FocusScope.of(context).requestFocus(_focus);
  }

  void _validateHandleTap() {
    _formKey.currentState.save();
    Provider().checkInternet(context);
    _insertFeedback();
  }

  @override
  void dispose() {
    _emailController.removeListener(
      () => _validateEmail(_emailController.text),
    );
    _emailController.removeListener(_cursorSendIconColor);
    _feedbackController.removeListener(_cursorSendIconColor);
    _emailController.dispose();
    _emailFocus.dispose();
    _feedbackController.dispose();
    _feedbackFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => _validateEmail(_emailController.text));
    _emailController.addListener(_cursorSendIconColor);
    _feedbackController.addListener(_cursorSendIconColor);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              color: _sendIconColor,
              icon: Icon(Icons.send),
              onPressed: () {
                (_isEmailValid && _formKey.currentState.validate())
                    ? _validateHandleTap()
                    : _invalidateHandleTap();
              },
              tooltip: LocalizationData.of(context, Tag.tooltip2),
            ),
          ],
          title: Text(_feedbackSubString(context)),
        ),
        body: Form(
          child: LayoutBuilder(
            builder: (_, scrollableConstraints) {
              return Scrollbar(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    child: IntrinsicHeight(
                      child: Column(
                        children: <Widget>[
                          _FeedbackFieldIOS(this),
                          _FeedbackScreenshotIOS(this, _image),
                        ],
                        mainAxisSize: MainAxisSize.min,
                      ),
                    ),
                    constraints: BoxConstraints(
                      minHeight: scrollableConstraints.maxHeight,
                    ),
                  ),
                ),
              );
            },
          ),
          key: _formKey,
        ),
        bottomNavigationBar: _FeedbackNoteIOS(),
      ),
      onWillPop: () => _onBackPressed(false),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  _InfoWidget(bool isFavoritePage, AsyncSnapshot snapshot, List list)
      : _isFavoritePage = isFavoritePage,
        _snapshot = snapshot,
        _list = list;

  final bool _isFavoritePage;
  final AsyncSnapshot _snapshot;
  final List _list;

  @override
  Widget build(BuildContext context) {
    TextStyle _display1 = Theme.of(context).textTheme.display1.copyWith(
          color: CupertinoColors.inactiveGray,
          fontSize: 27.0,
          letterSpacing: (!Platform.isIOS) ? null : 0.25,
        );
    return Center(
      child: (_isFavoritePage && _snapshot.hasData && _list.isEmpty)
          ? Text(
              LocalizationData.of(context, Tag.favorite3),
              style: _display1,
            )
          : (_snapshot.hasData && _list.isEmpty)
              ? RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        style: _display1,
                        text: LocalizationData.of(context, Tag.home),
                      ),
                      TextSpan(text: '\n\n'),
                      TextSpan(
                        style: TextStyle(color: Colors.grey),
                        text: LocalizationData.of(context, Tag.feedback15),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                )
              : (!_snapshot.hasData &&
                      (_snapshot?.connectionState == ConnectionState.waiting))
                  ? Column(
                      children: <Widget>[
                        (!Platform.isIOS)
                            ? CircularProgressIndicator()
                            : CupertinoActivityIndicator(),
                        Container(height: 20.0),
                        Text(
                          LocalizationData.of(context, Tag.feedback15),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                      mainAxisSize: MainAxisSize.min,
                    )
                  : (!Platform.isIOS)
                      ? CircularProgressIndicator()
                      : CupertinoActivityIndicator(),
    );
  }
}

class _MarqueeWidget extends StatefulWidget {
  _MarqueeWidget({
    this.direction: Axis.horizontal,
    this.animationDuration: const Duration(seconds: 10),
    this.pauseDuration: const Duration(seconds: 2),
    @required this.child,
  });

  final Axis direction;
  final Duration animationDuration, pauseDuration;
  final Widget child;

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<_MarqueeWidget> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.removeListener(() => _scrollListener());
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() => _scrollListener());
    _scroll();
  }

  void _scroll() async {
    while (true) {
      await Future.delayed(widget.pauseDuration);
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.linear,
          duration: widget.animationDuration,
        );
      }
    }
  }

  void _scrollListener() {
    // Optimized for any devices with screen sizes between
    // 4.0" (inclusive) to 4.7" (exclusive) only.
    double _delimiter = _scrollController.position.maxScrollExtent;
    if (_delimiter >= 400.0) {
      _delimiter -= _delimiter * 0.15;
    } else if ((_delimiter >= 350.0) && (_delimiter < 400.0)) {
      _delimiter -= _delimiter * 0.08;
    } else if ((_delimiter >= 333.0) && (_delimiter < 350.0)) {
      _delimiter -= _delimiter * 0.06;
    } else if ((_delimiter >= 325.0) && (_delimiter < 333.0)) {
      _delimiter -= _delimiter * 0.05;
    } else {
      _delimiter -= _delimiter * 0.03;
    }
    if (_scrollController.position.pixels >= _delimiter) {
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      controller: _scrollController,
      scrollDirection: widget.direction,
    );
  }
}

class _RippleCardEffect extends StatelessWidget {
  _RippleCardEffect(String message, [String category])
      : _category = category,
        _message = message;

  final String _category, _message;

  void _launchAppAndroid(BuildContext context) async {
    String _content, _url;
    switch (_category) {
      case ConstantData.eating:
      case ConstantData.going:
        _content = ConstantData.gmaps;
        _url = ConstantData().gmapsUrl + _query;
        break;
      case ConstantData.listening:
      case ConstantData.watching:
        _content = ConstantData.youtube;
        _url = ConstantData().youtubeUrl + _query;
        break;
    }
    _SearchListTile.override()._displayConfirmDialog(context, _content, _url);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          onTap: () {
            bool _hasCategory = [
                  ConstantData.eating,
                  ConstantData.going,
                  ConstantData.listening,
                  ConstantData.watching,
                ].contains(_category?.trim()) ??
                false;
            if (_hasCategory) _query = _message;
            (!Platform.isIOS && _hasCategory)
                ? _launchAppAndroid(context)
                : (!_hasCategory && (_category?.trim()?.isNotEmpty ?? false))
                    ? {}
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              Provider().passData(_message, _category),
                        ),
                      );
            _CardWidget._keys.forEach((key) => key.currentState?.close());
          },
          splashColor: Color.fromARGB(30, 100, 100, 100),
        ),
        color: Colors.transparent,
      ),
    );
  }
}

class _SearchAlertDialog extends StatelessWidget {
  _SearchAlertDialog(BuildContext context, String content)
      : _context = context,
        _content = content;

  final BuildContext _context;
  final String _content;

  void _selectAppStoreUrl() {
    String _url;
    switch (_content) {
      case 'Google ${ConstantData.chrome}':
        _url = ConstantData().chromeAppStoreUrl;
        break;
      case ConstantData.gmaps:
        _url = ConstantData().gmapsAppStoreUrl;
        break;
      case ConstantData.youtube:
        _url = ConstantData().youtubeAppStoreUrl;
        break;
    }
    _SearchListTile.override()._launchUrl(_context, _url);
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return CupertinoAlertDialog(
      actions: <Widget>[
        Divider(color: Colors.black45, height: 0.5),
        Stack(
          children: <Widget>[
            CupertinoDialogAction(
              child: Text(
                '${LocalizationData.of(context, Tag.search3)} App Store',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {},
            ),
            Positioned.fill(
              child: Material(
                child: InkWell(
                  onTap: () {
                    _selectAppStoreUrl();
                    _BottomDrawer()._onWillPop(context);
                  },
                  splashColor: Colors.transparent,
                ),
                color: Colors.transparent,
              ),
            ),
          ],
        ),
        Row(),
        Divider(color: Colors.black45, height: 0.0),
        Stack(
          children: <Widget>[
            CupertinoDialogAction(
              child: Text(
                (!Provider().isEN(context))
                    ? MaterialLocalizations.of(context).cancelButtonLabel
                    : 'Cancel',
                style: TextStyle(letterSpacing: -0.25),
              ),
              isDefaultAction: true,
              onPressed: () {},
            ),
            Positioned.fill(
              child: Material(
                child: InkWell(
                  onTap: () => _BottomDrawer()._onWillPop(context),
                  splashColor: Colors.transparent,
                ),
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ],
      content: Text(
        LocalizationData.of(context, Tag.search1) +
            _content +
            LocalizationData.of(context, Tag.search2),
      ),
      title: Text(
        '${LocalizationData.of(context, Tag.search0)} \“$_content\”?',
      ),
    );
  }
}

class _SearchListTile extends StatelessWidget {
  _SearchListTile(String icon, String title)
      : _icon = icon,
        _title = title;
  _SearchListTile.override()
      : _icon = '',
        _title = '';

  final String _icon, _title;
  static List<Widget> _finalList = [];
  static String _category, _content;
  static var _parent;

  List<Widget> _searchListTileDynamicList() {
    _searchListTileStaticList();
    Timer(
      Duration(microseconds: 1),
      () => ((_parent.mounted) ? _parent.setState(() {}) : {}),
    );
    return _finalList;
  }

  void _displayConfirmDialog(BuildContext context, String content, String url) {
    showDialog(
      barrierDismissible: false,
      builder: (_) => _ConfirmDialog(context, content, url),
      context: context,
    );
  }

  void _launchAppIOS(BuildContext context) async {
    String _path = Uri.encodeFull(_query);
    switch (_title) {
      case ConstantData.amaps:
        _displayConfirmDialog(
          context,
          ConstantData.amaps,
          ConstantData().amapsUrl + _path,
        );
        break;
      case ConstantData.gmaps:
        (await canLaunch(ConstantData().gmapsApp))
            ? _displayConfirmDialog(
                context,
                ConstantData.gmaps,
                ConstantData().gmapsApp + _path,
              )
            : Catalog()._showAlertErrorDialog(
                context,
                ConstantData.gmaps,
              );
        break;
      case ConstantData.chrome:
        (await canLaunch(ConstantData().chromeApp))
            ? _displayConfirmDialog(
                context,
                'Google ${ConstantData.chrome}',
                ConstantData().chromeApp + _content.substring(8) + _path,
              )
            : Catalog()._showAlertErrorDialog(
                context,
                'Google ${ConstantData.chrome}',
              );
        break;
      case ConstantData.safari:
        _displayConfirmDialog(
          context,
          ConstantData.safari,
          _content + _path,
        );
        break;
      case ConstantData.youtube:
        (await canLaunch(ConstantData().youtubeApp))
            ? _displayConfirmDialog(
                context,
                ConstantData.youtube,
                ConstantData().youtubeApp + _path,
              )
            : Catalog()._showAlertErrorDialog(
                context,
                ConstantData.youtube,
              );
        break;
    }
  }

  void _launchUrl(BuildContext context, String url,
      {bool forceSafariVC, String message}) async {
    if (await canLaunch(url)) {
      if (!Platform.isIOS) Fluttertoast.showToast(msg: message);
      await launch(url, forceSafariVC: forceSafariVC);
    } else {
      Catalog()._showAlertErrorDialog(context, url, false);
    }
  }

  void _searchListTileStaticList() async {
    var _list = List<Widget>();
    switch (_category) {
      case ConstantData.eating:
      case ConstantData.going:
        _content = ConstantData().gmapsUrl;
        _list = [
          _SearchListTile(ConstantData().gmapsIcon, ConstantData.gmaps),
          _SearchListTile(ConstantData().amapsIcon, ConstantData.amaps),
          _SearchListTile(ConstantData().chromeIcon, ConstantData.chrome),
        ];
        if (!await canLaunch(ConstantData().gmapsApp)) {
          _list.add(
            _SearchListTile(ConstantData().safariIcon, ConstantData.safari),
          );
        }
        break;
      case ConstantData.listening:
      case ConstantData.watching:
        _content = ConstantData().youtubeUrl;
        _list = [
          _SearchListTile(ConstantData().youtubeIcon, ConstantData.youtube),
          _SearchListTile(ConstantData().chromeIcon, ConstantData.chrome),
        ];
        if (!await canLaunch(ConstantData().youtubeApp)) {
          _list.add(
            _SearchListTile(ConstantData().safariIcon, ConstantData.safari),
          );
        }
        break;
    }
    _finalList = _list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: InkWell(
            child: Column(
              children: <Widget>[
                Container(height: 7.0),
                ListTile(
                  leading: Image.asset(_icon, scale: 3.5),
                  title: Text(
                    _title,
                    style: TextStyle(fontSize: 20.0, letterSpacing: -1.0),
                  ),
                  trailing: Icon(
                    CupertinoIcons.forward,
                    color: Color(0xFFC7C7CC),
                    size: 31.0,
                  ),
                ),
                Container(height: 7.0),
              ],
            ),
            onTap: () => _launchAppIOS(context),
            splashColor: Colors.transparent,
          ),
          type: MaterialType.transparency,
        ),
        Padding(
          child: Divider(color: ConstantData().dividerColor, height: 1.0),
          padding: EdgeInsets.only(left: 90.0),
        ),
      ],
    );
  }
}

class _SystemInfoListTile extends StatefulWidget {
  _SystemInfoListTile({Key key, @required this.context, @required this.content})
      : super(key: key);

  final BuildContext context;
  final String content;

  _SystemInfoListTileState createState() =>
      _SystemInfoListTileState(context, content);
}

class _SystemInfoListTileState extends State<_SystemInfoListTile> {
  _SystemInfoListTileState(BuildContext context, String content)
      : _context = context,
        _content = content;
  _SystemInfoListTileState.override()
      : _context = null,
        _content = '';

  final BuildContext _context;
  final String _content;
  static String _appIdentifier = '?',
      _appName = '?',
      _appVersion = '?',
      _batteryLevel = '?',
      _batteryState = '?',
      _dateTime = '?',
      _deviceModel = '?',
      _deviceOSVersion = '?';

  static List _systemInfoStaticList(BuildContext context) {
    var _items = List(), _tags = List();
    _staticInfo(context);
    _dateTime = Provider().fetchDateTime(context);
    Tag.values.forEach((tag) {
      if (tag.toString().contains(Tag.sysinfo.toString())) _tags.add(tag);
    });
    _tags.remove(Tag.sysinfo);
    for (int _i = 0; _i < _tags.length * 2; _i++) {
      String _text;
      switch (_i) {
        case 1:
          _text = _deviceModel;
          break;
        case 3:
          _text = _deviceOSVersion;
          break;
        case 5:
          _text = _appName;
          break;
        case 7:
          _text = _appIdentifier;
          break;
        case 9:
          _text = _appVersion;
          break;
        case 11:
          _text = _dateTime;
          break;
        case 13:
          _text = '$_batteryLevel.00%';
          break;
        case 15:
          _text = _batteryState;
          break;
        case 17:
          _text = Platform.localeName.replaceAll('_', '-');
          break;
        default:
          _text = LocalizationData.of(context, _tags[_i ~/ 2]);
          break;
      }
      _items.add(_text);
    }
    return _items;
  }

  static void _staticInfo(BuildContext context) async {
    PackageInfo _packageInfo = await PackageInfo.fromPlatform();
    var _battery = Battery(), _deviceInfo = DeviceInfoPlugin();
    if (!Platform.isIOS) {
      AndroidDeviceInfo _androidInfo = await _deviceInfo.androidInfo;
      _deviceModel = _androidInfo.model;
      _deviceOSVersion = _androidInfo.version.release;
    } else {
      IosDeviceInfo _iosInfo = await _deviceInfo.iosInfo;
      _deviceModel = _iosInfo.utsname.machine;
      _deviceOSVersion = _iosInfo.systemVersion;
    }
    _appName = _packageInfo.appName;
    _appIdentifier = _packageInfo.packageName;
    _appVersion = _packageInfo.version;
    try {
      int _level = await _battery.batteryLevel;
      _batteryLevel = _level.toString();
    } on Exception {}
    // Below method cannot use await keyword.
    _battery.onBatteryStateChanged.listen(
      (state) {
        switch (state) {
          case BatteryState.full:
            _batteryState = LocalizationData.of(context, Tag.battery0);
            break;
          case BatteryState.charging:
            _batteryState = LocalizationData.of(context, Tag.battery1);
            break;
          case BatteryState.discharging:
            _batteryState = LocalizationData.of(context, Tag.battery2);
            break;
        }
      },
      onError: (_) {},
    );
  }

  List _systemInfoDynamicList(BuildContext context) {
    Timer(
      Duration(seconds: 1),
      () => ((mounted) ? setState(() {}) : {}),
    );
    return _systemInfoStaticList(context);
  }

  @override
  Widget build(BuildContext context) {
    int _index = _systemInfoDynamicList(context).indexOf(_content);
    return (_index % 2 != 0)
        ? Container()
        : ListTile(
            subtitle: Text(_systemInfoDynamicList(context)[++_index]),
            title: Text(_content),
          );
  }
}

class _UploadDialog extends StatelessWidget {
  _UploadDialog(StorageUploadTask task) : _task = task;

  final StorageUploadTask _task;
  static double _progress = 0.0;

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    int _total = snapshot.totalByteCount,
        _transferred = snapshot.bytesTransferred;
    double _sentKilo = _transferred / 1024,
        _sentMega = _sentKilo / 1024,
        _sentGiga = _sentMega / 1024,
        _sizeKilo = _total / 1024,
        _sizeMega = _sizeKilo / 1024,
        _sizeGiga = _sizeMega / 1024;
    String _sent, _sentUnit, _size, _sizeUnit;
    // Format bytesTransferred
    if (double.parse(_sentGiga.toStringAsFixed(1)) >= 1.0) {
      _sent = _sentGiga.toStringAsFixed(1);
      _sentUnit = 'GB';
    } else if (double.parse(_sentMega.toStringAsFixed(1)) >= 1.0) {
      _sent = _sentMega.toStringAsFixed(1);
      _sentUnit = 'MB';
    } else if (double.parse(_sentKilo.toStringAsFixed(1)) >= 1.0) {
      _sent = _sentKilo.toStringAsFixed(1);
      _sentUnit = 'KB';
    } else {
      _sent = _transferred.toStringAsFixed(1);
      _sentUnit = 'B';
    }
    // Format totalByteCount
    if (double.parse(_sizeGiga.toStringAsFixed(1)) >= 1.0) {
      _size = _sizeGiga.toStringAsFixed(1);
      _sizeUnit = 'GB';
    } else if (double.parse(_sizeMega.toStringAsFixed(1)) >= 1.0) {
      _size = _sizeMega.toStringAsFixed(1);
      _sizeUnit = 'MB';
    } else if (double.parse(_sizeKilo.toStringAsFixed(1)) >= 1.0) {
      _size = _sizeKilo.toStringAsFixed(1);
      _sizeUnit = 'KB';
    } else {
      _size = _total.toStringAsFixed(1);
      _sizeUnit = 'B';
    }
    _progress = _transferred / _total * 100.0;
    return '$_sent $_sentUnit of $_size $_sizeUnit';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        // A comparison table on StorageUploadTask (_task) status,
        // AsyncSnapshot and StorageTaskEventType information.
        //          | isComplete | isCanceled | isSuccessful | hasData |   type
        // initial  :      F     |      F     |      F       |    F    |   null
        // progress :      F     |      F     |      F       |    T    |  progress
        // cancel   :      T     |      T     |      F       |    T    |  failure
        // error    :      T     |      F     |      F       |    T    |  failure
        // success  :      T     |      F     |      T       |    T    |  success
        bool _isError = (_task.isComplete &&
            !_task.isCanceled &&
            !_task.isSuccessful &&
            snapshot.hasData &&
            (snapshot.data?.type == StorageTaskEventType.failure));
        IconData _icon = (_isError)
            ? Icons.warning
            : (_task.isSuccessful) ? Icons.done : Icons.file_upload;
        String _subtitle = (_isError)
                ? LocalizationData.of(context, Tag.feedback13)
                : (!snapshot.hasData)
                    ? LocalizationData.of(context, Tag.feedback15)
                    : _bytesTransferred(snapshot.data.snapshot),
            _title = (_isError)
                ? LocalizationData.of(context, Tag.feedback12)
                : (_task.isSuccessful)
                    ? LocalizationData.of(context, Tag.feedback16)
                    : (!snapshot.hasData)
                        ? LocalizationData.of(context, Tag.feedback14)
                        : LocalizationData.of(context, Tag.feedback11);
        if (_task.isCanceled || _isError) _task.cancel();
        if (_task.isSuccessful || _isError) {
          FlutterStatusbarManager.setNetworkActivityIndicatorVisible(false);
          if (_task.isSuccessful) Navigator.maybePop(context);
        }
        return (!Platform.isIOS)
            ? AlertDialog(
                actions: (_task.isSuccessful)
                    ? null
                    : <Widget>[
                        FlatButton(
                          child: Text(
                            (_isError)
                                ? MaterialLocalizations.of(context)
                                    .modalBarrierDismissLabel
                                    .toUpperCase()
                                : MaterialLocalizations.of(context)
                                    .cancelButtonLabel,
                          ),
                          onPressed: () {
                            if (_task.isInProgress || _isError) {
                              _task.cancel();
                              _progress = 0.0;
                            }
                            FlutterStatusbarManager
                                .setNetworkActivityIndicatorVisible(false);
                            Navigator.maybePop(context);
                          },
                        ),
                      ],
                content: Column(
                  children: <Widget>[
                    Padding(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white,
                              value: _progress * 0.01,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                (_isError)
                                    ? Colors.grey
                                    : ConstantData().defaultColor,
                              ),
                            ),
                            padding: EdgeInsets.only(bottom: 17.5),
                          ),
                          Row(
                            children: <Widget>[Text(_subtitle)],
                            mainAxisAlignment: MainAxisAlignment.start,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                    ),
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
                title: Row(
                  children: <Widget>[
                    Icon(_icon, color: Colors.black54),
                    Text('  $_title'),
                  ],
                ),
              )
            : CupertinoAlertDialog(
                actions: (_task.isSuccessful)
                    ? <Widget>[]
                    : <Widget>[
                        Row(),
                        Divider(color: Colors.black45, height: 0.0),
                        Stack(
                          children: <Widget>[
                            CupertinoDialogAction(
                              child: Text(
                                (_isError)
                                    ? MaterialLocalizations.of(context)
                                        .okButtonLabel
                                    : 'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              isDefaultAction: true,
                              onPressed: () {},
                            ),
                            Positioned.fill(
                              child: Material(
                                child: InkWell(
                                  onTap: () {
                                    if (_task.isInProgress || _isError) {
                                      _task.cancel();
                                      _progress = 0.0;
                                    }
                                    FlutterStatusbarManager
                                        .setNetworkActivityIndicatorVisible(
                                            false);
                                    Navigator.maybePop(context);
                                  },
                                  splashColor: Colors.transparent,
                                ),
                                color: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ],
                content: Column(
                  children: <Widget>[
                    Padding(
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white,
                        value: _progress * 0.01,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (_isError)
                              ? CupertinoColors.inactiveGray
                              : ConstantData().defaultColor,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 17.5),
                    ),
                    Text(_subtitle),
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
                title: Text(_title),
              );
      },
      stream: _task.events,
    );
  }
}
