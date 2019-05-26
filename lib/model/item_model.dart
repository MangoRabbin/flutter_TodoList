import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String category;
  final String info;
  final Timestamp time;
  final bool done;
  final DocumentReference reference;
  // TODO: 만든 시간, 변경 시간 설정할 것 


  Product.fromMap(Map<String,dynamic> map, {this.reference})
    : assert(map['Name'] != null),
      assert(map['Category'] != null),
      assert(map['Info'] != null),
      assert(map['Date'] != null),
      assert(map['Done'] != null),
      name = map['Name'],
      category = map['Category'],
      info = map['Info'],
      done = map['Done'],
      time = map['Date'];


  Product.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, reference:snapshot.reference);

  @override
  String toString() => "Product<$name$category:$info:$time:$done>";
}