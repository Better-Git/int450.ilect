import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:ilect_app/main.dart';

final String category = 'category', title = 'iLect';
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
