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

  List _getSystemInfoList(BuildContext context) =>
      _SystemInfoListTileState.override()._systemInfoDynamicList(context);

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
    for (int _i = 0; _i < _listString.length; _i++) {
      if (_listString[_i].contains(ConstantData().thaiPattern)) {
        _listText.add(
          Text(
            _listString[_i],
            style: (b) ? _textStyleCard(false) : _textStyleSubtitle(),
          ),
        );
      } else {
        _listText.add(
          Text(
            _listString[_i],
            style: (b)
                ? TextStyle(
                    fontSize: 30.0,
                    letterSpacing: (!Platform.isIOS) ? null : -1.0,
                  )
                : _textStyleSubtitleNonIOS(),
          ),
        );
      }
      if (_i < _listString.length - 1) {
        String _space;
        (b)
            ? _space = String.fromCharCode(0x00A0) + String.fromCharCode(0x00A0)
            : _space = String.fromCharCode(0x00A0);
        _listText.add(Text(_space));
      }
    }
    return _listText;
  }

  List<Widget> systemInfoList(BuildContext context) {
    var _items = List<Widget>(), _list = _getSystemInfoList(context);
    for (var _e in _list) {
      _items.add(_SystemInfoListTile(context: context, input: _e));
    }
    return _items;
  }

  TextStyle _textStyleBottomAppBar(BuildContext context, String str) =>
      (str != ConstantData().title && Platform.isIOS)
          ? TextStyle(
              fontFamily: ConstantData().font,
              fontSize: 30.0,
              height: 1.5,
            )
          : Theme.of(context).textTheme.title;

  TextStyle _textStyleCard([bool b]) => (!Platform.isIOS)
      ? TextStyle(fontSize: 30.0)
      : (b)
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

  TextStyle _textStyleSubtitle() => (!Platform.isIOS)
      ? _textStyleSubtitleNonIOS()
      : TextStyle(
          color: CupertinoColors.inactiveGray,
          fontFamily: ConstantData().font,
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          height: 1.45,
        );

  TextStyle _textStyleSubtitleNonIOS() => TextStyle(
        color: CupertinoColors.inactiveGray,
        fontSize: 17.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
      );

  Widget bottomAppBar(String str1, [String str2]) {
    if (str2 != null && str2.trim().isNotEmpty) _temp = str2;
    return _BottomAppBar(str1);
  }

  Widget bottomAppBarExtended(String str) {
    _temp = null;
    return _BottomAppBar.extended(str);
  }

  // (!Platform.isIOS) ? _FeedbackWidgetAndroid() :
  Widget feedbackWidget() => _FeedbackWidgetIOS();

  Widget cardWidget(int i, List list) => _CardWidget(i, list);

  Widget _setBackIcon() =>
      (!Platform.isIOS) ? Icon(Icons.arrow_back) : Icon(Icons.arrow_back_ios);

  void _setCursorColor(BuildContext context, Color color) =>
      DynamicTheme.of(context).setThemeData(
          ThemeData(cursorColor: color, primaryColor: Colors.white));

  void _showAlertErrorDialog(BuildContext context, String str, [bool b]) =>
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

  void showWarningDialog(BuildContext context, String str1,
      {String str2, bool override}) {
    bool _b = (override ?? false);
    (!Platform.isIOS || _b)
        ? showDialog(
            barrierDismissible: false,
            builder: (BuildContext context) => (_b)
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
                    icon: Catalog()._setBackIcon(),
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
            Catalog()._getSystemInfoList(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConstantData().page01),
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

class _FeedbackNoteIOS extends StatelessWidget {
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
              TextSpan(text: (!Provider().isEN(context)) ? 'และ' : ' and '),
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

  void _getImage() async {
    var _img = await ImagePicker.pickImage(source: ImageSource.gallery);
    _parent.setState(() => _parent.image = _img);
  }

  @override
  Widget build(BuildContext context) {
    bool _b = (_image == null);
    return Expanded(
      child: Column(
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                ListTile(
                  contentPadding: (_b) ? null : EdgeInsets.all(0.0),
                  leading: (_b)
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
                  trailing: (!_b) ? null : Icon(Icons.add_photo_alternate),
                ),
                Positioned(
                  child: (_b)
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

class _FeedbackWidgetIOS extends StatefulWidget {
  @override
  _FeedbackWidgetIOSState createState() => _FeedbackWidgetIOSState();
}

class _FeedbackWidgetIOSState extends State<_FeedbackWidgetIOS> {
  final _emailController = TextEditingController(),
      _emailFocus = FocusNode(),
      _feedbackController = TextEditingController(),
      _feedbackFocus = FocusNode(),
      _formKey = GlobalKey<FormState>();
  int _i = 0;
  File image;
  String _note, _warning;
  MaterialColor _sendIconColor = Colors.grey;

  @override
  void dispose() {
    _feedbackFocus.removeListener(_sendIconColorChange);
    _emailController.dispose();
    _feedbackController.dispose();
    _emailFocus.dispose();
    _feedbackFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(_sendIconColorChange);
  }

  _sendIconColorChange() {
    if (_feedbackController.text.trim().isNotEmpty) {
      Catalog()._setCursorColor(context, Catalog().defaultColor);
      setState(() {
        _sendIconColor = MaterialColor(
          0xFF000000,
          <int, Color>{900: Color(0xFF000000)},
        );
      });
    } else {
      if (_feedbackFocus.hasFocus && _i > 0) {
        Catalog()._setCursorColor(context, Catalog().errorColor);
      } else {
        Catalog()._setCursorColor(context, Catalog().defaultColor);
      }
      setState(() {
        _sendIconColor = Colors.grey;
      });
    }
  }

  String _validateEmail(String email) {
    final String _quotePattern = '^(\"|\“)([^"“”])+(\"|\”)@';
    bool _validate = true;

//    if (email.length < 254) {
//      _validate = true;
//    }

    for (int i = 0; i < email.length; i++) {
      int comparePos = i++;
      if (comparePos >= email.length) {
        break;
      }
      if (email[i] == '@') {
        if (email.substring(i).contains('"') ||
            email.substring(i).contains('“') ||
            email.substring(i).contains('”')) {
          _validate = false;
          break;
        }
      }
      if (email[i] == email[comparePos] &&
          email[i].contains('.') &&
          email[comparePos].contains('.')) {
        _validate = false;
      }
    }

    String _emailPattern = '';
//        '^(?!\.)(?!.*\.\.)(?!.*\.\$)*' +
//        '(((^\(([^@()[\]\\;:",<> ])*\))|' +
//        '(\(([^@()[\]\\;:",<> ])*\)@)|' +
//        '(^\"([^"\\]|\\["\\])*\")|' +
//        '[^@()[\]\\;:",<> ]|' +
//        '(?:\.[^@()[\]\\;:",<> ])){0,64}@' +
//        '((?!\-)(?!\-*\-\$)*' +
//        '((\(([^@()[\]\\;:",<> ])*\))*' +
//        '((((?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])*\.)*(?:[a-z]*))|' +
//        '([^\w@()[\]\\;:",<> ]*))(\(([^@()[\]\\;:",<> ])*\))*\$)|' +
//        '(\[([\w\d:.])*\]\$)))){0,254}\$';
//
//        "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
//        "\\@" +
//        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
//        "(" +
//        "\\." +
//        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
//        ")+";
//
//   pattern checking sample emails
//    -- pass --
//    simple@example.com
//    สมรัก@จดหมาย.ไทย
//    very.common@example.com
//    ยอด.รัก@จดหมาย.ไทย
//    john.doe@example.com
//    disposable.style.email.with+symbol@example.com
//    other.email-with-hyphen@example.com
//    fully-qualified-domain@example.com
//    user.name+tag+sorting@example.com
//    (may go to user.name@example.com inbox depending on mail server)
//    x@example.com (one-letter local-part)
//    example-indeed@strange-example.com
//    #!$%&'*+-/=?^_`{}|~@example.org
//    example@s.example (see the List of Internet top-level domains)
//    user@[2001:DB8::1]
//    jsmith@[192.168.2.1]
//    jsmith@[IPv6:2001:db8::1]
//    " "@example.org
//    "John..Doe"@example.com
//    "John...Doe"@example.com
//    "John....Doe"@example.com
//    ".JohnDoe"@example.com
//    "..JohnDoe"@example.com
//    "...JohnDoe"@example.com
//    "....JohnDoe"@example.com
//    "JohnDoe."@example.com
//    "JohnDoe.."@example.com
//    "JohnDoe..."@example.com
//    "JohnDoe...."@example.com
//    john.smith(comment)@example.com
//    (comment)john.smith@example.com
//    john.smith@(comment)example.com
//    john.smith@example.com(comment)
//    "Abc@def"@example.com
//    "Fred Bloggs"@example.com
//    customer/department=shipping@example.com
//    $A12345@example.com
//    !def!xyz%abc@example.com
//    _somename@example.com

//    -- not pass --
//    admin@mailserver1
//    (local domain name with no TLD,
//    although ICANN highly discourages dotless email addresses)
//    "very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual"@strange.example.com
//    "()<>[]:,;@\\\"!#$%&'-/=?^_`{}| ~.a"@example.org
//    Abc.example.com (no @ character)
//    A@b@c@example.com (only one @ is allowed outside quotation marks)
//    Abc\@def@example.com
//    a"b(c)d,e:f;g<h>i[j\k]l@example.com
//    (none of the special characters in this local-part are allowed outside quotation marks)
//    just"not"right@example.com
//    (quoted strings must be dot separated or the only element making up the local-part)
//    this is"not\allowed@example.com
//    (spaces, quotes, and backslashes may only exist when within quoted strings
//    and preceded by a backslash)
//    this\ still\"not\\allowed@example.com
//    (even if escaped (preceded by a backslash), spaces, quotes, and
//    backslashes must still be contained by quotes)
//    Fred\ Bloggs@example.com
//    Joe.\\Blow@example.com
//    1234567890123456789012345678901234567890123456789012345678901234+x@example.com
//    (local part is longer than 64 characters)
//    .john.doe@example.com
//    ..john.doe@example.com
//    ...john.doe@example.com
//    ....john.doe@example.com
//    john..doe@example.com (double dot before @)
//    john...doe@example.com (n dot before @)
//    john....doe@example.com (n dot before @)
//    john.doe.@example.com
//    john.doe..@example.com
//    john.doe...@example.com
//    john.doe....@example.com
//    john.doe@.example.com
//    john.doe@..example.com
//    john.doe@...example.com
//    john.doe@....example.com
//    john.doe@example..com (double dot after @)
//    john.doe@example...com (n dot after @)
//    john.doe@example....com (n dot after @)
//    john.doe@example.com.
//    john.doe@example.com..
//    john.doe@example.com...
//    john.doe@example.com....
//    ".JohnDoe@example.com
//    "..JohnDoe@example.com
//    "...JohnDoe@example.com
//    "....JohnDoe@example.com
//    "John.Doe@example.com
//    "John..Doe@example.com
//    "John...Doe@example.com
//    "John....Doe@example.com
//    "JohnDoe.@example.com
//    "JohnDoe..@example.com
//    "JohnDoe...@example.com
//    "JohnDoe....@example.com
//    .JohnDoe"@example.com
//    ..JohnDoe"@example.com
//    ...JohnDoe"@example.com
//    ....JohnDoe"@example.com
//    John.Doe"@example.com
//    John..Doe"@example.com
//    John...Doe"@example.com
//    John....Doe"@example.com
//    JohnDoe."@example.com
//    JohnDoe.."@example.com
//    JohnDoe..."@example.com
//    JohnDoe...."@example.com

//    if (RegExp(_emailPattern).hasMatch(email)) return null;
    if (_validate) return null;
    return 'Your address is invalid.';
  }

  // https://www.freecodecamp.org/forum/t/how-to-validate-forms-and-
  // user-input-the-easy-way-using-flutter/190377
  void _optionalValidateEmail(String email) {
    if (_validateEmail(email) == null) {
      _warning = null;
      Catalog()._setCursorColor(context, Catalog().defaultColor);
      if ((email.substring(0, email.indexOf('@')).length > 32) ||
          (email.substring(email.indexOf('@')).length > 32)) {
        _note =
            'Your address maybe too long.\nPlease consider using another address.';
      } else {
        _note = null;
      }
      _emailFocus.unfocus();
      FocusScope.of(context).requestFocus(_feedbackFocus);
    } else {
      _warning = _validateEmail(email);
      Catalog()._setCursorColor(context, Catalog().errorColor);
    }
  }

  String _feedbackSubString(BuildContext context) {
    String _feedback, _lang = Localizations.localeOf(context).languageCode;
    (Platform.isIOS && _lang == 'en')
        ? _feedback = LocalizationData.of(context, Tag.feedback).substring(5)
        : _feedback = LocalizationData.of(context, Tag.feedback);
    return _feedback;
  }

  void _invalidateHandleTap() {
    bool _a = _emailController.text.trim().isEmpty,
        _b = _feedbackController.text.trim().isEmpty;
    FocusNode _focus;
    String _text;
    if (_a || _b) {
      if (_a) {
        _focus = _emailFocus;
        _text = LocalizationData.of(context, Tag.feedback7);
      } else if (_b) {
        _focus = _feedbackFocus;
        _text = LocalizationData.of(context, Tag.feedback8);
      }
//      Catalog().showWarningDialog(context, _text, override: true);
      Catalog()._setCursorColor(context, Catalog().errorColor);
      FocusScope.of(context).requestFocus(_focus);
    } else {
      Catalog()._setCursorColor(context, Catalog().defaultColor);
    }

//    if (_feedbackController.text.trim().isNotEmpty) {
//    } else {
//      Catalog().showWarningDialog(context, _text, override: true);
//
////      if (_feedbackFocus.hasFocus && _i > 0) {
////        Catalog().setCursorColor(context, Catalog().errorColor);
////      } else {
////        Catalog().setCursorColor(context, Catalog().defaultColor);
////      }
//    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Builder(
            // Create an inner BuildContext so that the onPressed method
            // can refer to the Scaffold with Scaffold.of().
            builder: (BuildContext context) {
              return IconButton(
                color: _sendIconColor,
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  } else {
                    _i++;
                    _invalidateHandleTap();
                  }
                },
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Catalog()._setBackIcon(),
          onPressed: () {
            Catalog()._setCursorColor(context, Catalog().defaultColor);
            Navigator.of(context).maybePop();
          },
        ),
//        elevation: (!Platform.isIOS) ? null : 0.5,
        title: Text(_feedbackSubString(context)),
      ),
      body: Form(
        child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints scrollableConstraints,
          ) {
            return Scrollbar(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  child: IntrinsicHeight(
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        LocalizationData.of(
                                            context, Tag.feedback0),
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
                                              controller: _emailController,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 5.0,
                                                        vertical: 7.5),
                                                errorText: _warning,
                                                helperText: _note,
                                                hintStyle: TextStyle(
                                                  color: Colors.black26,
                                                  letterSpacing: -0.5,
                                                ),
                                                hintText: LocalizationData.of(
                                                    context, Tag.feedback1),
                                              ),
                                              focusNode: _emailFocus,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              maxLines: null,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14.5),
                                              textInputAction:
                                                  TextInputAction.next,
                                              validator: _validateEmail,
                                            ),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.only(left: 55.0),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.only(
                                  left: 20.0,
                                  top: 10.15,
                                  right: 20.0,
                                  bottom: 0.0,
                                ), //.all(20.0),
                              ),
                              Padding(
                                child: Divider(
                                    color: Color(0xFFBCBBC1), height: 0.0),
                                padding: EdgeInsets.only(top: 11.25),
                              ),
                              Padding(
                                child: TextFormField(
                                  controller: _feedbackController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 7.5),
//                  focusedBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.black54),
//                  ),
                                    hintStyle: TextStyle(
                                      color: Colors.black54,
                                      letterSpacing: -0.5,
                                    ),
                                    hintText: LocalizationData.of(
                                        context, Tag.feedback2),
                                  ),
                                  focusNode: _feedbackFocus,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.5,
                                  ),
//                style: TextStyle(color: Colors.black, fontSize: 20.0),
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value.isEmpty) return '';
                                  },
                                ),
                                padding: EdgeInsets.only(
                                    left: 20.0, right: 20.0, top: 8.32),
                              ),
                            ],
                          ),
                          flex: 0,
                        ),
                        _FeedbackScreenshotIOS(this, image),
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
    );
  }
}

class _CardWidget extends StatelessWidget {
  _CardWidget(int i, List list)
      : _index = i,
        _items = list;

  final int _index;
  final List<CardData> _items;

  @override
  Widget build(BuildContext context) {
    bool _b = (_temp != null && _temp.trim().isNotEmpty);
    String _text =
        (_items[_index].name == null || _items[_index].name.trim().isEmpty)
            ? _items[_index].search
            : _items[_index].name;
    return Card(
      child: Stack(
        children: <Widget>[
          (!_b)
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
                ), // ObjectCard
          _RippleCardEffect(
            (!_b) ? _items[_index].name : _items[_index].search,
            _temp,
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
      Catalog()._showAlertErrorDialog(context, _url);
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
                      builder: (context) =>
                          Provider().dataPass(_input1, _input2),
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
            ? _launchUrl(context, ConstantData().gmapsApp + _path)
            : Catalog()._showAlertErrorDialog(
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
            : Catalog()._showAlertErrorDialog(
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
            ? _launchUrl(context, ConstantData().youtubeApp + _path)
            : Catalog()._showAlertErrorDialog(
                context,
                ConstantData.youtube,
                true,
              );
        break;
    }
  }

  void _launchUrl(BuildContext context, String url) async =>
      (await canLaunch(url))
          ? await launch(url, forceSafariVC: false)
          : Catalog()._showAlertErrorDialog(context, url, false);

  void _showSnackBar(BuildContext context, String str) {
    var _snackBar = SnackBar(
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
    _getStaticInfo(context);
    _dateTime = Provider().getDateTime(context);
    for (int _i = 0; _i < Tag.values.length; _i++) {
      for (int _j = 0; _j < 9; _j++) {
        if (Tag.values[_i].toString().contains('sysinfo' + _j.toString()))
          _tags.add(Tag.values[_i]);
      }
    }
    for (int _i = 0; _i < _tags.length * 2; _i++) {
      int _j = _i ~/ 2;
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
    _battery.batteryLevel.then((level) => _batteryLevel = level.toString());
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
            subtitle: Text(_systemInfoDynamicList(context)[++_idx]),
            title: Text(_input),
          );
  }
}
