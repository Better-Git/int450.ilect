import 'dart:async' show Timer;
import 'dart:io' show Platform;
import 'package:cache_image/cache_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ilect_app/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

String _query, _temp;

class Catalog {
  TextStyle _style;

  List<Widget> searchList(String str) {
    List<Widget> _items;
    switch (str) {
      case ConstantData.eat:
      case ConstantData.go:
        {
          _items = [
            _SearchListTile(ConstantData().gmapsIcon, ConstantData.gmaps),
            _SearchListTile(ConstantData().amapsIcon, ConstantData.amaps),
            _SearchListTile(ConstantData().chromeIcon, ConstantData.chrome),
            _SearchListTile(ConstantData().safariIcon, ConstantData.safari),
          ];
        }
        break;
      case ConstantData.listen:
      case ConstantData.watch:
        {
          _items = [
            _SearchListTile(ConstantData().youtubeIcon, ConstantData.youtube),
            _SearchListTile(ConstantData().chromeIcon, ConstantData.chrome),
            _SearchListTile(ConstantData().safariIcon, ConstantData.safari),
          ];
        }
        break;
    }
    return _items;
  }

  TextStyle textStyleBottomAppBar(BuildContext context, String str) {
    (str != ConstantData().title && Platform.isIOS)
        ? _style = TextStyle(
            fontFamily: ConstantData().font,
            fontSize: 30.0,
            height: 1.5,
          )
        : _style = Theme.of(context).textTheme.title;
    return _style;
  }

  TextStyle textStyleCard([bool b]) {
    (!Platform.isIOS)
        ? _style = TextStyle(fontSize: 30.0)
        : (b)
            ? _style = TextStyle(
                fontFamily: ConstantData().font,
                fontSize: 40.0,
                height: 1.2,
              ) // _CategoryCard
            : _style = TextStyle(
                fontFamily: ConstantData().font,
                fontSize: 44.25,
                height: 1.55,
              ); // _ObjectCard
    return _style;
  }

  TextStyle textStyleSubtitle() {
    (!Platform.isIOS)
        ? textStyleSubtitleNonIOS()
        : _style = TextStyle(
            color: CupertinoColors.inactiveGray,
            fontFamily: ConstantData().font,
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            height: 1.45,
          );
    return _style;
  }

  TextStyle textStyleSubtitleNonIOS() {
    return TextStyle(
      color: CupertinoColors.inactiveGray,
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.4,
    );
  }

  Widget bottomAppBar(String str1, [String str2]) {
    if (str2 != null && str2.trim().isNotEmpty) _temp = str2;
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
}

class _BottomAppBar extends StatelessWidget {
  _BottomAppBar(String str)
      : _bool = false,
        _input = str;
  _BottomAppBar.extended(bool b, String str)
      : _bool = b,
        _input = str;

  final bool _bool;
  final String _input;

  @override
  Widget build(BuildContext context) {
    var _rightIconButton;
    switch (_bool) {
      case true:
        {
          _rightIconButton = IconButton(
            icon: Icon(Icons.share),
            onPressed: () => Share.share(ConstantData().share),
          );
        }
        break;
      default:
        {
          var _rightIcon;
          (Platform.isIOS)
              ? _rightIcon = Icon(Icons.arrow_back_ios)
              : _rightIcon = Icon(Icons.arrow_back);
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
              style: Catalog().textStyleBottomAppBar(context, _input),
            ),
            _rightIconButton,
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.blue, width: 2.0)),
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
//        Divider(height: 1.0),
        ListTile(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ConstantData().page01)),
          title: Text(ConstantData().feedback),
        ),
        Divider(height: 1.0),
        AboutListTile(
          aboutBoxChildren: [
            Padding(
              child: Column(
                children: <Widget>[
                  FlatButton(
                    child: Text(ConstantData().tos),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConstantData().page02)),
                    textColor: Colors.black87,
                  ),
                  FlatButton(
                    child: Text(ConstantData().pp),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConstantData().page03)),
                    textColor: Colors.black87,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 40.0),
            ),
          ],
          applicationIcon: Image.asset(ConstantData().ilectIcon, scale: 6.5),
          applicationLegalese: ConstantData().copyright,
          applicationName: ConstantData().title,
          applicationVersion: ConstantData().version,
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

  final int _index;
  final List<CardData> _items;

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
                    child: Image.network(
                      Provider().createImageUrl(_items[_index]),
                    ),
                  ),
                  Padding(
                    child: Text(
                      _items[_index].name,
                      style: Catalog().textStyleCard(true),
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

  final int _index;
  final List<CardData> _items;

  @override
  Widget build(BuildContext context) {
    String _text;
    var _pic;
    (_items[_index].name == null || _items[_index].name.trim().isEmpty)
        ? _text = _items[_index].search
        : _text = _items[_index].name;
    (_items[_index].pic.substring(0, 2) == 'gs')
        ? _pic = CacheImage.firebase(path: _items[_index].pic)
        : _pic =
            Image.network(Provider().createImageUrl(_items[_index], _temp));
    return Card(
      child: Stack(
        children: <Widget>[
          Padding(
            child: Column(
              children: <Widget>[
                Padding(
                  child: _pic,
                  padding: EdgeInsets.only(
                      bottom: 15.0, left: 16.0, right: 16.0, top: 18.0),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      _text.substring(
                          0, _text.lastIndexOf(ConstantData().pattern) + 1),
                      style: TextStyle(fontSize: 30.0),
                    ),
                    Text(
                      _text.substring(
                          _text.lastIndexOf(ConstantData().pattern) + 1),
                      style: Catalog().textStyleCard(false),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
              ],
            ),
            padding: EdgeInsets.all(15.0),
          ),
          _RippleCardEffect(_items[_index].search, _temp),
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

  final String _input1, _input2;

  void _launchAppAndroid() async {
    String _str = 'Open ', _url;
    switch (_temp) {
      case ConstantData.eat:
      case ConstantData.go:
        _str += ConstantData.gmaps;
        _url = ConstantData().gmapsUrl + _query;
        break;
      case ConstantData.listen:
      case ConstantData.watch:
        _str += ConstantData.youtube;
        _url = ConstantData().youtubeUrl + _query;
        break;
    }
    Fluttertoast.showToast(msg: _str);
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      throw 'Error: Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          onTap: () {
            _query = _input1;
            (_input2 != null && _input2.trim().isNotEmpty && !Platform.isIOS)
                ? _launchAppAndroid()
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Provider().dataPass(_input1, _input2)));
          },
          splashColor: Color.fromARGB(30, 100, 100, 100),
        ),
        color: Colors.transparent,
      ),
    );
  }
}

class _SearchAlertDialog extends StatelessWidget {
  _SearchAlertDialog(String str) : _input = str;

  final String _input;

  void _selectAppStoreUrl() async {
    String _url;
    switch (_input) {
      case 'Google ' + ConstantData.chrome:
        _url = ConstantData().chromeAppStoreUrl;
        break;
      case ConstantData.gmaps:
        _url = ConstantData().gmapsAppStoreUrl;
        break;
      case ConstantData.youtube:
        _url = ConstantData().youtubeAppStoreUrl;
        break;
    }
    if (await canLaunch(_url)) {
      await launch(_url);
    } else {
      throw 'Error: Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Get \“$_input\”?'),
      content: Text('You followed a link that requires the app \“$_input\”, ' +
          'which is no longer on your device. You can get it from the App Store.'),
      actions: <Widget>[
        Divider(color: Colors.black45, height: 0.5),
        Stack(
          children: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'Show in App Store',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {},
            ),
            Positioned.fill(
              child: Material(
                child: InkWell(
                  onTap: () {
                    _selectAppStoreUrl();
                    Navigator.pop(context);
                  },
                  splashColor: Colors.transparent,
                ),
                color: Colors.transparent,
              ),
            ),
          ],
        ),
        Row(),
        Divider(color: Colors.black45, height: 0.5),
        Stack(
          children: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(letterSpacing: -0.25),
              ),
              isDefaultAction: true,
              onPressed: () {},
            ),
            Positioned.fill(
              child: Material(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
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

class _SearchListTile extends StatelessWidget {
  _SearchListTile(String icon, String title)
      : _asset = icon,
        _input = title;

  final String _asset, _input;

  void _handleTap(BuildContext context) {
    switch (_temp) {
      case ConstantData.eat:
      case ConstantData.go:
        _launchAppIOS(context, ConstantData().gmapsUrl);
        break;
      case ConstantData.listen:
      case ConstantData.watch:
        _launchAppIOS(context, ConstantData().youtubeUrl);
        break;
    }
  }

  void _launchAppIOS(BuildContext context, String str) async {
    String _path = Uri.encodeFull(_query);
    switch (_input) {
      case ConstantData.amaps:
        _launchUrl(ConstantData().amapsUrl + _path);
        break;
      case ConstantData.gmaps:
        (await canLaunch(ConstantData().gmapsApp))
            ? _launchUrl(ConstantData().gmapsApp + _path)
            : showCupertinoDialog(
                context: context,
                builder: (BuildContext context) =>
                    _SearchAlertDialog(ConstantData.gmaps));
        break;
      case ConstantData.chrome:
        (await canLaunch(ConstantData().chromeApp))
            ? _launchUrl(ConstantData().chromeApp + str.substring(8) + _path)
            : showCupertinoDialog(
                context: context,
                builder: (BuildContext context) =>
                    _SearchAlertDialog('Google ' + ConstantData.chrome));
        break;
      case ConstantData.safari:
        if (await canLaunch(ConstantData().gmapsApp) &&
            str == ConstantData().gmapsUrl) {
          _showSnackBar(context, ConstantData.gmaps);
          Timer(Duration(milliseconds: 1000), () => _launchUrl(str + _path));
        } else if (await canLaunch(ConstantData().youtubeApp) &&
            str == ConstantData().youtubeUrl) {
          _showSnackBar(context, ConstantData.youtube);
          Timer(Duration(milliseconds: 1000), () => _launchUrl(str + _path));
        } else {
          _launchUrl(str + _path);
        }
        break;
      case ConstantData.youtube:
        (await canLaunch(ConstantData().youtubeApp))
            ? _launchUrl(ConstantData().youtubeApp + _path)
            : showCupertinoDialog(
                context: context,
                builder: (BuildContext context) =>
                    _SearchAlertDialog(ConstantData.youtube));
        break;
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      throw 'Error: Could not launch $url';
    }
  }

  void _showSnackBar(BuildContext context, String str) {
    final _snackBar = SnackBar(
      backgroundColor: Colors.white,
      content: Row(
        children: <Widget>[
          Card(
            child: Padding(
              child: Text(
                'Redirect to ' + str,
                style: TextStyle(color: Colors.black),
              ),
              padding: EdgeInsets.all(15.0),
            ),
            color: Colors.white,
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(38.0),
              side: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
    Scaffold.of(context).showSnackBar(_snackBar);
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
            onTap: () => _handleTap(context),
            splashColor: Colors.transparent,
          ),
          type: MaterialType.transparency,
        ),
        Padding(
          child: Divider(color: Color(0xFFBCBBC1), height: 1.0),
          padding: EdgeInsets.only(left: 90.0),
        ),
      ],
    );
  }
}
