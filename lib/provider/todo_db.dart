import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:finalexam/model/item_model.dart';

import 'package:finalexam/model/category_model.dart';
import 'package:finalexam/model/user_model.dart';



class TodoDataBaseService {
  final Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createTodo(Todo newTodo) async {
    String user = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(user)
        .collection("Todos")
        .document()
        .setData({
      "Name" : newTodo.name,
      "Time" : newTodo.time.runtimeType == null ? null :DateTime(newTodo.dateTime.year,newTodo.dateTime.month,newTodo.dateTime.day),
      "Info" : newTodo.info,
      "Day"  : int.parse(newTodo.dateTime.year.toString()+"${newTodo.dateTime.month.toString().length == 2 ? newTodo.dateTime.month.toString() : "0"+newTodo.dateTime.month.toString()}" + "${newTodo.dateTime.day.toString().length == 2? newTodo.dateTime.day.toString() : "0" + newTodo.dateTime.day.toString()}"),
      "Done" : newTodo.done,
      "Category" : newTodo.category
    });
  }
  Future<void> removeTodo( var id ) async {
    String user = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(user)
        .collection('Todos')
        .document(id)
        .delete();
  }
  Future<void> removeDetailTodo( var id, DateTime time ) async {
    String user = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(user)
        .collection('Todos')
        .document(id)
        .delete();
  }
  Future<void> updateTodo(var id, String name, String info,DateTime time, String category) async {
    String user = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(user)
        .collection('Todos')
        .document(id)
        .updateData({
      "Name" : name,
      "Time" : time.toUtc(),
      "Info" : info,
      "Category" : category,
      "day" : int.parse(time.year.toString()+"${time.month.toString().length == 2 ? time.month.toString() : "0"+time.month.toString()}" + "${time.day.toString().length == 2? time.day.toString() : "0" + time.day.toString()}"),
    });
  }
  Future<void> doneButtonTodo(var id, bool done) async {
    String user = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(user)
        .collection('Todos')
        .document(id)
        .updateData({
      "Done" : !done
    });
  }
  Future<void> updateCategory(String title) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    List<dynamic> prevCategory = await _db.collection("Users").document(uid).collection("user").document('user').get().then((user) => CurrentUser.fromFirestore(user).categories).catchError((err) => err);
    final fresh = new List<dynamic>.from(prevCategory);
    fresh.add(title);
    return _db.collection("Users")
        .document(uid)
        .collection("user")
        .document('user')
        .updateData({
      "Categories" : fresh
    });
  }


  Future<void> createCategory(String title) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(uid)
        .collection("Categories")
        .document(title)
        .setData({
      "Total": 0,
      "Done" : 0,
      "Title" : title,
    });
  }
  Future<void> upCountDone(String title, CategoryModel category ) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(uid)
        .collection("Categories")
        .document(title)
        .updateData({
      "Done": category.done + 1
    });
  }
  Future<void> upCountTotal(String title, CategoryModel category ) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(uid)
        .collection("Categories")
        .document(title)
        .updateData({
      "Total": category.totalTodo + 1
    });
  }
  Future<void> downCountTotal(String title, CategoryModel category ) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(uid)
        .collection("Categories")
        .document(title)
        .updateData({
      "Total": category.totalTodo - 1
    });
  }
  Future<void> downCountDone(String title, CategoryModel category ) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(uid)
        .collection("Categories")
        .document(title)
        .updateData({
      "Done": category.done - 1
    });
  }
  Future<void> downCountAll(String title, CategoryModel category ) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    return _db
        .collection("Users")
        .document(uid)
        .collection("Categories")
        .document(title)
        .updateData({
      "Done": category.done - 1,
      "Total": category.totalTodo - 1
    });
  }
  Future<void> categoryDelete(String title) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    deleteUserCategory(title);
    return _db
        .collection("Users")
        .document(uid)
        .collection("Categories")
        .document(title)
        .delete();
  }
  Future<void> deleteUserCategory(String title) async {
    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);
    List<dynamic> prevCategory = await _db.collection("Users").document(uid).collection("user").document('user').get().then((user) => CurrentUser.fromFirestore(user).categories).catchError((err) => err);
    final fresh = new List<dynamic>.from(prevCategory);
    fresh.remove(title);
    return _db.collection("Users")
        .document(uid)
        .collection("user")
        .document('user')
        .updateData({
      "Categories" : fresh
    });
  }
}
