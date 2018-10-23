import 'dart:async' show Timer;
import 'dart:io' show File, Platform;
import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ilect_app/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

String _query, _temp;

class Catalog {
  final Color
      // Color assets
      defaultColor = Color(0xFF007AFF),
      dividerColor = Color(0xFFBCBBC1),
      errorColor = Color(0xFFB71C1C),
      tileColor = Color(0xFFF5F5F5);
  TextStyle _style;

  showAlertErrorDialog(BuildContext context, String str, [bool b]) {
    (!Platform.isIOS)
        ? showDialog(
            builder: (BuildContext context) => _ErrorDialog(str),
            context: context,
          )
        : showCupertinoDialog(
            builder: (BuildContext context) =>
                (b) ? _SearchAlertDialog(context, str) : _ErrorDialog(str),
            context: context,
          );
  }

  showWarningDialog(BuildContext context, String str1,
      {String str2, bool override}) {
    bool _override = (override == null) ? false : true;
    (!Platform.isIOS || _override)
        ? showDialog(
            barrierDismissible: false,
            builder: (BuildContext context) => (_override)
                ? _ErrorDialog.override(str1)
                : _ErrorDialog.extended(str2, str1),
            context: context,
          )
        : showCupertinoDialog(
            builder: (BuildContext context) =>
                _ErrorDialog.extended(str2, str1),
            context: context,
          );
  }

  List getSystemInfoList(BuildContext context) {
    return _SystemInfoListTileState.override()._systemInfoDynamicList(context);
  }

  List<Widget> searchList(String str) {
    List<Widget> _items;
    switch (str) {
      case ConstantData.eat:
      case ConstantData.go:
        _items = [
          _SearchListTile(ConstantData().gmapsIcon, ConstantData.gmaps),
          _SearchListTile(ConstantData().amapsIcon, ConstantData.amaps),
          _SearchListTile(ConstantData().chromeIcon, ConstantData.chrome),
          _SearchListTile(ConstantData().safariIcon, ConstantData.safari),
        ];
        break;
      case ConstantData.listen:
      case ConstantData.watch:
        _items = [
          _SearchListTile(ConstantData().youtubeIcon, ConstantData.youtube),
          _SearchListTile(ConstantData().chromeIcon, ConstantData.chrome),
          _SearchListTile(ConstantData().safariIcon, ConstantData.safari),
        ];
        break;
    }
    return _items;
  }

  List<Widget> splitString(bool b, String str) {
    List<String> _listString = str.split(' ');
    var _listText = List<Widget>();
    for (int i = 0; i < _listString.length; i++) {
      if (_listString[i].contains(ConstantData().thaiPattern)) {
        _listText.add(
          Text(
            _listString[i],
            style: (b)
                ? Catalog()._textStyleCard(false)
                : Catalog()._textStyleSubtitle(),
          ),
        );
      } else {
        _listText.add(
          Text(
            _listString[i],
            style: (b)
                ? TextStyle(
                    fontSize: 30.0,
                    letterSpacing: (!Platform.isIOS) ? null : -1.0,
                  )
                : Catalog()._textStyleSubtitleNonIOS(),
          ),
        );
      }
      if (i < _listString.length - 1) {
        var _space;
        (b)
            ? _space = String.fromCharCode(0x00A0) + String.fromCharCode(0x00A0)
            : _space = String.fromCharCode(0x00A0);
        _listText.add(Text(_space));
      }
    }
    return _listText;
  }

  List<Widget> systemInfoList(BuildContext context) {
    var _items = List<Widget>(), _list = Catalog().getSystemInfoList(context);
    for (var e in _list) {
      _items.add(_SystemInfoListTile(context: context, input: e));
    }
    return _items;
  }

  String feedbackSubString(BuildContext context) {
    String _feedback, _lang = Localizations.localeOf(context).languageCode;
    (Platform.isIOS && _lang == 'en')
        ? _feedback = LocalizationData.of(context, Tag.feedback).substring(5)
        : _feedback = LocalizationData.of(context, Tag.feedback);
    return _feedback;
  }

  TextStyle _textStyleBottomAppBar(BuildContext context, String str) {
    (str != ConstantData().title && Platform.isIOS)
        ? _style = TextStyle(
            fontFamily: ConstantData().font,
            fontSize: 30.0,
            height: 1.5,
          )
        : _style = Theme.of(context).textTheme.title;
    return _style;
  }

  TextStyle _textStyleCard([bool b]) {
    (!Platform.isIOS)
        ? _style = TextStyle(fontSize: 30.0)
        : (b)
            ? _style = TextStyle(
                fontFamily: ConstantData().font,
                fontSize: 40.0,
                height: 1.2,
              ) // _IndexCard
            : _style = TextStyle(
                fontFamily: ConstantData().font,
                fontSize: 44.25,
                height: 1.55,
              ); // _ObjectCard
    return _style;
  }

  TextStyle _textStyleSubtitle() {
    (!Platform.isIOS)
        ? _textStyleSubtitleNonIOS()
        : _style = TextStyle(
            color: CupertinoColors.inactiveGray,
            fontFamily: ConstantData().font,
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            height: 1.45,
          );
    return _style;
  }

  TextStyle _textStyleSubtitleNonIOS() {
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

  Widget bottomAppBarExtended(String str) {
    return _BottomAppBar.extended(str);
  }

  Widget feedbackNote() {
    return _FeedbackNote();
  }

  Widget feedbackScreenshotIOS(state, File image) {
    return _FeedbackScreenshotIOS(state, image);
  }

  Widget indexCard(int i, List list) {
    return _IndexCard(i, list);
  }

  Widget objectCard(int i, List list) {
    return _ObjectCard(i, list);
  }

  Widget setBackIcon() {
    var _backIcon;
    (!Platform.isIOS)
        ? _backIcon = Icon(Icons.arrow_back)
        : _backIcon = Icon(Icons.arrow_back_ios);
    return _backIcon;
  }

  void setCursorColor(BuildContext context, Color color) {
    DynamicTheme.of(context).setThemeData(ThemeData(
      cursorColor: color,
      primaryColor: Colors.white,
    ));
  }
}

class _BottomAppBar extends StatelessWidget {
  _BottomAppBar(String str)
      : _bool = false,
        _input = str;
  _BottomAppBar.extended(String str)
      : _bool = true,
        _input = str;

  final bool _bool;
  final String _input;

  @override
  Widget build(BuildContext context) {
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
              style: Catalog()._textStyleBottomAppBar(context, _input),
            ),
            (_bool)
                ? IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () => Share.share(ConstantData().share),
                  )
                : IconButton(
                    icon: Catalog().setBackIcon(),
                    onPressed: () => Navigator.pop(context),
                  ),
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
          onTap: () {
            Catalog().getSystemInfoList(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConstantData().page01,
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
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConstantData().page02,
                          ),
                        ),
                    textColor: Colors.black87,
                  ),
                  FlatButton(
                    child: Text(LocalizationData.of(context, Tag.privacy)),
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConstantData().page03,
                          ),
                        ),
                    textColor: Colors.black87,
                  ),
                ],
              ),
              padding: EdgeInsets.only(top: 40.0),
            ),
          ],
          applicationIcon: Image.asset(ConstantData().ilectIcon, scale: 6.5),
          applicationLegalese: LocalizationData.of(context, Tag.copyright),
          applicationName: ConstantData().title,
          applicationVersion: ConstantData().version,
          icon: Icon(Icons.info_outline),
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  _ErrorDialog(String str)
      : _bool = false,
        _input1 = str,
        _input2 = '',
        _override = false;
  _ErrorDialog.extended(String str1, String str2)
      : _bool = true,
        _input1 = str1,
        _input2 = str2,
        _override = false;
  _ErrorDialog.override(String str)
      : _bool = true,
        _input1 = str,
        _input2 = '',
        _override = true;

  final bool _bool, _override;
  final String _input1, _input2;

  @override
  Widget build(BuildContext context) {
    String _text =
        (_bool) ? _input1 : LocalizationData.of(context, Tag.error1) + _input1;
    var _dialog;
    (!Platform.isIOS || _override)
        ? _dialog = AlertDialog(
            actions: <Widget>[
              FlatButton(
                child: Text(
                  (_bool)
                      ? MaterialLocalizations.of(context).okButtonLabel
                      : MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel
                          .toUpperCase(),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
            content: Text(_text),
            title: (_override)
                ? null
                : (_bool)
                    ? Text(_input2)
                    : Row(
                        children: <Widget>[
                          Icon(Icons.warning, color: Colors.black54),
                          Text('  ' + LocalizationData.of(context, Tag.error0)),
                        ],
                      ),
          )
        : _dialog = CupertinoAlertDialog(
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
                        onTap: () => Navigator.pop(context),
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
              (_bool) ? _input2 : LocalizationData.of(context, Tag.error0),
            ),
          );
    return _dialog;
  }
}

class _FeedbackNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: LocalizationData.of(context, Tag.feedback4)),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConstantData().page04,
                        ),
                      ),
                style: TextStyle(color: Catalog().defaultColor),
                text: LocalizationData.of(context, Tag.feedback5),
              ),
              TextSpan(text: LocalizationData.of(context, Tag.feedback6)),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConstantData().page03,
                        ),
                      ),
                style: TextStyle(color: Catalog().defaultColor),
                text: LocalizationData.of(context, Tag.privacy),
              ),
              TextSpan(text: (Provider().isEN(context)) ? ' and ' : 'และ'),
              TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConstantData().page02,
                        ),
                      ),
                style: TextStyle(color: Catalog().defaultColor),
                text: LocalizationData.of(context, Tag.service),
              ),
              TextSpan(text: (Provider().isEN(context)) ? '.' : null),
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
      color: Catalog().tileColor,
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.symmetric(vertical: 10.0),
    );
  }
}

class _FeedbackScreenshotIOS extends StatelessWidget {
  _FeedbackScreenshotIOS(this._parent, File image) : _image = image;

  final _parent;
  final File _image;

  _getImage() async {
    var _img = await ImagePicker.pickImage(source: ImageSource.gallery);
    _parent.setState(() => _parent.image = _img);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                ListTile(
                  contentPadding: _image == null ? null : EdgeInsets.all(0.0),
                  leading: _image == null
                      ? null
                      : Image.file(
                          _image,
                          fit: BoxFit.cover,
                          height: 56.0,
                          width: 59.0,
                        ),
                  title: Text(
                    LocalizationData.of(context, Tag.feedback3),
                    style: TextStyle(fontSize: 15.0, letterSpacing: -0.5),
                  ),
                  trailing:
                      _image != null ? null : Icon(Icons.add_photo_alternate),
                ),
                Positioned(
                  child: _image == null
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

class _IndexCard extends StatelessWidget {
  _IndexCard(int i, List list)
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
                      style: Catalog()._textStyleCard(true),
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
    String _text =
        (_items[_index].name == null || _items[_index].name.trim().isEmpty)
            ? _items[_index].search
            : _items[_index].name;
    return Card(
      child: Stack(
        children: <Widget>[
          Padding(
            child: Column(
              children: <Widget>[
                Padding(
                  child: Image.network(
                    Provider().createImageUrl(_items[_index], _temp),
                  ),
                  padding: EdgeInsets.only(
                    bottom: 15.0,
                    left: 16.0,
                    right: 16.0,
                    top: 18.0,
                  ),
                ),
                Row(
                  children: Catalog().splitString(true, _text),
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

  void _launchAppAndroid(BuildContext context) async {
    String _str = LocalizationData.of(context, Tag.object0), _url;
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
    if (await canLaunch(_url)) {
      Fluttertoast.showToast(msg: _str);
      await launch(_url);
    } else {
      Catalog().showAlertErrorDialog(context, _url);
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
                ? _launchAppAndroid(context)
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Provider().dataPass(
                            _input1,
                            _input2,
                          ),
                    ),
                  );
          },
          splashColor: Color.fromARGB(30, 100, 100, 100),
        ),
        color: Colors.transparent,
      ),
    );
  }
}

class _SearchAlertDialog extends StatelessWidget {
  _SearchAlertDialog(BuildContext context, String str)
      : _context = context,
        _input = str;

  final BuildContext _context;
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
      Catalog().showAlertErrorDialog(_context, _url, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      actions: <Widget>[
        Divider(color: Colors.black45, height: 0.5),
        Stack(
          children: <Widget>[
            CupertinoDialogAction(
              child: Text(
                LocalizationData.of(context, Tag.search3) + ' App Store',
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
        Divider(color: Colors.black45, height: 0.0),
        Stack(
          children: <Widget>[
            CupertinoDialogAction(
              child: Text(
                (Provider().isEN(context))
                    ? 'Cancel'
                    : MaterialLocalizations.of(context).cancelButtonLabel,
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
      content: Text(
        LocalizationData.of(context, Tag.search1) +
            _input +
            LocalizationData.of(context, Tag.search2),
      ),
      title: Text(LocalizationData.of(context, Tag.search0) + ' \“$_input\”?'),
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
        _launchUrl(context, ConstantData().amapsUrl + _path);
        break;
      case ConstantData.gmaps:
        (await canLaunch(ConstantData().gmapsApp))
            ? _launchUrl(
                context,
                ConstantData().gmapsApp + _path,
              )
            : Catalog().showAlertErrorDialog(
                context,
                ConstantData.gmaps,
                true,
              );
        break;
      case ConstantData.chrome:
        (await canLaunch(ConstantData().chromeApp))
            ? _launchUrl(
                context,
                ConstantData().chromeApp + str.substring(8) + _path,
              )
            : Catalog().showAlertErrorDialog(
                context,
                'Google ' + ConstantData.chrome,
                true,
              );
        break;
      case ConstantData.safari:
        if (await canLaunch(ConstantData().gmapsApp) &&
            str == ConstantData().gmapsUrl) {
          _showSnackBar(context, ConstantData.gmaps);
          Timer(
            Duration(milliseconds: 1000),
            () => _launchUrl(context, str + _path),
          );
        } else if (await canLaunch(ConstantData().youtubeApp) &&
            str == ConstantData().youtubeUrl) {
          _showSnackBar(context, ConstantData.youtube);
          Timer(
            Duration(milliseconds: 1000),
            () => _launchUrl(context, str + _path),
          );
        } else {
          _launchUrl(context, str + _path);
        }
        break;
      case ConstantData.youtube:
        (await canLaunch(ConstantData().youtubeApp))
            ? _launchUrl(
                context,
                ConstantData().youtubeApp + _path,
              )
            : Catalog().showAlertErrorDialog(
                context,
                ConstantData.youtube,
                true,
              );
        break;
    }
  }

  void _launchUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
    } else {
      Catalog().showAlertErrorDialog(context, url, false);
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
                LocalizationData.of(context, Tag.search4) + str,
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
          child: Divider(color: Catalog().dividerColor, height: 1.0),
          padding: EdgeInsets.only(left: 90.0),
        ),
      ],
    );
  }
}

class _SystemInfoListTile extends StatefulWidget {
  _SystemInfoListTile({Key key, @required this.context, @required this.input})
      : super(key: key);

  final BuildContext context;
  final String input;

  _SystemInfoListTileState createState() =>
      _SystemInfoListTileState(context, input);
}

class _SystemInfoListTileState extends State<_SystemInfoListTile> {
  _SystemInfoListTileState(BuildContext context, String str)
      : _context = context,
        _input = str;
  _SystemInfoListTileState.override()
      : _context = null,
        _input = '';

  final BuildContext _context;
  final String _input;
  static var _appName = '?',
      _appIdentifier = '?',
      _appVersion = '?',
      _batteryLevel = '?',
      _batteryState = '?',
      _dateTime = '?',
      _deviceModel = '?',
      _deviceOSVersion = '?';

  static List _systemInfoStaticList(BuildContext context) {
    var _items = List(), _tags = List();
    _getStaticInfo(context);
    _dateTime = Provider().getDateTime(context);
    for (int i = 0; i < Tag.values.length; i++) {
      for (int j = 0; j < 9; j++) {
        if (Tag.values[i].toString().contains('sysinfo$j'))
          _tags.add(Tag.values[i]);
      }
    }
    for (int i = 0; i < _tags.length * 2; i++) {
      int _j = i ~/ 2;
      String _text;
      switch (i) {
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
          _text = LocalizationData.of(context, _tags[_j]);
          break;
      }
      _items.add(_text);
    }
    return _items;
  }

  static void _getStaticInfo(BuildContext context) {
    final _battery = Battery(), _deviceInfo = DeviceInfoPlugin();
    (!Platform.isIOS)
        ? _deviceInfo.androidInfo.then((info) {
            _deviceModel = info.model;
            _deviceOSVersion = info.version.release;
          })
        : _deviceInfo.iosInfo.then((info) {
            _deviceModel = info.utsname.machine;
            _deviceOSVersion = info.systemVersion;
          });
    PackageInfo.fromPlatform().then((info) {
      _appName = info.appName;
      _appIdentifier = info.packageName;
      _appVersion = info.version;
    });
    _battery.batteryLevel.then((level) {
      _batteryLevel = level.toString();
    });
    _battery.onBatteryStateChanged.listen((state) {
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
    });
  }

  List _systemInfoDynamicList(BuildContext context) {
    Timer(Duration(milliseconds: 500), () => setState(() {}));
    return _systemInfoStaticList(context);
  }

  @override
  Widget build(BuildContext context) {
    int _idx = _systemInfoDynamicList(context).indexOf(_input);
    return (_idx % 2 != 0)
        ? Container()
        : ListTile(
            subtitle: Text(_systemInfoDynamicList(context)[_idx + 1]),
            title: Text(_input),
          );
  }
}
