import 'dart:async' show Stream;
import 'dart:io' show InternetAddress, Platform;

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, Event, FirebaseDatabase;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart'
    show
        BuildContext,
        Color,
        FontWeight,
        Locale,
        Localizations,
        LocalizationsDelegate,
        StatefulWidget,
        TextStyle,
        TextTheme,
        ThemeData;
import 'package:intl/intl.dart' show DateFormat;

import 'catalog.dart' show Catalog;
import 'main.dart'
    show
        FeedbackPage,
        PrivacyPolicyPage,
        SecondPage,
        SystemInfoPage,
        ThirdPage,
        ServiceTermsPage;

class CardData {
  String id, keyword, name, pic, token;

  CardData.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    keyword = snapshot.value['search'];
    name = snapshot.value['name'];
    pic = snapshot.value['pic'];
    token = snapshot.value['token'];
  }
}

class ConstantData {
  static const String
      // Category titles
      eating = 'กิน',
      going = 'ไป',
      listening = 'ฟัง',
      watching = 'ดู',

      // Icon titles
      amaps = 'Maps',
      chrome = 'Chrome',
      gmaps = 'Google Maps',
      safari = 'Safari',
      youtube = 'YouTube';
  final
      // Page instances
      feedbackPage = FeedbackPage(),
      privacyPage = PrivacyPolicyPage(),
      servicePage = ServiceTermsPage(),
      sysinfoPage = SystemInfoPage();
  final Color
      // Color assets
      defaultColor = Color(0xFF007AFF),
      dividerColor = Color(0xFFBCBBC1),
      errorColor = Color(0xFFB71C1C),
      tileColor = Color(0xFFF5F5F5);
  final Pattern
      // Regular expressions
      nonDomainPattern = RegExp(r'[\x00-\x40\x5B-\x60\x7B-\x7F]+'),
      nonLocalPattern = RegExp(r'[ \"(),.:;<>@[\\\]]+'),
      nonSubDomainPattern =
          RegExp(r'[\x00-\x2C\x2E\x2F\x3A-\x40\x5B-\x60\x7B-\x7F]+'),
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
      chromeAppStoreUrl =
          'https://itunes.apple.com/us/app/google-chrome/id535886823?mt=8',
      firebaseUrl =
          'https://firebasestorage.googleapis.com/v0/b/it58-20.appspot.com/o/',
      gmapsAppStoreUrl =
          'https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8',
      gmapsUrl = 'https://www.google.com/maps/search/',
      ilectAppStoreUrl = 'https://itunes.apple.com/us/app/',
      ilectPlayStoreUrl = 'https://play.google.com/store/apps/details?id=',
      testUrl = 'youtu.be',
      youtubeAppStoreUrl =
          'https://itunes.apple.com/us/app/youtube-watch-listen-stream/id544007664?mt=8',
      youtubeUrl = 'https://www.youtube.com/results?search_query=',

      // Firebase database schema titles
      schema0 = 'category',
      schema1 = 'eat',
      schema2 = 'go',
      schema3 = 'listen',
      schema4 = 'watch',

      // Font asset
      font = 'EucrosiaUPC',

      // Icon assets
      amapsIcon = 'assets/a_maps_icon.png',
      chromeIcon = 'assets/chrome_icon.png',
      gmapsIcon = 'assets/g_maps_icon.png',
      ilectIcon = 'assets/icon.png',
      safariIcon = 'assets/safari_icon.png',
      youtubeIcon = 'assets/youtube_icon.png',

      // Other text spans
      batteryState0 = 'Full',
      batteryState0TH = 'เต็ม',
      batteryState1 = 'Charging',
      batteryState1TH = 'กำลังชาร์จ',
      batteryState2 = 'Unplugged',
      batteryState2TH = 'ไม่ได้เสียบปลั๊ก',
      bottomAppBarTooltip0 = 'Back to home page',
      bottomAppBarTooltip0TH = 'กลับไปหน้าแรก',
      bottomAppBarTooltip1 = 'Share',
      bottomAppBarTooltip1TH = 'แชร์',
      copyright =
          '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
      copyrightTH = '© 2561 คณะเทคโนโลยีสารสนเทศ, มจธ.\nสงวนลิขสิทธิ์',
      dateFormat = 'dd/MM/yyyy',
      dateFormatTH = 'dd/MM/',
      errorDialog0 = 'Unable to load this page: ',
      errorDialog0TH = 'ไม่สามารถโหลดหน้านี้ได้: ',
      errorDialog1 =
          ' requires an internet connection to function properly.\n\n',
      errorDialog1TH =
          ' จำเป็นต้องใช้อินเทอร์เน็ตเพื่อให้สามารถทำงานได้อย่างถูกต้อง\n\n',
      errorDialog2 = 'It seems that you have turned on the airplane mode. '
          'Please turn on Wi-Fi again or turn off this setting.',
      errorDialog2TH = 'ดูเหมือนว่าคุณมีการเปิดใช้งานโหมดเครื่องบินอยู่ '
          'กรุณาเปิดไวไฟอีกครั้งหรือปิดโหมดเครื่องบิน',
      errorDialog3 = 'Please check your network settings and try again.',
      errorDialog3TH = 'โปรดตรวจสอบการตั้งค่าเครือข่ายและลองใหม่อีกครั้ง',
      errorDialogTitle0 = 'Error',
      errorDialogTitle0TH = 'ข้อผิดพลาด',
      errorDialogTitle1 = 'No Internet Connection',
      errorDialogTitle1TH = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
      feedbackDialog0 = 'Your address is invalid.',
      feedbackDialog0TH = 'ที่อยู่อีเมลของคุณไม่ถูกต้อง',
      feedbackDialog1 = 'Invalid public IP address.',
      feedbackDialog1TH = 'ที่อยู่ไอพีสาธารณะไม่ถูกต้อง',
      feedbackDialog2 = 'Write your feedback before sending',
      feedbackDialog2TH = 'โปรดเขียนความคิดเห็นก่อนส่ง',
      feedbackHelper = 'Your address maybe too long.\n'
          'Please consider using another address.',
      feedbackHelperTH = 'ที่อยู่อีเมลของคุณอาจยาวเกินไป\n'
          'โปรดพิจารณาใช้ที่อยู่อื่นแทน',
      feedbackNote0 =
          'In addition to account info or screenshot whether or not you provide. Some ',
      feedbackNote0TH =
          'นอกเหนือไปจากข้อมูลบัญชีหรือภาพหน้าจอที่คุณได้มีการให้เอาไว้หรือไม่ก็ตาม ',
      feedbackNote1 = 'app and system info',
      feedbackNote1TH = 'ข้อมูลแอปและระบบ',
      feedbackNote2 = ' on this device will be automatically included. '
          'We\'ll use it to address technical issues and improve our services, '
          'subject to our ',
      feedbackNote2TH = 'บางส่วนบนอุปกรณ์เครื่องนี้จะถูกส่งไปโดยอัตโนมัติ '
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
      feedbackTooltip = 'Send',
      feedbackTooltipTH = 'ส่ง',
      firebaseSlash = '%2F',
      firebaseToken = '?alt=media&token=',
      objectToast = 'Open ',
      objectToastTH = 'เปิด ',
      offline = 'Offline Pictures',
      searchAlertButton = 'Show in',
      searchAlertButtonTH = 'แสดงใน',
      searchAlertDialog0 = 'You followed a link that requires the app \“',
      searchAlertDialog0TH = 'คุณได้เปิดลิงก์ที่ต้องใช้แอพ \“',
      searchAlertDialog1 = '\”, which is no longer on your device. '
          'You can get it from the App Store.',
      searchAlertDialog1TH =
          '\” แต่อุปกรณ์ของคุณไม่มีแอพนี้แล้ว คุณสามารถรับแอพได้จาก App Store',
      searchAlertDialogTitle = 'Get',
      searchAlertDialogTitleTH = 'รับ',
      searchSnackBar = 'Redirect to ',
      searchSnackBarTH = 'กำลังเปิดไปยัง ',
      share0 = 'I\'ve used the iLect app and I want everyone to try it.\n\n'
          'Download now at\nApp Store\n',
      share0TH = 'ฉันได้ใช้แอป iLect แล้วนะ อยากจะให้เพื่อนๆมาลองใช้กัน\n\n'
          'ดาวน์โหลดได้แล้วที่\nApp Store\n',
      share1 = '\nGoogle Play Store\n',
      sysinfoListTileTitle0 = 'Device model',
      sysinfoListTileTitle0TH = 'รุ่นของอุปกรณ์',
      sysinfoListTileTitle1 = 'OS version',
      sysinfoListTileTitle1TH = 'เวอร์ชันของระบบปฏิบัติการ',
      sysinfoListTileTitle2 = 'Application name',
      sysinfoListTileTitle2TH = 'ชื่อแอปพลิเคชัน',
      sysinfoListTileTitle3 = 'Application identifier',
      sysinfoListTileTitle3TH = 'ตัวระบุแอปพลิเคชัน',
      sysinfoListTileTitle4 = 'Application version',
      sysinfoListTileTitle4TH = 'เวอร์ชันของแอปพลิเคชัน',
      sysinfoListTileTitle5 = 'Time',
      sysinfoListTileTitle5TH = 'เวลา',
      sysinfoListTileTitle6 = 'Battery level',
      sysinfoListTileTitle6TH = 'ระดับแบตเตอรี่',
      sysinfoListTileTitle7 = 'Battery state',
      sysinfoListTileTitle7TH = 'สถานะแบตเตอรี่',
      sysinfoListTileTitle8 = 'Language',
      sysinfoListTileTitle8TH = 'ภาษา',
      timeFormat = ' HH:mm:ss ',
      timeFormatTH = ' H นาฬิกา m นาที s วินาที ',
      version = '0.7',

      // Page titles
      feedback = 'Send Feedback',
      feedbackTH = 'ส่งความคิดเห็น',
      privacy = 'Privacy Policy',
      privacyTH = 'นโยบายความเป็นส่วนตัว',
      search = 'Open in',
      searchTH = 'เปิดใน',
      service = 'Terms of Service',
      serviceTH = 'ข้อกำหนดในการให้บริการ',
      sysinfo = 'System information',
      sysinfoTH = 'ข้อมูลระบบ';
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
      Tag.error0: ConstantData().errorDialogTitle0,
      Tag.error1: ConstantData().errorDialog0,
      Tag.feedback: ConstantData().feedback,
      Tag.feedback0: (!Platform.isIOS)
          ? ConstantData().feedbackPage0
          : ConstantData().feedbackPage0IOS,
      Tag.feedback1: ConstantData().feedbackPage1,
      Tag.feedback2: ConstantData().feedbackHelper,
      Tag.feedback3: ConstantData().feedbackPage2,
      Tag.feedback4: ConstantData().feedbackPage3,
      Tag.feedback5: ConstantData().feedbackNote0,
      Tag.feedback6: ConstantData().feedbackNote1,
      Tag.feedback7: ConstantData().feedbackNote2,
      Tag.feedback8: ConstantData().feedbackDialog0,
      Tag.feedback9: ConstantData().feedbackDialog1,
      Tag.feedback10: ConstantData().feedbackDialog2,
      Tag.formatDate: ConstantData().dateFormat,
      Tag.formatTime: ConstantData().timeFormat,
      Tag.privacy: ConstantData().privacy,
      Tag.search: ConstantData().search,
      Tag.search0: ConstantData().searchAlertDialogTitle,
      Tag.search1: ConstantData().searchAlertDialog0,
      Tag.search2: ConstantData().searchAlertDialog1,
      Tag.search3: ConstantData().searchAlertButton,
      Tag.search4: ConstantData().searchSnackBar,
      Tag.service: ConstantData().service,
      Tag.share: ConstantData().share0 +
          ConstantData().ilectAppStoreUrl +
          ConstantData().share1 +
          ConstantData().ilectPlayStoreUrl,
      Tag.sysinfo: ConstantData().sysinfo,
      Tag.sysinfo0: ConstantData().sysinfoListTileTitle0,
      Tag.sysinfo1: ConstantData().sysinfoListTileTitle1,
      Tag.sysinfo2: ConstantData().sysinfoListTileTitle2,
      Tag.sysinfo3: ConstantData().sysinfoListTileTitle3,
      Tag.sysinfo4: ConstantData().sysinfoListTileTitle4,
      Tag.sysinfo5: ConstantData().sysinfoListTileTitle5,
      Tag.sysinfo6: ConstantData().sysinfoListTileTitle6,
      Tag.sysinfo7: ConstantData().sysinfoListTileTitle7,
      Tag.sysinfo8: ConstantData().sysinfoListTileTitle8,
      Tag.toast: ConstantData().objectToast,
      Tag.tooltip0: ConstantData().bottomAppBarTooltip0,
      Tag.tooltip1: ConstantData().bottomAppBarTooltip1,
      Tag.tooltip2: ConstantData().feedbackTooltip,
      Tag.warning0: ConstantData().errorDialogTitle1,
      Tag.warning1: ConstantData().title + ConstantData().errorDialog1,
      Tag.warning2: ConstantData().errorDialog2,
      Tag.warning3: ConstantData().errorDialog3,
    },
    'th': {
      Tag.battery0: ConstantData().batteryState0TH,
      Tag.battery1: ConstantData().batteryState1TH,
      Tag.battery2: ConstantData().batteryState2TH,
      Tag.copyright: ConstantData().copyrightTH,
      Tag.error0: ConstantData().errorDialogTitle0TH,
      Tag.error1: ConstantData().errorDialog0TH,
      Tag.feedback: ConstantData().feedbackTH,
      Tag.feedback0: ConstantData().feedbackPage0TH,
      Tag.feedback1: ConstantData().feedbackPage1TH,
      Tag.feedback2: ConstantData().feedbackHelperTH,
      Tag.feedback3: ConstantData().feedbackPage2TH,
      Tag.feedback4: ConstantData().feedbackPage3TH,
      Tag.feedback5: ConstantData().feedbackNote0TH,
      Tag.feedback6: ConstantData().feedbackNote1TH,
      Tag.feedback7: ConstantData().feedbackNote2TH,
      Tag.feedback8: ConstantData().feedbackDialog0TH,
      Tag.feedback9: ConstantData().feedbackDialog1TH,
      Tag.feedback10: ConstantData().feedbackDialog2TH,
      Tag.formatDate: ConstantData().dateFormatTH,
      Tag.formatTime: ConstantData().timeFormatTH,
      Tag.privacy: ConstantData().privacyTH,
      Tag.search: ConstantData().searchTH,
      Tag.search0: ConstantData().searchAlertDialogTitleTH,
      Tag.search1: ConstantData().searchAlertDialog0TH,
      Tag.search2: ConstantData().searchAlertDialog1TH,
      Tag.search3: ConstantData().searchAlertButtonTH,
      Tag.search4: ConstantData().searchSnackBarTH,
      Tag.service: ConstantData().serviceTH,
      Tag.share: ConstantData().share0TH +
          ConstantData().ilectAppStoreUrl +
          ConstantData().share1 +
          ConstantData().ilectPlayStoreUrl,
      Tag.sysinfo: ConstantData().sysinfoTH,
      Tag.sysinfo0: ConstantData().sysinfoListTileTitle0TH,
      Tag.sysinfo1: ConstantData().sysinfoListTileTitle1TH,
      Tag.sysinfo2: ConstantData().sysinfoListTileTitle2TH,
      Tag.sysinfo3: ConstantData().sysinfoListTileTitle3TH,
      Tag.sysinfo4: ConstantData().sysinfoListTileTitle4TH,
      Tag.sysinfo5: ConstantData().sysinfoListTileTitle5TH,
      Tag.sysinfo6: ConstantData().sysinfoListTileTitle6TH,
      Tag.sysinfo7: ConstantData().sysinfoListTileTitle7TH,
      Tag.sysinfo8: ConstantData().sysinfoListTileTitle8TH,
      Tag.toast: ConstantData().objectToastTH,
      Tag.tooltip0: ConstantData().bottomAppBarTooltip0TH,
      Tag.tooltip1: ConstantData().bottomAppBarTooltip1TH,
      Tag.tooltip2: ConstantData().feedbackTooltipTH,
      Tag.warning0: ConstantData().errorDialogTitle1TH,
      Tag.warning1: ConstantData().title + ConstantData().errorDialog1TH,
      Tag.warning2: ConstantData().errorDialog2TH,
      Tag.warning3: ConstantData().errorDialog3TH,
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
  feedback9,
  feedback10,
  formatDate,
  formatTime,
  privacy,
  search,
  search0,
  search1,
  search2,
  search3,
  search4,
  service,
  share,
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
  toast,
  tooltip0,
  tooltip1,
  tooltip2,
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
  bool isEN(BuildContext context) =>
      Localizations.localeOf(context).languageCode.contains('en');

  StatefulWidget passData(String message, [String category]) {
    return (category == null || category.trim().isEmpty)
        ? SecondPage(category: message)
        : ThirdPage(category: category, name: message);
  }

  Stream<Event> cardDataStreamSubscription(String schema) =>
      FirebaseDatabase.instance.reference().child(schema).onChildAdded;

  String createImageUrl(CardData cardData, [String category]) {
    return [
      ConstantData().firebaseUrl,
      (category == null || category.trim().isEmpty)
          ? ConstantData().schema0
          : selectSchema(category),
      ConstantData().firebaseSlash,
      cardData.pic,
      ConstantData().firebaseToken,
      cardData.token,
    ].join();
  }

  String fetchDateTime(BuildContext context) {
    return DateFormat(LocalizationData.of(context, Tag.formatDate)).format(
          DateTime.now(),
        ) +
        ((Localizations.localeOf(context).languageCode == 'th')
            ? (DateTime.now().year + 543).toString().substring(2)
            : '') +
        DateFormat(LocalizationData.of(context, Tag.formatTime)).format(
          DateTime.now(),
        ) +
        'GMT' +
        DateTime.now().timeZoneName.substring(0, 1) +
        int.parse(DateTime.now().timeZoneName.substring(1)).toString();
  }

  String selectSchema(String category) {
    switch (category) {
      case ConstantData.eating:
        category = ConstantData().schema1;
        break;
      case ConstantData.going:
        category = ConstantData().schema2;
        break;
      case ConstantData.listening:
        category = ConstantData().schema3;
        break;
      case ConstantData.watching:
        category = ConstantData().schema4;
        break;
    }
    return category;
  }

  void checkInternet(BuildContext context) async {
    if (!Platform.isIOS) {
      try {
        await InternetAddress.lookup(ConstantData().testUrl).timeout(
          Duration(seconds: 2),
        );
      } on Exception {
        ConnectivityResult _result = await Connectivity().checkConnectivity();
        String _connection;
        (_result == ConnectivityResult.none)
            ? _connection = LocalizationData.of(context, Tag.warning2)
            : _connection = LocalizationData.of(context, Tag.warning3);
        Catalog().showWarningDialog(
          context,
          LocalizationData.of(context, Tag.warning1) + _connection,
          title: LocalizationData.of(context, Tag.warning0),
        );
      }
    }
  }
}

class ProviderThemeData {
  ProviderThemeData([this._color]) {
    _theme();
  }

  Color _color = ConstantData().defaultColor;
  ThemeData theme;

  void _theme() {
    theme = ThemeData(
      cursorColor: _color,
      primaryColor: Color(0xFFFFFFFF),
      primaryTextTheme: TextTheme(
        body1: TextStyle(color: Color(0xFFFFFFFF)),
        title: (Platform.isIOS) ? null : TextStyle(fontWeight: FontWeight.w500),
      ),
      textTheme: TextTheme(
        button: TextStyle(fontWeight: FontWeight.w500),
        title: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
