import 'dart:async' show Timer;
import 'dart:io' show File, Platform;

import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'provider.dart';

String _query;

class Catalog {
  List _systemInfoList(BuildContext context) =>
      _SystemInfoListTileState.override()._systemInfoDynamicList(context);

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
    for (var _e in _list) {
      _items.add(_SystemInfoListTile(content: _e, context: context));
    }
    return _items;
  }

  TextStyle _textStyleBottomAppBar(BuildContext context, String message) {
    return (!Platform.isIOS || (message == ConstantData().title))
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

  Widget feedbackWidget() => _FeedbackWidget();

  Widget cardWidget(int i, List list, [String category]) =>
      _CardWidget(i, list, category);

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

  void showWarningDialog(BuildContext context, String content,
      {bool override, bool warning, String title}) {
    (!Platform.isIOS || (override ?? false))
        ? showDialog(
            barrierDismissible: (warning ?? true) ? false : true,
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

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Container(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                  builder: (_) => _BottomDrawer(),
                  context: context,
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
                    onPressed: () =>
                        Share.share(LocalizationData.of(context, Tag.share)),
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
//          title: Text(offline),
//          value: _downloaded,
//        ),
//        Divider(height: 1.0),
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
                onPressed: () => Navigator.pop(context),
              )
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
              (_isExtended) ? _title : LocalizationData.of(context, Tag.error0),
            ),
          );
  }
}

class _FeedbackFieldIOS extends StatelessWidget {
  _FeedbackFieldIOS(this._parent);

  final _parent;

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
//                focusedBorder: UnderlineInputBorder(
//                  borderSide: BorderSide(color: Colors.black54),
//                ),
                hintStyle: TextStyle(
                  color: Colors.black54,
                  letterSpacing: -0.5,
                ),
                hintText: LocalizationData.of(context, Tag.feedback3),
              ),
              focusNode: _parent._feedbackFocus,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: TextStyle(color: Colors.black, fontSize: 16.5),
//              style: TextStyle(color: Colors.black, fontSize: 20.0),
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
  _FeedbackScreenshotIOS(this._parent, File image) : _image = image;

  final _parent;
  final File _image;

  void _getImage() async {
    File _img = await ImagePicker.pickImage(source: ImageSource.gallery);
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
  bool _isCursorDirty = false, _isEmailValid = false, _isFeedbackDirty = false;
  Color _sendIconColor = Colors.grey;
  File _image;
  String _note, _warning;

  _onBackPressed() {
    _isCursorDirty = false;
    _isEmailValid = false;
    _isFeedbackDirty = false;
    Catalog()._cursorColor(context, ConstantData().defaultColor);
    Navigator.pop(context);
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
    if (_hextets.every((value) => value.length < 5) &&
        _allocatedPrefixes.contains(_hextets[0])) {
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
                (_hextets[1] != '0db8')) continue validCase;
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
    if (localPart.length < 65) {
      // Validate dot-string
      if (!localPart.startsWith(ConstantData().nonLocalPattern) &&
          !localPart[localPart.length - 1].contains(
            ConstantData().nonLocalPattern,
          ) &&
          localPart.split('').every(
                (value) => !value.contains(ConstantData().nonLocalPattern),
              )) {
        if (localPart.length > 1) {
          for (int _i = 0; _i < localPart.length; _i++) {
            if ((_i + 1 >= localPart.length)) break;
            String _check = localPart[_i] + localPart[_i + 1];
            if ('.'.allMatches(_check).length > 1) {
              break;
            } else {
              return true;
            }
          }
        } else {
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
                (_email.substring(_realAtSignIndex).length > 32))
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
    (_isEmailValid && _isFeedbackNotEmpty)
        ? setState(() => _sendIconColor = Colors.black)
        : setState(() => _sendIconColor = Colors.grey);
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
    _onBackPressed();
  }

  @override
  void dispose() {
    _emailController.removeListener(
      () => _validateEmail(_emailController.text),
    );
    _emailController.removeListener(_cursorSendIconColor);
    _feedbackController.removeListener(_cursorSendIconColor);
    _emailController.dispose();
    _feedbackController.dispose();
    _emailFocus.dispose();
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
      onWillPop: () => _onBackPressed(),
    );
  }
}

class _CardWidget extends StatelessWidget {
  _CardWidget(int i, List list, [String category])
      : _index = i,
        _items = list,
        _category = category;

  final int _index;
  final List<CardData> _items;
  final String _category;

  @override
  Widget build(BuildContext context) {
    bool _hasCategory = (_category != null && _category.trim().isNotEmpty);
    String _text =
        (_items[_index].name == null || _items[_index].name.trim().isEmpty)
            ? _items[_index].keyword
            : _items[_index].name;
    return Card(
      child: Stack(
        children: <Widget>[
          (!_hasCategory)
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
                      Row(
                        children: Catalog().toSplitString(true, _text),
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(15.0),
                ), // ObjectCard
          _RippleCardEffect(
            (!_hasCategory) ? _items[_index].name : _items[_index].keyword,
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
}

class _RippleCardEffect extends StatelessWidget {
  _RippleCardEffect(String message, [String category])
      : _category = category,
        _message = message;

  final String _category, _message;

  void _launchAppAndroid(BuildContext context) async {
    String _message = LocalizationData.of(context, Tag.toast), _url;
    switch (_category) {
      case ConstantData.eating:
      case ConstantData.going:
        _message += ConstantData.gmaps;
        _url = ConstantData().gmapsUrl + _query;
        break;
      case ConstantData.listening:
      case ConstantData.watching:
        _message += ConstantData.youtube;
        _url = ConstantData().youtubeUrl + _query;
        break;
    }
    if (await canLaunch(_url)) {
      Fluttertoast.showToast(msg: _message);
      await launch(_url);
    } else {
      Catalog()._showAlertErrorDialog(context, _url, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
          onTap: () {
            bool _hasCategory =
                (_category != null && _category.trim().isNotEmpty);
            if (_hasCategory) _query = _message;
            (!Platform.isIOS && _hasCategory)
                ? _launchAppAndroid(context)
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Provider().passData(_message, _category),
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
  _SearchAlertDialog(BuildContext context, String content)
      : _context = context,
        _content = content;

  final BuildContext _context;
  final String _content;

  void _selectAppStoreUrl() async {
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
    (await canLaunch(_url))
        ? await launch(_url)
        : Catalog()._showAlertErrorDialog(_context, _url, false);
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

  _searchListTileStaticList() async {
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

  List<Widget> _searchListTileDynamicList() {
    Timer(
      Duration(microseconds: 1),
      () {
        if (_parent.mounted) {
          _parent.setState(() {
            _searchListTileStaticList();
          });
        }
      },
    );
    return _finalList;
  }

  void _launchAppIOS(BuildContext context) async {
    String _path = Uri.encodeFull(_query);
    switch (_title) {
      case ConstantData.amaps:
        _launchUrl(context, ConstantData().amapsUrl + _path);
        break;
      case ConstantData.gmaps:
        (await canLaunch(ConstantData().gmapsApp))
            ? _launchUrl(context, ConstantData().gmapsApp + _path)
            : Catalog()._showAlertErrorDialog(
                context,
                ConstantData.gmaps,
              );
        break;
      case ConstantData.chrome:
        (await canLaunch(ConstantData().chromeApp))
            ? _launchUrl(
                context,
                ConstantData().chromeApp + _content.substring(8) + _path,
              )
            : Catalog()._showAlertErrorDialog(
                context,
                'Google ${ConstantData.chrome}',
              );
        break;
      case ConstantData.safari:
        _launchUrl(context, _content + _path);
        break;
      case ConstantData.youtube:
        (await canLaunch(ConstantData().youtubeApp))
            ? _launchUrl(context, ConstantData().youtubeApp + _path)
            : Catalog()._showAlertErrorDialog(
                context,
                ConstantData.youtube,
              );
        break;
    }
  }

  void _launchUrl(BuildContext context, String url) async {
    (await canLaunch(url))
        ? await launch(url, forceSafariVC: false)
        : Catalog()._showAlertErrorDialog(context, url, false);
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
  static String _appName = '?',
      _appIdentifier = '?',
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
    for (int _i = 0; _i < Tag.values.length; _i++) {
      for (int _j = 0; _j < 9; _j++) {
        if (Tag.values[_i].toString().contains('sysinfo${_j.toString()}'))
          _tags.add(Tag.values[_i]);
      }
    }
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
