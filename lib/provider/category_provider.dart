import 'package:cloud_firestore/cloud_firestore.dart';import 'package:firebase_auth/firebase_auth.dart';import 'dart:async';import 'package:finalexam/model/category_model.dart';import 'package:finalexam/model/user_model.dart';class CategoryProvider {  FirebaseAuth _auth;  Firestore _db = Firestore.instance;  Future<void> updateCategory(String title) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    List<dynamic> prevCategory = await _db.collection("Users").document(uid).collection("user").document('user').get().then((user) => CurrentUser.fromFirestore(user).categories).catchError((err) => err);    final fresh = new List<dynamic>.from(prevCategory);    fresh.add(title);    return _db.collection("Users")        .document(uid)        .collection("user")        .document('user')        .updateData({      "Categories" : fresh    });  }  Future<void> createCategory(String title) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    return _db        .collection("Users")        .document(uid)        .collection("Categories")        .document(title)        .setData({      "Total": 0,      "Done" : 0,      "Title" : title,    });  }  Future<void> upCountDone(String title, CategoryModel category ) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    return _db        .collection("Users")        .document(uid)        .collection("Categories")        .document(title)        .updateData({      "Done": category.done + 1    });  }  Future<void> upCountTotal(String title, CategoryModel category ) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    return _db        .collection("Users")        .document(uid)        .collection("Categories")        .document(title)        .updateData({    "Total": category.totalTodo + 1    });  }  Future<void> downCountTotal(String title, CategoryModel category ) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    return _db        .collection("Users")        .document(uid)        .collection("Categories")        .document(title)        .updateData({      "Total": category.totalTodo - 1    });  }  Future<void> downCountDone(String title, CategoryModel category ) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    return _db        .collection("Users")        .document(uid)        .collection("Categories")        .document(title)        .updateData({      "Done": category.done - 1    });  }  Future<void> downCountAll(String title, CategoryModel category ) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    return _db        .collection("Users")        .document(uid)        .collection("Categories")        .document(title)        .updateData({      "Done": category.done - 1,      "Total": category.totalTodo - 1    });  }  Future<void> categoryDelete(String title, CategoryModel category ) async {    String uid = await _auth.currentUser().then((user) => user.uid).catchError((err) => err);    List<String> prevCategory = await _db.collection("Users").document(uid).get().then((user) => CurrentUser.fromFirestore(user).categories).catchError((err) => err);    prevCategory.removeWhere((data) => data == category.title );    _db.collection("Users").document(uid).updateData({      "Categories" : prevCategory    });    return _db        .collection("Users")        .document(uid)        .collection("Categories")        .document(title)        .delete();  }}