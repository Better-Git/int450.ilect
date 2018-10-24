import 'dart:async' show Stream;
import 'dart:io' show InternetAddress, Platform;
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, Event, FirebaseDatabase;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart'
    show BuildContext, Locale, Localizations, LocalizationsDelegate;
import 'package:ilect_app/catalog.dart' show Catalog;
import 'package:ilect_app/main.dart'
    show FeedbackPage, PPPage, SecondPage, SystemInfoPage, ThirdPage, ToSPage;
import 'package:intl/intl.dart' show DateFormat;

class CardData {
  String id, name, pic, search, token;

  CardData.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    name = snapshot.value['name'];
    pic = snapshot.value['pic'];
    search = snapshot.value['search'];
    token = snapshot.value['token'];
  }
}

class ConstantData {
  static const String
      // Category titles
      eat = 'กิน',
      go = 'ไป',
      listen = 'ฟัง',
      watch = 'ดู',

      // Icon titles
      amaps = 'Maps',
      chrome = 'Chrome',
      gmaps = 'Google Maps',
      safari = 'Safari',
      youtube = 'YouTube';
  final
      // Page instances
      page01 = FeedbackPage(),
      page02 = ToSPage(),
      page03 = PPPage(),
      page04 = SystemInfoPage();
  final Pattern
      // Regular expressions
      thaiPattern = RegExp(r'[ก-๙]');
  final String
      // Application title
      title = 'iLect',

      // Custom URL schemes
      chromeApp = 'googlechromes://',
      gmapsApp = 'googlemaps://?q=',
      youtubeApp = 'youtube:///results?q=',

      // External links
      amapsUrl = 'https://maps.apple.com/?q=',
      checkUrl = 'youtu.be',
      chromeAppStoreUrl =
          'https://itunes.apple.com/us/app/google-chrome/id535886823?mt=8',
      firebaseUrl =
          'https://firebasestorage.googleapis.com/v0/b/it58-20.appspot.com/o/',
      gmapsAppStoreUrl =
          'https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8',
      gmapsUrl = 'https://www.google.com/maps/search/',
      youtubeAppStoreUrl =
          'https://itunes.apple.com/us/app/youtube-watch-listen-stream/id544007664?mt=8',
      youtubeUrl = 'https://www.youtube.com/results?search_query=',

      // Firebase database schema titles
      schema0 = 'category',
      schema1 = 'eat',
      schema2 = 'go',
      schema3 = 'listen',
      schema4 = 'watch',

      // Font assets
      font = 'EucrosiaUPC',

      // Icon assets
      amapsIcon = 'assets/a_maps_icon.png',
      chromeIcon = 'assets/chrome_icon.png',
      gmapsIcon = 'assets/g_maps_icon.png',
      ilectIcon = 'assets/icon.png',
      safariIcon = 'assets/safari_icon.png',
      youtubeIcon = 'assets/youtube_icon.png',

      // Other textspans
      batteryState0 = 'Full',
      batteryState0TH = 'เต็ม',
      batteryState1 = 'Charging',
      batteryState1TH = 'กำลังชาร์จ',
      batteryState2 = 'Unplugged',
      batteryState2TH = 'ไม่ได้เสียบปลั๊ก',
      copyright =
          '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
      copyrightTH = '© 2561 คณะเทคโนโลยีสารสนเทศ, มจธ.\nสงวนลิขสิทธิ์',
      errorDialog0 = 'Error',
      errorDialog0TH = 'ข้อผิดพลาด',
      errorDialog1 = 'Unable to load this page: ',
      errorDialog1TH = 'ไม่สามารถโหลดหน้านี้ได้: ',
      errorDialog2 = 'No Internet Connection',
      errorDialog2TH = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
      errorDialog3 =
          ' requires an internet connection to function properly.\n\n',
      errorDialog3TH =
          ' จำเป็นต้องใช้อินเทอร์เน็ตเพื่อให้สามารถทำงานได้อย่างถูกต้อง\n\n',
      errorDialog4 = 'It seems that you have turned on the airplane mode. ' +
          'Please turn on Wi-Fi again or turn off this setting.',
      errorDialog4TH = 'ดูเหมือนว่าคุณมีการเปิดใช้งานโหมดเครื่องบินอยู่ ' +
          'กรุณาเปิดไวไฟอีกครั้งหรือปิดโหมดเครื่องบิน',
      errorDialog5 = 'Please check your network settings and try again.',
      errorDialog5TH = 'โปรดตรวจสอบการตั้งค่าเครือข่ายและลองใหม่อีกครั้ง',
      feedbackDialog0 = '',
      feedbackDialog0TH = '',
      feedbackDialog1 = 'Write your feedback before sending',
      feedbackDialog1TH = 'โปรดเขียนความคิดเห็นก่อนส่ง',
      feedbackNote0 =
          'In addition to account info or screenshot whether or not you provide. Some ',
      feedbackNote0TH =
          'นอกเหนือไปจากข้อมูลบัญชีหรือภาพหน้าจอที่คุณได้มีการให้เอาไว้หรือไม่ก็ตาม ',
      feedbackNote1 = 'app and system info',
      feedbackNote1TH = 'ข้อมูลแอปและระบบ',
      feedbackNote2 = ' on this device will be automatically included. ' +
          'We\'ll use it to address technical issues and improve our services, ' +
          'subject to our ',
      feedbackNote2TH = 'บางส่วนบนอุปกรณ์เครื่องนี้จะถูกส่งไปโดยอัตโนมัติ ' +
          'เราจะใช้ข้อมูลดังกล่าวมาเพื่อแก้ไขปัญหาด้านเทคนิคและปรับปรุงการให้บริการโดยเป็นไปตาม',
      feedbackPage0 = 'From:',
      feedbackPage0IOS = 'From',
      feedbackPage0TH = 'จาก',
      feedbackPage1 = 'Email (optional)',
      feedbackPage1TH = 'อีเมล (ไม่บังคับ)',
      feedbackPage2 = 'Write your feedback',
      feedbackPage2TH = 'เขียนความคิดเห็นของคุณ',
      feedbackPage3 = 'Screenshot',
      feedbackPage3TH = 'ภาพหน้าจอ',
      objectToast = 'Open ',
      objectToastTH = 'เปิด ',
      op = 'Offline Pictures',
      searchAlertButton = 'Show in',
      searchAlertButtonTH = 'แสดงใน',
      searchAlertDialog0 = 'Get',
      searchAlertDialog0TH = 'รับ',
      searchAlertDialog1 = 'You followed a link that requires the app \“',
      searchAlertDialog1TH = 'คุณได้เปิดลิงก์ที่ต้องใช้แอพ \“',
      searchAlertDialog2 = '\”, which is no longer on your device. ' +
          'You can get it from the App Store.',
      searchAlertDialog2TH =
          '\” แต่อุปกรณ์ของคุณไม่มีแอพนี้แล้ว คุณสามารถรับแอพได้จาก App Store',
      searchSnackBar = 'Redirect to ',
      searchSnackBarTH = 'กำลังเปิดไปยัง ',
      share =
          'ฉันได้ใช้แอป iLect แล้วนะ\nอยากจะให้เพื่อนๆมาลองใช้กัน\n\nดาวน์โหลดได้ที่ ...',
      sysinfo0 = 'Device model',
      sysinfo0TH = 'รุ่นของอุปกรณ์',
      sysinfo1 = 'OS version',
      sysinfo1TH = 'เวอร์ชันของระบบปฏิบัติการ',
      sysinfo2 = 'Application name',
      sysinfo2TH = 'ชื่อแอปพลิเคชัน',
      sysinfo3 = 'Application identifier',
      sysinfo3TH = 'ตัวระบุแอปพลิเคชัน',
      sysinfo4 = 'Application version',
      sysinfo4TH = 'เวอร์ชันของแอปพลิเคชัน',
      sysinfo5 = 'Time',
      sysinfo5TH = 'เวลา',
      sysinfo6 = 'Battery level',
      sysinfo6TH = 'ระดับแบตเตอรี่',
      sysinfo7 = 'Battery state',
      sysinfo7TH = 'สถานะแบตเตอรี่',
      sysinfo8 = 'Language',
      sysinfo8TH = 'ภาษา',
      version = '0.6',

      // Page titles
      feedback = 'Send Feedback',
      feedbackTH = 'ส่งความคิดเห็น',
      pp = 'Privacy Policy',
      ppTH = 'นโยบายความเป็นส่วนตัว',
      search = 'Open in',
      searchTH = 'เปิดใน',
      si = 'System information',
      siTH = 'ข้อมูลระบบ',
      tos = 'Terms of Service',
      tosTH = 'ข้อกำหนดในการให้บริการ';
}

class LocalizationData {
  LocalizationData(this._locale);

  final Locale _locale;
  Map<String, Map<Tag, String>> _localizedValues = {
    'en': {
      Tag.battery0: ConstantData().batteryState0,
      Tag.battery1: ConstantData().batteryState1,
      Tag.battery2: ConstantData().batteryState2,
      Tag.copyright: ConstantData().copyright,
      Tag.error0: ConstantData().errorDialog0,
      Tag.error1: ConstantData().errorDialog1,
      Tag.feedback: ConstantData().feedback,
      Tag.feedback0: (!Platform.isIOS)
          ? ConstantData().feedbackPage0
          : ConstantData().feedbackPage0IOS,
      Tag.feedback1: ConstantData().feedbackPage1,
      Tag.feedback2: ConstantData().feedbackPage2,
      Tag.feedback3: ConstantData().feedbackPage3,
      Tag.feedback4: ConstantData().feedbackNote0,
      Tag.feedback5: ConstantData().feedbackNote1,
      Tag.feedback6: ConstantData().feedbackNote2,
      Tag.feedback7: ConstantData().feedbackDialog0,
      Tag.feedback8: ConstantData().feedbackDialog1,
      Tag.object0: ConstantData().objectToast,
      Tag.privacy: ConstantData().pp,
      Tag.search: ConstantData().search,
      Tag.search0: ConstantData().searchAlertDialog0,
      Tag.search1: ConstantData().searchAlertDialog1,
      Tag.search2: ConstantData().searchAlertDialog2,
      Tag.search3: ConstantData().searchAlertButton,
      Tag.search4: ConstantData().searchSnackBar,
      Tag.service: ConstantData().tos,
      Tag.sysinfo: ConstantData().si,
      Tag.sysinfo0: ConstantData().sysinfo0,
      Tag.sysinfo1: ConstantData().sysinfo1,
      Tag.sysinfo2: ConstantData().sysinfo2,
      Tag.sysinfo3: ConstantData().sysinfo3,
      Tag.sysinfo4: ConstantData().sysinfo4,
      Tag.sysinfo5: ConstantData().sysinfo5,
      Tag.sysinfo6: ConstantData().sysinfo6,
      Tag.sysinfo7: ConstantData().sysinfo7,
      Tag.sysinfo8: ConstantData().sysinfo8,
      Tag.warning0: ConstantData().errorDialog2,
      Tag.warning1: ConstantData().title + ConstantData().errorDialog3,
      Tag.warning2: ConstantData().errorDialog4,
      Tag.warning3: ConstantData().errorDialog5,
    },
    'th': {
      Tag.battery0: ConstantData().batteryState0TH,
      Tag.battery1: ConstantData().batteryState1TH,
      Tag.battery2: ConstantData().batteryState2TH,
      Tag.copyright: ConstantData().copyrightTH,
      Tag.error0: ConstantData().errorDialog0TH,
      Tag.error1: ConstantData().errorDialog1TH,
      Tag.feedback: ConstantData().feedbackTH,
      Tag.feedback0: ConstantData().feedbackPage0TH,
      Tag.feedback1: ConstantData().feedbackPage1TH,
      Tag.feedback2: ConstantData().feedbackPage2TH,
      Tag.feedback3: ConstantData().feedbackPage3TH,
      Tag.feedback4: ConstantData().feedbackNote0TH,
      Tag.feedback5: ConstantData().feedbackNote1TH,
      Tag.feedback6: ConstantData().feedbackNote2TH,
      Tag.feedback7: ConstantData().feedbackDialog0TH,
      Tag.feedback8: ConstantData().feedbackDialog1TH,
      Tag.object0: ConstantData().objectToastTH,
      Tag.privacy: ConstantData().ppTH,
      Tag.search: ConstantData().searchTH,
      Tag.search0: ConstantData().searchAlertDialog0TH,
      Tag.search1: ConstantData().searchAlertDialog1TH,
      Tag.search2: ConstantData().searchAlertDialog2TH,
      Tag.search3: ConstantData().searchAlertButtonTH,
      Tag.search4: ConstantData().searchSnackBarTH,
      Tag.service: ConstantData().tosTH,
      Tag.sysinfo: ConstantData().siTH,
      Tag.sysinfo0: ConstantData().sysinfo0TH,
      Tag.sysinfo1: ConstantData().sysinfo1TH,
      Tag.sysinfo2: ConstantData().sysinfo2TH,
      Tag.sysinfo3: ConstantData().sysinfo3TH,
      Tag.sysinfo4: ConstantData().sysinfo4TH,
      Tag.sysinfo5: ConstantData().sysinfo5TH,
      Tag.sysinfo6: ConstantData().sysinfo6TH,
      Tag.sysinfo7: ConstantData().sysinfo7TH,
      Tag.sysinfo8: ConstantData().sysinfo8TH,
      Tag.warning0: ConstantData().errorDialog2TH,
      Tag.warning1: ConstantData().title + ConstantData().errorDialog3TH,
      Tag.warning2: ConstantData().errorDialog4TH,
      Tag.warning3: ConstantData().errorDialog5TH,
    },
  };

  static String of(BuildContext context, Tag tag) =>
      Localizations.of<LocalizationData>(context, LocalizationData)._get(tag);

  String _get(Tag tag) => _localizedValues[_locale.languageCode][tag];
}

enum Tag {
  battery0,
  battery1,
  battery2,
  copyright,
  error0,
  error1,
  feedback,
  feedback0,
  feedback1,
  feedback2,
  feedback3,
  feedback4,
  feedback5,
  feedback6,
  feedback7,
  feedback8,
  object0,
  privacy,
  search,
  search0,
  search1,
  search2,
  search3,
  search4,
  service,
  sysinfo,
  sysinfo0,
  sysinfo1,
  sysinfo2,
  sysinfo3,
  sysinfo4,
  sysinfo5,
  sysinfo6,
  sysinfo7,
  sysinfo8,
  warning0,
  warning1,
  warning2,
  warning3,
}

class LocalizationsDataDelegate
    extends LocalizationsDelegate<LocalizationData> {
  // Returning a SynchronousFuture here because an async "load" operation
  // isn't needed to produce an instance of LocalizationData.
  @override
  load(Locale locale) =>
      SynchronousFuture<LocalizationData>(LocalizationData(locale));

  @override
  bool isSupported(Locale locale) => ['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDataDelegate old) => false;
}

class Provider {
  dataPass(String str1, [String str2]) => (str2 == null || str2.trim().isEmpty)
      ? SecondPage(category: str1)
      : ThirdPage(name: str1, category: str2);

  bool isEN(BuildContext context) =>
      Localizations.localeOf(context).languageCode.contains('en');

//  bool isConnected() {
//    try {
//      var _result = checkInternetBase();
//      _result.then((val) {
//        String _res = val[0].rawAddress.join('.');
//        if (_res.trim().isNotEmpty) {
//          return true;
//        }
//      });
//    } on Exception {
//      return false;
//    }
//    return false;
//  }
//
//  checkInternetBase() async =>
//      await InternetAddress.lookup(ConstantData().checkUrl)
//          .timeout(Duration(seconds: 2));

  Stream<Event> cardDataStreamSubscription(String str) =>
      FirebaseDatabase.instance.reference().child(str).onChildAdded;

  String createImageUrl(CardData cd, [String str]) {
    String _dir,
        _media = '?alt=media&token=',
        _slash = '%2F',
        _url = ConstantData().firebaseUrl;
    (str == null || str.trim().isEmpty)
        ? _dir = ConstantData().schema0
        : _dir = selectSchema(str);
    return [_url, _dir, _slash, cd.pic, _media, cd.token].join();
  }

  String getDateTime(BuildContext context) {
    String _dateTime, _lang = Localizations.localeOf(context).languageCode;
    (_lang == 'th')
        ? _dateTime = DateFormat('dd/MM/').format(DateTime.now()) +
            (DateTime.now().year + 543).toString().substring(2) +
            DateFormat(' H นาฬิกา m นาที s วินาที').format(DateTime.now())
        : _dateTime = DateFormat('dd/MM/yyyy').format(DateTime.now()) +
            DateFormat(' HH:mm:ss').format(DateTime.now());
    _dateTime += ' GMT' +
        DateTime.now().timeZoneName.substring(0, 1) +
        int.parse(DateTime.now().timeZoneName.substring(1)).toString();
    return _dateTime;
  }

  String selectSchema(String str) {
    switch (str) {
      case ConstantData.eat:
        str = ConstantData().schema1;
        break;
      case ConstantData.go:
        str = ConstantData().schema2;
        break;
      case ConstantData.listen:
        str = ConstantData().schema3;
        break;
      case ConstantData.watch:
        str = ConstantData().schema4;
        break;
    }
    return str;
  }

  void checkInternet(BuildContext context) async {
    if (!Platform.isIOS)
      try {
        await InternetAddress.lookup(ConstantData().checkUrl).timeout(
          Duration(seconds: 2),
        );
      } on Exception {
        String _connection;
        var _result = await Connectivity().checkConnectivity();
        (_result != ConnectivityResult.mobile &&
                _result != ConnectivityResult.wifi)
            ? _connection = LocalizationData.of(context, Tag.warning2)
            : _connection = LocalizationData.of(context, Tag.warning3);
        Catalog().showWarningDialog(
          context,
          LocalizationData.of(context, Tag.warning0),
          str2: LocalizationData.of(context, Tag.warning1) + _connection,
        );
      }
  }
}
