import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';

import 'package:finalexam/model/item_model.dart';


class AdditionScreen extends StatefulWidget {
  @override
  _AdditionScreenState createState() => _AdditionScreenState();
}

class _AdditionScreenState extends State<AdditionScreen> {
  
  Product product;
  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode categoryFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  String category ;
  DateTime date;
  String name;
  bool dataUploading;
  List<String> weekdayValue1 = ["Mon","Tue","Web","Thur","Fri","Sat","Sun"];
  String weekdayV1;
  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    dataUploading = false;
    weekdayV1 = weekdayValue1[DateTime.now().weekday-1];
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    nameFocus.dispose();
    categoryFocus.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }

  Future _selectDate( BuildContext context) async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 2)
    );
    if(picked != null) setState(() {
      date = picked;
      weekdayV1 = weekdayValue1[picked.weekday-1];
      });
  }
  
  Future _saved(BuildContext context) async {


    await Firestore.instance.collection('Product').document(weekdayV1).collection(weekdayV1).document(date.toString()).setData({
      "Name": nameController.text,
      "Category": category,
      "Date": date,
      "Info": descriptionController.text,
      "Done": false
    });
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text(
              'Add',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold
              )
          ),
          titleSpacing: 0.0,
          centerTitle: true,
          leading: Center(
            child: GestureDetector(
              child: Text(
                "Cancel",
                style: TextStyle(
                    color: Colors.black
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                "Save",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              // onPressed: () => print("Save"),
              onPressed: () => _saved(context),
              //TODO: send data to firebase.
            )
          ],
        ),
        body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10.0, left: 30.0, right: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.8,
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          focusNode: nameFocus,
                          controller: nameController,
                          onFieldSubmitted: (v) {
                            setState(() {
                              name = v;
                            });
                            FocusScope.of(context).requestFocus(categoryFocus);
                          },
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold
                          ),
                          decoration: InputDecoration(
                            hintText: "What TODO",
                            hintStyle: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.8,
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: TextFormField(
                          focusNode: categoryFocus,
                          onFieldSubmitted: (v) =>
                              FocusScope.of(context).requestFocus(descriptionFocus),
                          controller: categoryController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18.0,
                          ),
                          decoration: InputDecoration(
                              hintText: "Category",
                              hintStyle: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18.0,
                              )
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.8,
                        child: TextField(
                          focusNode: descriptionFocus,
                          controller: descriptionController,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 18.0,
                          ),
                          decoration: InputDecoration(
                              hintText: "Desicription",
                              hintStyle: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18.0,
                              )
                          ),
                        ),
                      ),
                      RaisedButton(onPressed: () async => _selectDate(context), child: new Text('Click me'),)
                    ],
                  ),
                ),
              )
      );
    }
}

