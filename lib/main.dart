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
      data: (theme) => ThemeData(
            cursorColor: Catalog().defaultColor,
            primaryColor: Colors.white,
          ),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          builder: (context, navigator) {
            String _lang = Localizations.localeOf(context).languageCode;
            return Theme(
              child: navigator,
              data: ThemeData(
                cursorColor: Catalog().defaultColor,
                primaryColor: Colors.white,
                textTheme: (!Platform.isIOS || _lang != 'th')
                    ? null
                    : TextTheme(
                        button: TextStyle(fontWeight: FontWeight.w500),
                        title: TextStyle(fontWeight: FontWeight.w500),
                      ),
              ),
            );
          },
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

class FeedbackPage extends StatefulWidget {
  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State.
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

class FeedbackPageState extends State<FeedbackPage> {
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _emailFocus = FocusNode();
  final _feedbackFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  int _i = 0;
  File image;
  String _note, _warning;
  var _sendIconColor = Colors.grey;

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
      Catalog().setCursorColor(context, Catalog().defaultColor);
      setState(() {
        _sendIconColor = MaterialColor(
          0xFF000000,
          <int, Color>{900: Color(0xFF000000)},
        );
      });
    } else {
      if (_feedbackFocus.hasFocus && _i > 0) {
        Catalog().setCursorColor(context, Catalog().errorColor);
      } else {
        Catalog().setCursorColor(context, Catalog().defaultColor);
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
      Catalog().setCursorColor(context, Catalog().defaultColor);
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
      Catalog().setCursorColor(context, Catalog().errorColor);
    }
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
              var iconButton = IconButton(
                color: _sendIconColor,
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  } else {
                    _i++;
                    Catalog().showWarningDialog(
                      context,
                      'Write your feedback before sending',
                      override: true,
                    );
                    Catalog().setCursorColor(context, Catalog().errorColor);
                  }
                },
              );
              return iconButton;
            },
          ),
        ],
        leading: IconButton(
          icon: Catalog().setBackIcon(),
          onPressed: () {
            Catalog().setCursorColor(context, Catalog().defaultColor);
            Navigator.of(context).maybePop();
          },
        ),
//        elevation: (!Platform.isIOS) ? null : 0.5,
        title: Text(Catalog().feedbackSubString(context)),
      ),
      body: Form(
        child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints scrollableConstraints,
          ) {
            return SingleChildScrollView(
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
                      Catalog().feedbackScreenshotIOS(this, image),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                ),
                constraints: BoxConstraints(
                  minHeight: scrollableConstraints.maxHeight,
                ),
              ),
            );
          },
        ),
        key: _formKey,
      ),
      bottomNavigationBar: Catalog().feedbackNote(),
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

  void onIndexAdded(Event event) {
    // This call to setState tells the Flutter framework that something has
    // changed in this State, which causes it to rerun the build method below
    // so that the display can reflect the updated values. If we changed
    // without calling setState(), then the build method would not be
    // called again, and so nothing would appear to happen.
    setState(() => _items.add(CardData.fromSnapshot(event.snapshot)));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the method above.
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Scrollbar(
        child: GridView.count(
          children: List.generate(
            _items.length,
            (i) => Catalog().indexCard(i, _items),
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

  void onObjectAdded(Event event) {
    setState(() => _items.add(CardData.fromSnapshot(event.snapshot)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: ListView(
          children: List.generate(
            _items.length,
            (i) => Catalog().objectCard(i, _items),
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
