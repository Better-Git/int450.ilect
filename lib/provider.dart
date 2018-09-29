import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:ilect_app/main.dart';

final String category = 'category',
    copyright =
        '© 2018 School of Information Technology, KMUTT.\nAll rights reserved.',
    feedback = 'Send Feedback',
    icon = 'assets/icon.png',
    op = 'Offline Pictures',
    pp = 'Privacy Policy',
    search = 'Open in',
    share =
        'ฉันได้ใช้แอป iLect แล้วนะ\nอยากจะให้เพื่อนๆมาลองใช้กัน\n\nดาวน์โหลดได้ที่ ...',
    title = 'iLect',
    tos = 'Terms of Service',
    version = 'version 0.3';
final page01 = FeedbackPage(), page02 = ToSPage(), page03 = PPPage();

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
  dataPass(bool b, String str) {
    switch (b) {
      case true:
        {
          return ThirdPage(name: str);
        }
        break;
      default:
        {
          return SecondPage(categoryName: str);
        }
        break;
    }
  }

  Stream<Event> cardDataStreamSubscription(String str) {
    return FirebaseDatabase.instance.reference().child(str).onChildAdded;
  }
}
