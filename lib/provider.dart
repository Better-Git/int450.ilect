// Copyright 2018 School of Information Technology, KMUTT. All rights reserved.

import 'dart:async' show Stream;
import 'dart:io' show InternetAddress, Platform, SocketException;

import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart'
    show DatabaseReference, Event, FirebaseDatabase;
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

import 'catalog.dart';
import 'main.dart';

class CardData {
  CardData.fromMap(int i, Map map) {
    id = i.toString();
    map.forEach((key, value) {
      keyword = map['search'];
      name = map['name'];
      pic = map['pic'];
      token = map['token'];
    });
  }

  String id, keyword, name, pic, token;
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
      favoritePage = FavoritePage(),
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
      nonLocalWithDotPattern = RegExp(r'[ \"(),.:;<>@[\\\]]+'),
      nonLocalWithoutDotPattern = RegExp(r'[ \"(),:;<>@[\\\]]+'),
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
      errorDialog4 = 'Unable to send the feedback. Please try again later.',
      errorDialog4TH =
          'ไม่สามารถส่งความคิดเห็นได้ โปรดลองใหม่อีกครั้งในภายหลัง',
      errorDialogTitle0 = 'Error',
      errorDialogTitle0TH = 'ข้อผิดพลาด',
      errorDialogTitle1 = 'No Internet Connection',
      errorDialogTitle1TH = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
      favoriteButton0 = 'Favorites',
      favoriteButton0TH = 'รายการโปรด',
      favoriteButton1 = '\nRemove\nfrom\n',
      favoriteButton1TH = '\nเอาออกจาก\n',
      favoriteButton2 = '\nAdd to\n',
      favoriteButton2TH = '\nเพิ่มลงใน\n',
      favoritePage0 = 'No ',
      favoritePage0TH = 'ไม่มี',
      favoriteInfo = 'List is sorted by category.',
      favoriteInfoTH = 'รายการถูกแบ่งออกตามหมวดหมู่',
      feedbackDialog0 = 'Your address is invalid.',
      feedbackDialog0TH = 'ที่อยู่อีเมลของคุณไม่ถูกต้อง',
      feedbackDialog1 = 'Invalid public IP address.',
      feedbackDialog1TH = 'ที่อยู่ไอพีสาธารณะไม่ถูกต้อง',
      feedbackDialog2 = 'Write your feedback before sending',
      feedbackDialog2TH = 'โปรดเขียนความคิดเห็นก่อนส่ง',
      feedbackDialog3 = 'There is an error occurred\n'
          'between uploading process.\n\nPlease try again later.',
      feedbackDialog3IOS = 'There is an error occurred '
          'between the uploading process.\nPlease try again later.',
      feedbackDialog3TH =
          'เกิดข้อผิดพลาดขึ้นในระหว่าง\nการอัพโหลด\n\nโปรดลองใหม่อีกครั้งในภายหลัง',
      feedbackDialog3THIOS =
          'เกิดข้อผิดพลาดขึ้นในระหว่างการอัพโหลด โปรดลองใหม่อีกครั้งในภายหลัง',
      feedbackDialog4 = 'Please wait...',
      feedbackDialog4TH = 'กรุณารอสักครู่',
      feedbackDialogTitle0 = 'Uploading',
      feedbackDialogTitle0TH = 'กำลังอัพโหลด',
      feedbackDialogTitle1 = 'Unable to upload',
      feedbackDialogTitle1TH = 'ไม่สามารถอัพโหลดได้',
      feedbackDialogTitle2 = 'Preparing',
      feedbackDialogTitle2TH = 'กำลังเตรียมการ',
      feedbackDialogTitle3 = 'Upload Successful',
      feedbackDialogTitle3TH = 'อัพโหลดสำเร็จ',
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
      homePage0 = 'We are updating\nour database',
      homePage0TH = 'เรากำลังอัพเดท\nฐานข้อมูลอยู่',
      homeSnackBar = 'Thank you for the feedback',
      homeSnackBarTH = 'ขอบคุณสำหรับความคิดเห็น',
      objectToast = 'Open ',
      objectToastTH = 'เปิด ',
      offline = 'Offline Pictures',
      privacyPage0 = 'This privacy policy was created by iLect application '
          '(in this case will be used the words instead of saying, '
          '"we", "us", or iLect), which is intended to protect and maintain the '
          'privacy of the users of the application.\n\n'
          '1. iLect values the trust you have given to us by providing your '
          'personal information to. We will use your personal information in a way '
          'that is fair and worthy of such trust.\n\n'
          '2. You have the right to receive clear information about how iLect '
          'uses your personal information to. We are transparent to the people '
          'and always on the information that we collect.\n\n'
          '3. If you have any concerns about how iLect use your personal information, '
          'we will cooperate with you in order to resolve such concerns.\n\n'
          '4. iLect will perform all justifiable in order to protect your information '
          'from being used in the wrong way and to keep safe.\n\n'
          '5. iLect shall comply with laws and regulations on data protection that '
          'apply to us by the various data protection authorities. '
          'If there is no data protection law, we will act in accordance '
          'with generally accepted principles governing data protection.',
      privacyPage0TH =
          '      นโยบายความเป็นส่วนตัวฉบับนี้ถูกสร้างขึ้นโดยแอปพลิเคชัน iLect '
          '(ในที่นี้จะใช้คำแทนว่า “เรา”, “ของเรา”, หรือ iLect) '
          'ซึ่งมีวัตถุประสงค์เพื่อป้องกันและรักษาความเป็นส่วนตัวของผู้ใช้แอพพลิเคชั่นดังนี้\n\n'
          '1. iLect ให้คุณค่าความไว้วางใจที่ท่านมีให้แก่เราจากการที่ได้ให้ข้อมูลส่วนตัวของท่านกับเรา  '
          'iLect จะใช้ข้อมูลส่วนตัวของท่านในทางที่เป็นธรรมและควรค่าแก่ความไว้วางใจดังกล่าวนั้นเสมอ\n\n'
          '2. ท่านมีสิทธิ์ได้รับข้อมูลที่ชัดเจนเกี่ยวกับวิธีการที่ iLect ใช้ข้อมูลส่วนตัวของท่าน  iLect '
          'จะโปร่งใสกับท่านเสมอในเรื่องข้อมูลที่เราเก็บรวบรวม\n\n'
          '3. หากท่านมีข้อกังวลใดๆเกี่ยวกับวิธีการที่ iLect ใช้ข้อมูลส่วนตัวของท่าน '
          'เราจะร่วมมือกับท่านเพื่อแก้ไขข้อกังวลดังกล่าวนั้นโดยพลัน\n\n'
          '4. iLect จะดำเนินการอันสมควรทั้งปวงเพื่อปกป้องข้อมูลของท่านจากการถูกนำไปใช้ในทางที่ผิด '
          'และเพื่อรักษาข้อมูลดังกล่าวไว้ให้ปลอดภัย\n\n'
          '5. iLect จะปฏิบัติตามกฎหมายและข้อบังคับว่าด้วยการคุ้มครองข้อมูลซึ่งใช้บังคับอยู่ทั้งปวง '
          'และเราจะให้ความร่วมมือกับเจ้าหน้าที่ผู้คุ้มครองข้อมูลต่างๆ หากไม่มีกฎหมายคุ้มครองข้อมูล'
          'ทางเราก็จะปฏิบัติตามหลักการอันเป็นที่ยอมรับทั่วไปว่าด้วยการคุ้มครองข้อมูล',
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
      servicePage0 =
          'iLect is an application that is currently in the experiment and development, '
          'which is helping people with the problems of communication with others. '
          'In the matter of basic needs, '
          'there are also restrictions on the number of choices. '
          'These are Terms of Service as follows:\n\n'
          '1. iLect reserves the right to modify the terms and conditions of use '
          'of this service without prior notice.\n\n'
          '2. iLect reserves the right to verify the accuracy of the information '
          'within the application. We will not be liable for any damages, including '
          'injury and loss expenses incurred both directly and indirectly, '
          'by chance or as a sequel to the usage of the application in all cases.',
      servicePage0TH =
          '      iLect เป็นแอปพลิเคชันที่กำลังอยู่ในช่วงทดลองและพัฒนา'
          'เพื่อช่วยเหลือผู้ที่มีปัญหาเรื่องของการสื่อสารกับผู้อื่นในแง่ของความต้องการขั้นพื้นฐานเป็นหลัก '
          'ทำให้ยังมีข้อจำกัดในการให้บริการและจำนวนตัวเลือกที่ปรากฏให้ใช้งาน '
          'โดยมีเงื่อนไขในการให้บริการดังนี้\n\n'
          '1. iLect ขอสงวนสิทธิ์ในการที่จะแก้ไขข้อกำหนดและเงื่อนไขในการให้บริการ'
          'โดยไม่ต้องแจ้งให้ทราบล่วงหน้า\n\n'
          '2. iLect ขอสงวนสิทธิ์ในการยืนยันความถูกต้องของข้อมูลต่างๆภายในแอปพลิเคชันนี้ '
          'เราจะไม่รับผิดชอบในความเสียหายใดๆ ซึ่งรวมถึงความสูญเสีย การบาดเจ็บ '
          'และค่าใช้จ่ายที่เกิดขึ้นทั้งทางตรง ทางอ้อม โดยบังเอิญ '
          'หรือเป็นผลที่เกิดขึ้นตามมาสืบเนื่องจากการใช้งานแอปพลิเคชันในทุกกรณี',
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
      version = '0.9',

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
  LocalizationData(Locale locale) : _locale = locale;

  final Locale _locale;
  final Map<String, Map<Tag, String>> _localizedValues = {
    'en': {
      Tag.battery0: ConstantData().batteryState0,
      Tag.battery1: ConstantData().batteryState1,
      Tag.battery2: ConstantData().batteryState2,
      Tag.copyright: ConstantData().copyright,
      Tag.error0: ConstantData().errorDialogTitle0,
      Tag.error1: ConstantData().errorDialog0,
      Tag.error2: ConstantData().errorDialog4,
      Tag.favorite: ConstantData().favoriteButton0,
      Tag.favorite0: ConstantData().favoriteInfo,
      Tag.favorite1: ConstantData().favoriteButton1,
      Tag.favorite2: ConstantData().favoriteButton2,
      Tag.favorite3:
          ConstantData().favoritePage0 + ConstantData().favoriteButton0,
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
      Tag.feedback11: ConstantData().feedbackDialogTitle0,
      Tag.feedback12: ConstantData().feedbackDialogTitle1,
      Tag.feedback13: (!Platform.isIOS)
          ? ConstantData().feedbackDialog3
          : ConstantData().feedbackDialog3IOS,
      Tag.feedback14: ConstantData().feedbackDialogTitle2,
      Tag.feedback15: ConstantData().feedbackDialog4,
      Tag.feedback16: ConstantData().feedbackDialogTitle3,
      Tag.formatDate: ConstantData().dateFormat,
      Tag.formatTime: ConstantData().timeFormat,
      Tag.home: ConstantData().homePage0,
      Tag.privacy: ConstantData().privacy,
      Tag.privacy0: ConstantData().privacyPage0,
      Tag.search: ConstantData().search,
      Tag.search0: ConstantData().searchAlertDialogTitle,
      Tag.search1: ConstantData().searchAlertDialog0,
      Tag.search2: ConstantData().searchAlertDialog1,
      Tag.search3: ConstantData().searchAlertButton,
      Tag.search4: ConstantData().searchSnackBar,
      Tag.service: ConstantData().service,
      Tag.service0: ConstantData().servicePage0,
      Tag.share: ConstantData().share0 +
          ConstantData().ilectAppStoreUrl +
          ConstantData().share1 +
          ConstantData().ilectPlayStoreUrl,
      Tag.snackbar: ConstantData().homeSnackBar,
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
      Tag.error2: ConstantData().errorDialog4TH,
      Tag.favorite: ConstantData().favoriteButton0TH,
      Tag.favorite0: ConstantData().favoriteInfoTH,
      Tag.favorite1: ConstantData().favoriteButton1TH,
      Tag.favorite2: ConstantData().favoriteButton2TH,
      Tag.favorite3:
          ConstantData().favoritePage0TH + ConstantData().favoriteButton0TH,
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
      Tag.feedback11: ConstantData().feedbackDialogTitle0TH,
      Tag.feedback12: ConstantData().feedbackDialogTitle1TH,
      Tag.feedback13: (!Platform.isIOS)
          ? ConstantData().feedbackDialog3TH
          : ConstantData().feedbackDialog3THIOS,
      Tag.feedback14: ConstantData().feedbackDialogTitle2TH,
      Tag.feedback15: ConstantData().feedbackDialog4TH,
      Tag.feedback16: ConstantData().feedbackDialogTitle3TH,
      Tag.formatDate: ConstantData().dateFormatTH,
      Tag.formatTime: ConstantData().timeFormatTH,
      Tag.home: ConstantData().homePage0TH,
      Tag.privacy: ConstantData().privacyTH,
      Tag.privacy0: ConstantData().privacyPage0TH,
      Tag.search: ConstantData().searchTH,
      Tag.search0: ConstantData().searchAlertDialogTitleTH,
      Tag.search1: ConstantData().searchAlertDialog0TH,
      Tag.search2: ConstantData().searchAlertDialog1TH,
      Tag.search3: ConstantData().searchAlertButtonTH,
      Tag.search4: ConstantData().searchSnackBarTH,
      Tag.service: ConstantData().serviceTH,
      Tag.service0: ConstantData().servicePage0TH,
      Tag.share: ConstantData().share0TH +
          ConstantData().ilectAppStoreUrl +
          ConstantData().share1 +
          ConstantData().ilectPlayStoreUrl,
      Tag.snackbar: ConstantData().homeSnackBarTH,
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
  static final String _category = ConstantData()
      .favoriteInfo
      .substring(18, ConstantData().favoriteInfo.length - 1);

  static String of(BuildContext context, Tag tag) =>
      Localizations.of<LocalizationData>(context, LocalizationData)._get(tag);

  String _get(Tag tag) => _localizedValues[_locale.languageCode][tag];
}

class LocalizationDataDelegate extends LocalizationsDelegate<LocalizationData> {
  // Returning a SynchronousFuture here because an async "load" operation
  // isn't needed to produce an instance of LocalizationData.
  @override
  load(Locale locale) =>
      SynchronousFuture<LocalizationData>(LocalizationData(locale));

  @override
  bool isSupported(Locale locale) => ['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationDataDelegate old) => false;
}

class Provider {
  bool isEN(BuildContext context) =>
      Localizations.localeOf(context).languageCode.contains('en');

  DatabaseReference cardDataDatabaseReference(String schema) =>
      FirebaseDatabase.instance.reference().child(schema);

  StatefulWidget passData(String message, [String category]) {
    return (category?.trim()?.isEmpty ?? true)
        ? SecondPage(category: message)
        : ThirdPage(category: category, name: message);
  }

  Stream<Event> cardDataStream([String name]) {
    return cardDataDatabaseReference(
      (name?.trim()?.isEmpty ?? true)
          ? LocalizationData._category
          : selectSchema(name) ?? name,
    ).onValue;
  }

  String createImageUrl(CardData cardData, [String category]) {
    return [
      ConstantData().firebaseUrl,
      (category?.trim()?.isEmpty ?? true)
          ? LocalizationData._category
          : selectSchema(category) ?? category,
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
    HomePage.list
        .where((item) => item.name == category)
        .forEach((item) => category = item.keyword);
    return category;
  }

  void checkInternet(BuildContext context) async {
    try {
      await InternetAddress.lookup(ConstantData().testUrl).timeout(
        Duration(seconds: 2),
      );
    } on SocketException {
      ConnectivityResult _result = await Connectivity().checkConnectivity();
      String _connection;
      (!Platform.isIOS && (_result == ConnectivityResult.none))
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

class ProviderThemeData {
  ProviderThemeData([Color color]) {
    _color = color;
    _theme();
  }

  Color _color = ConstantData().defaultColor;
  ThemeData theme;

  void _theme() {
    theme = ThemeData(
      canvasColor: Color(0xFFFFFFFF),
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

enum Tag {
  battery0,
  battery1,
  battery2,
  copyright,
  error0,
  error1,
  error2,
  favorite,
  favorite0,
  favorite1,
  favorite2,
  favorite3,
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
  feedback11,
  feedback12,
  feedback13,
  feedback14,
  feedback15,
  feedback16,
  formatDate,
  formatTime,
  home,
  privacy,
  privacy0,
  search,
  search0,
  search1,
  search2,
  search3,
  search4,
  service,
  service0,
  share,
  snackbar,
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
