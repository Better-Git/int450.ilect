import 'dart:io';
import 'package:cache_image/cache_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ilect_app/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

String temp = '';

class Catalog {
  Widget bottomAppBar(String str1, [String str2]) {
    if (str2 != null && str2.isNotEmpty) {
      temp = str2;
    }
    return _BottomAppBar(str1);
  }

  Widget bottomAppBarExtended(bool b, String str) {
    return _BottomAppBar.extended(b, str);
  }

  Widget categoryCard(int i, List list) {
    return _CategoryCard(i, list);
  }

  Widget objectCard(int i, List list) {
    return _ObjectCard(i, list);
  }

  Widget searchListDivider() {
    return _searchListDivider();
  }

  Widget searchListTile(String icon, String title) {
    return _searchListTile(icon, title);
  }
}

class _BottomAppBar extends StatelessWidget {
  _BottomAppBar(String str) : _input = str;
  _BottomAppBar.extended(bool b, String str)
      : _bool = b,
        _input = str;

  bool _bool = false;
  String _input = '';
  var _rightIconButton;

  @override
  Widget build(BuildContext context) {
    switch (_bool) {
      case true:
        {
          _rightIconButton = IconButton(
            icon: Icon(Icons.share),
            onPressed: () => Share.share(share),
          );
        }
        break;
      default:
        {
          var _rightIcon;
          if (Platform.isAndroid) {
            _rightIcon = Icon(Icons.arrow_back);
          } else if (Platform.isIOS) {
            _rightIcon = Icon(Icons.arrow_back_ios);
          }
          _rightIconButton = IconButton(
            icon: _rightIcon,
            onPressed: () => Navigator.pop(context),
          );
        }
        break;
    }
    return BottomAppBar(
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () => showModalBottomSheet<Null>(
                    builder: (BuildContext context) => _BottomDrawer(),
                    context: context,
                  ),
            ),
            Text(
              _input,
              style: Theme.of(context).textTheme.title,
            ),
            _rightIconButton,
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.blue, width: 2.0))),
      ),
    );
  }
}

class _BottomDrawer extends StatelessWidget {
//  bool _downloaded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
//        SwitchListTile(
//          onChanged: (bool value) {
//            (() {
//              _downloaded = value;
//            });
//          },
//          secondary: Icon(Icons.cloud_off),
//          title: Text(op),
//          value: _downloaded,
//        ),
//        Divider(height: 1.0),
        ListTile(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => page01)),
          title: Text(feedback),
        ),
        Divider(height: 1.0),
        AboutListTile(
          aboutBoxChildren: [
            Padding(
              child: Column(
                children: <Widget>[
                  FlatButton(
                    child: Text(tos),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => page02)),
                    textColor: Colors.black87,
                  ),
                  FlatButton(
                    child: Text(pp),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => page03)),
                    textColor: Colors.black87,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 40.0),
            ),
          ],
          applicationIcon: Image.asset(ilectIcon, scale: 6.5),
          applicationLegalese: copyright,
          applicationName: title,
          applicationVersion: version,
          icon: Icon(Icons.info_outline),
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  _CategoryCard(int i, List list)
      : _index = i,
        _items = list;

  int _index = 0;
  List<CardData> _items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Padding(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: CacheImage.firebase(path: _items[_index].pic),
                  ),
                  Padding(
                    child: Text(
                      _items[_index].name,
                      style: TextStyle(fontSize: 30.0),
                    ),
                    padding: EdgeInsets.only(bottom: 11.0, top: 11.0),
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 19.0),
            ),
          ),
          _RippleCardEffect(_items[_index].name),
        ],
      ),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(38.0),
        side: BorderSide(color: Colors.blue, width: 2.0),
      ),
    );
  }
}

class _ObjectCard extends StatelessWidget {
  _ObjectCard(int i, List list)
      : _index = i,
        _items = list;

  int _index = 0;
  List<CardData> _items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: <Widget>[
          Padding(
            child: Column(
              children: <Widget>[
                Padding(
                  child: CacheImage.firebase(path: _items[_index].pic),
                  padding: EdgeInsets.only(
                      bottom: 5.0, left: 16.0, right: 16.0, top: 18.0),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      _items[_index].name,
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
            ),
            padding: EdgeInsets.all(13.0),
          ),
          _RippleCardEffect(_items[_index].name, temp),
        ],
      ),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(38.0),
        side: BorderSide(color: Colors.blue, width: 2.0),
      ),
    );
  }
}

class _RippleCardEffect extends StatelessWidget {
  _RippleCardEffect(String str1, [String str2])
      : _input1 = str1,
        _input2 = str2;

  String _input1 = '', _input2 = '';

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Provider().dataPass(_input1, _input2)),
              ),
          splashColor: Color.fromARGB(30, 100, 100, 100),
        ),
        color: Colors.transparent,
      ),
    );
  }
}

class _searchListDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Divider(color: Color(0xFFBCBBC1), height: 1.0),
      padding: EdgeInsets.only(left: 90.0),
    );
  }
}

class _searchListTile extends StatelessWidget {
  _searchListTile(String icon, String title, onTap)
      : _asset = icon,
        _input = title;

  String _asset = '', _input = '';
  var onTap;

  void _handleTap() async {
    switch (_input) {
      case amaps:
        {}
        break;
      case chrome:
      case safari:
        {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Error: Could not launch $url';
          }
        }
        break;
      case gmaps:
        {}
        break;
      case youtube:
        {}
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        child: Column(
          children: <Widget>[
            Container(height: 7.0),
            ListTile(
              leading: Image.asset(_asset, scale: 3.5),
              title: Text(
                _input,
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
        onTap: _handleTap,
      ),
      type: MaterialType.transparency,
    );
  }
}
