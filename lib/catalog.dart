import 'dart:io';
import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:ilect_app/provider.dart';
import 'package:share/share.dart';

class Catalog {
  Widget bottomAppBar(String str) {
    return _BottomAppBar(str);
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
          border: Border(
            top: BorderSide(color: Colors.blue, width: 2.0),
          ),
        ),
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
//        Divider(height: 5.0),
        ListTile(
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page01),
              ),
          title: Text(feedback),
        ),
        Divider(height: 5.0),
        AboutListTile(
          aboutBoxChildren: [
            Padding(
              child: Column(
                children: <Widget>[
                  FlatButton(
                    child: Text(tos),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => page02),
                        ),
                    textColor: Colors.black87,
                  ),
                  FlatButton(
                    child: Text(pp),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => page03),
                        ),
                    textColor: Colors.black87,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 40.0),
            ),
          ],
          applicationIcon: Image.asset(icon, scale: 6.5),
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
          Positioned.fill(
            child: Material(
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Provider().dataPass(false, _items[_index].name),
                      ),
                    ),
                splashColor: Color.fromARGB(30, 100, 100, 100),
              ),
              color: Colors.transparent,
            ),
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
                CacheImage.firebase(path: _items[_index].pic),
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
          Positioned.fill(
            child: Material(
              child: InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(40.0),
                ),
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Provider().dataPass(true, _items[_index].name),
                      ),
                    ),
                splashColor: Color.fromARGB(30, 100, 100, 100),
              ),
              color: Colors.transparent,
            ),
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
}
