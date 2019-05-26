import 'package:finalexam/constant/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';

import 'package:finalexam/model/item_model.dart';


class EditingScreen extends StatefulWidget {
  EditingScreen({this.id, this.initCategory });
  final String id;
  final String initCategory;
  @override
  _EditingScreenState createState() => _EditingScreenState(id: this.id, initCategory: initCategory);
}

class _EditingScreenState extends State<EditingScreen> {

  _EditingScreenState({this.id, this.initCategory});
  final String id;
  final String initCategory;
  Product product;
  File _image;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  String category;
  DateTime modify;
  String name;
  bool picChange;
  
  @override
  void initState() {
    super.initState();
    modify = DateTime.now();
    category = initCategory;
    picChange = false;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    nameFocus.dispose();
    priceFocus.dispose();
    descriptionFocus.dispose();
    super.dispose();
  }
  


  // Future _saved(BuildContext context, Product product) async {
  //   String imageUrl;
  //   if (picChange) {
  //     StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(basename(_image.path).toString());
  //     StorageUploadTask task =  firebaseStorageRef.putFile(_image);
  //     imageUrl =  (await firebaseStorageRef.getDownloadURL()).toString();
  //   }
  //   DocumentReference doc =Firestore.instance.collection('Product').document(id);
  //   await doc.setData({
  //       "Name": nameController.text.length == 0 ? product.name : nameController.text, 
  //       "Price": priceController.text.length == 0 ?  product.price : int.parse(priceController.text),
  //       "Image": _image == null ? product.image : imageUrl,
  //       "Category": category,
  //       "Modify": modify.toString(),
  //       "Info": descriptionController.text.isNotEmpty ? descriptionController.text.toString() : product.info,
  //   }, merge: true); 
  //   // await Firestore.instance.runTransaction((tx) async {
  //   //   await tx.update(product.reference,
  //   //   {
  //   //     "Name": nameController.text,
  //   //     "Price": int.parse(priceController.text),
  //   //     "Image": imageUrl,
  //   //     "Category": category,
  //   //     "Modify": modify.toString(),
  //   //     "Info": descriptionController.text.toString(),
  //   //   });
  //   // });
  //   Navigator.of(context).pop();
  // }

  @override
  Widget build (BuildContext context) {
    Product product;
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
            onPressed: () => print("Save"),
            // onPressed: () => _saved(context, product),
            //TODO: send data to firebase.
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance.collection('Product').document(id).snapshots(),
        builder: (context,snapshot) {
          if(!snapshot.hasData) return CircularProgressIndicator();
          else{
            product = Product.fromSnapshot(snapshot.data);
            return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top:10.0, left: 30.0,right: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Container(
                //   width: MediaQuery.of(context).size.width*0.8,
                //   height: MediaQuery.of(context).size.height*0.3,
                //   child: Center(
                //     child: _image == null 
                //     ? Image.network(product.image)
                //     : Image.file(_image)
                //   ),
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButton<String>(
                      value: category,
                      onChanged: (String newValue) => setState((){category = newValue;}),
                      items: <String>['accessories','home','clothing'].map<DropdownMenuItem<String>>((String value){
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value)
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.7),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => debugPrint("camera")
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.05
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: TextFormField(
                    focusNode: nameFocus,
                    controller: nameController,
                    onFieldSubmitted: (v) {
                      setState(() {
                        name = v;
                      });
                      FocusScope.of(context).requestFocus(priceFocus);
                    },
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                    ),
                    decoration: InputDecoration(
                      hintText: product.name,
                      hintStyle: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width*0.8,
                //   padding: EdgeInsets.only(bottom: 20.0),
                //   child: TextFormField(
                //     focusNode: priceFocus,
                //     onFieldSubmitted: (v) => FocusScope.of(context).requestFocus(descriptionFocus),
                //     controller: priceController,
                //     keyboardType: TextInputType.number,
                //     style: TextStyle(
                //       color: Colors.blueAccent,
                //       fontSize: 18.0,
                //     ),
                //     decoration: InputDecoration(
                //       hintText: product.price.toString(),
                //       hintStyle: TextStyle(
                //         color: Colors.blueAccent,
                //         fontSize: 18.0,
                //       )
                //     ),
                //   ),
                // ),
                Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: TextField(
                    focusNode: descriptionFocus,
                    controller: descriptionController,
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18.0,
                    ),
                    decoration: InputDecoration(
                      hintText: product.info,
                      hintStyle: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 18.0,
                      )
                    ),
                  ),
                ),
                
                
              ],
            ),
          ),
        );
          }
        },
      )
    );
  }
}