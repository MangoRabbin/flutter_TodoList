import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id;
  String name;
  String info;
  Timestamp time;
  int day;
  bool done;
  DocumentReference reference;
  DateTime dateTime;
  String category;

  Todo({
    this.id,
    this.name,
    this.info,
    this.time,
    this.day,
    this.done,
    this.reference,
    this.dateTime,
    this.category
  });

  factory Todo.fromFireStore(DocumentSnapshot doc) {
    Map data = doc.data;

    assert(doc.documentID != null);
    assert(data['Name'] != null);
    assert(data['Info'] != null);
    assert(data['Time'] != null);
    assert(data['Day'] != null);
    assert(data['Done'] != null);
    assert(doc.reference != null);
    assert(data['Category'] != null);
    return Todo(
        id: doc.documentID,
        name: data['Name'],
        info: data['Info'],
        time: data['Time'],
        day: data['Day'],
        done: data['Done'],
        reference: doc.reference,
        category: data['Category']
    );
  }

  @override
  String toString() => "TODO<$name:$time:$done:$category>";

  Todo.toInsert(String name, String info, DateTime time, String category) :
        id = "",
        name = name,
        info = info.isEmpty ? "" : info,
        dateTime = time,
        category = category.trim().length != 0 ? category : "",
        day = int.parse(time.year.toString()+"${time.month.toString().length == 2 ? time.month.toString() : "0"+time.month.toString()}" + "${time.day.toString().length == 2? time.day.toString() : "0" + time.day.toString()}"),
        done = false;
}
