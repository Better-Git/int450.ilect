import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:ilect_app/main.dart';

const String
    // Category titles
    eat = 'หิว',
    go = 'ไป',
    listen = 'ฟัง',
    watch = 'ดู',

    // External links
    gmapsUrl = 'https://www.google.co.th/maps/search/',
    youtubeUrl = 'https://www.youtube.com/results?search_query=',

    // Icon titles
    amaps = 'Maps',
    chrome = 'Chrome',
    gmaps = 'Google Maps',
    safari = 'Safari',
    youtube = 'YouTube';
final String
    // Application title
    title = 'iLect',

    // Icon assets
    amapsIcon = 'assets/a_maps_icon.png',
    chromeIcon = 'assets/chrome_icon.png',
    gmapsIcon = 'assets/g_maps_icon.png',
    ilectIcon = 'assets/icon.png',
    safariIcon = 'assets/safari_icon.png',
    youtubeIcon = 'assets/youtube_icon.png',

    // Page titles
    feedback = 'Send Feedback',
    op = 'Offline Pictures',
    pp = 'Privacy Policy',
    search = 'Open in',
    tos = 'Terms of Service',

    // Others
    copyright =
        '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
    share =
        'ฉันได้ใช้แอป iLect แล้วนะ\nอยากจะให้เพื่อนๆมาลองใช้กัน\n\nดาวน์โหลดได้ที่ ...',
    version = 'version 0.4',

    // Firebase database schema titles
    schema0 = 'category',
    schema1 = 'looking',
    schema2 = 'listen',
    schema3 = 'Hungry',
    schema4 = 'go';
final page01 = FeedbackPage(), page02 = ToSPage(), page03 = PPPage();
String url = '';

class CardData {
  CardData(this._id, this._name, this._pic);

  String _id;
  String _name;
  String _pic;

  String get id => _id;
  String get name => _name;
  String get pic => _pic;

  CardData.fromSnapshot(bool b, DataSnapshot snapshot) {
    _id = snapshot.key;
    _pic = snapshot.value['pic'];
    switch (b) {
      case true:
        {
          _name = snapshot.value['search'];
        }
        break;
      default:
        {
          _name = snapshot.value['name'];
        }
        break;
    }
  }

  CardData.map(dynamic obj) {
    this._id = obj['id'];
    this._name = obj['name'];
    this._pic = obj['pic'];
  }
}

class Provider {
  dataPass(String str1, [String str2]) {
    return (str2 == null || str2.isEmpty)
        ? SecondPage(category: str1)
        : ThirdPage(name: str1, category: str2);
  }

  Stream<Event> cardDataStreamSubscription(String str) {
    return FirebaseDatabase.instance.reference().child(str).onChildAdded;
  }
}
