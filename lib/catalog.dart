import 'dart:io';
import 'package:cache_image/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:ilect_app/provider.dart';
import 'package:share/share.dart';

class Catalog {
  Widget bottomAppBar(var str) {
    return _BottomAppBar(str);
  }

  Widget bottomAppBarExtended(var str, bool b) {
    return _BottomAppBar.extended(str, b);
  }

  Widget categoryCard(int i, List list) {
    return _CategoryCard(i, list);
  }

  Widget objectCard(int i, List list) {
    return _ObjectCard(i, list);
  }
}

class _BottomAppBar extends StatelessWidget {
  _BottomAppBar(var str) : _input = str;
  _BottomAppBar.extended(var str, bool b)
      : _bool = b,
        _input = str;

  bool _bool = false;
  var _input = '', _rightIconButton;

  @override
  Widget build(BuildContext context) {
    switch (_bool) {
      case true:
        {
          _rightIconButton = new IconButton(
            icon: new Icon(Icons.share),
            onPressed: () => Share.share(
                'ฉันได้ใช้แอป iLect แล้วนะ\nอยากจะให้เพื่อนๆมาลองใช้กัน\n\nดาวน์โหลดได้ที่ ...'),
          );
        }
        break;
      default:
        {
          var _rightIcon;
          if (Platform.isAndroid) {
            _rightIcon = new Icon(Icons.arrow_back);
          } else if (Platform.isIOS) {
            _rightIcon = new Icon(Icons.arrow_back_ios);
          }
          _rightIconButton = new IconButton(
            icon: _rightIcon,
            onPressed: () => Navigator.pop(context),
          );
        }
        break;
    }
    return new BottomAppBar(
      child: new Container(
        child: new Row(
          children: <Widget>[
            new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () => showModalBottomSheet<Null>(
                  builder: (BuildContext context) => _BottomDrawer(),
                  context: context),
            ),
            new Text(
              _input,
              style: Theme.of(context).textTheme.title,
            ),
            _rightIconButton,
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        decoration: new BoxDecoration(
          border: new Border(
            top: new BorderSide(color: Colors.blue, width: 2.0),
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
    return new Column(
      children: <Widget>[
//        new SwitchListTile(
//          onChanged: (bool value) {
//            (() {
//              _downloaded = value;
//            });
//          },
//          secondary: new Icon(Icons.cloud_off),
//          title: new Text('Offline Pictures'),
//          value: _downloaded,
//        ),
//        new Divider(
//          height: 5.0,
//        ),
        new ListTile(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => page01)),
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
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => page02)),
                      textColor: Colors.black87,
                    ),
                    new FlatButton(
                      child: new Text('Privacy Policy'),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => page03)),
                      textColor: Colors.black87,
                    ),
                  ],
                ),
                padding: new EdgeInsets.only(top: 40.0)),
          ],
          applicationIcon: new Image.asset('assets/icon.png', scale: 6.5),
          applicationLegalese:
              '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
          applicationName: 'iLect',
          applicationVersion: 'version 0.3',
          icon: new Icon(Icons.info_outline),
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
    return new Card(
      child: new Stack(
        children: <Widget>[
          new Positioned.fill(
            child: new Padding(
              child: new Column(
                children: <Widget>[
                  new Expanded(
                    child: new CacheImage.firebase(path: _items[_index].pic),
                  ),
                  new Padding(
                    child: new Text(
                      _items[_index].name,
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
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Provider().dataPass(false, _items[_index].name))),
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

class _ObjectCard extends StatelessWidget {
  _ObjectCard(int i, List list)
      : _index = i,
        _items = list;

  int _index = 0;
  List<CardData> _items;

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Stack(
        children: <Widget>[
          new Padding(
            child: new Column(
              children: <Widget>[
                new CacheImage.firebase(path: _items[_index].pic),
                new Row(
                  children: <Widget>[
                    new Text(
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
          new Positioned.fill(
            child: new Material(
              child: new InkWell(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Provider().dataPass(true, _items[_index].name))),
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
