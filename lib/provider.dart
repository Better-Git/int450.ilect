import 'dart:async' show Stream;
import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, Event, FirebaseDatabase;
import 'package:ilect_app/main.dart'
    show FeedbackPage, PPPage, SecondPage, ThirdPage, ToSPage;

class CardData {
  String id, name, pic, search;

  CardData.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    name = snapshot.value['name'];
    pic = snapshot.value['pic'];
    search = snapshot.value['search'];
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
      page03 = PPPage();
  final Pattern
      // Regular expressions
      pattern = RegExp(r'[\w\s][^ก-๙]');
  final String
      // Application title
      title = 'iLect',

      // External links
      amapsUrl = 'http://maps.apple.com/?q=',
      chromeApp = 'googlechrome://',
      gmapsApp = 'googlemaps://',
      gmapsUrl = 'https://www.google.co.th/maps/search/',
      youtubeApp = 'youtube://',
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

      // Others
      copyright =
          '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
      share =
          'ฉันได้ใช้แอป iLect แล้วนะ\nอยากจะให้เพื่อนๆมาลองใช้กัน\n\nดาวน์โหลดได้ที่ ...',
      version = 'version 0.4',

      // Page titles
      feedback = 'Send Feedback',
      op = 'Offline Pictures',
      pp = 'Privacy Policy',
      search = 'Open in',
      tos = 'Terms of Service';
}

class Provider {
  dataPass(String str1, [String str2]) {
    return (str2 == null || str2.trim().isEmpty)
        ? SecondPage(category: str1)
        : ThirdPage(name: str1, category: str2);
  }

  Stream<Event> cardDataStreamSubscription(String str) {
    return FirebaseDatabase.instance.reference().child(str).onChildAdded;
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
}
