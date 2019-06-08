import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  final String uid;
  final DocumentReference reference;
  final List<dynamic> categories;
  final int total;
  final int done;
  CurrentUser({
    this.uid,
    this.reference,
    this.categories,
    this.total,
    this.done
  });

  factory CurrentUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    assert(doc.documentID != null);
    assert(data['Categories'] != null);
    assert(data['Total'] != null);
    assert(data['Done'] != null);
    assert(doc.reference != null);
    return CurrentUser(
        uid: doc.documentID,
        categories: data['Categories'],
        done: data['Done'],
        reference: doc.reference,
        total: data['Total'],
    );
  }

  @override
  String toString() => "CurrentUser:$uid:$categories:$total$done>";

}