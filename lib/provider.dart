import 'dart:async' show Stream;
import 'package:firebase_database/firebase_database.dart'
    show DataSnapshot, Event, FirebaseDatabase;
import 'package:ilect_app/main.dart'
    show FeedbackPage, PPPage, SecondPage, ThirdPage, ToSPage;

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
      page03 = PPPage();
  final Pattern
      // Regular expressions
      pattern = RegExp(r'[\w\s][^ก-๙]');
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

      // Others
      copyright =
          '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
      share =
          'ฉันได้ใช้แอป iLect แล้วนะ\nอยากจะให้เพื่อนๆมาลองใช้กัน\n\nดาวน์โหลดได้ที่ ...',
      version = 'version 0.5',

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

  String createImageUrl(CardData cd, [String str]) {
    final String _media = '?alt=media&token=',
        _slash = '%2F',
        _url = ConstantData().firebaseUrl;
    String _dir;
    (str == null || str.trim().isEmpty)
        ? _dir = ConstantData().schema0
        : _dir = selectSchema(str);
    return [_url, _dir, _slash, cd.pic, _media, cd.token].join();
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
