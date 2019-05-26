import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalexam/model/item_model.dart';

import 'package:finalexam/screen/edit_screen.dart';
        

final FirebaseAuth _auth = FirebaseAuth.instance;

class DetailScreen extends StatelessWidget {

  const DetailScreen({
    Key key,
    this.id,
    this.uid
  });

  final String id;
  final String uid;
  
  

  Future<void> _upAndDown (BuildContext context,Product product) async {
    // // if (!product.likes.contains(uid)){
    //   upCount(product);
    //   final addSnackBar =SnackBar(
    //     duration: Duration(milliseconds: 500),
    //     content: Text(
    //       "I LIKE IT",
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontSize: 20.0
    //       ),
    //       ),
    //       action: SnackBarAction(
    //         label: "Undo",
    //         onPressed: () => downCount(product)
    //       ),
    //   );
    //   Scaffold.of(context).showSnackBar(addSnackBar);
    // }
    // else {
    //   final addSnackBar =SnackBar(
    //     duration: Duration(milliseconds: 500),
    //     content: Text(
    //       "You can do it once !!",
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontSize: 20.0
    //       ),
    //       ),
    //       action: SnackBarAction(
    //         label: "Undo",
    //         onPressed: () => downCount(product)
    //       ),
    //   );
    //   Scaffold.of(context).showSnackBar(addSnackBar);
    // }
  }

  Future<void> upCount(Product product) async {
    Firestore.instance.runTransaction((tx) async {
      final freshSnapshot = await tx.get(product.reference);
      final fresh = Product.fromSnapshot(freshSnapshot);
      // var _add = new List<dynamic>.from(fresh.likes);
      // _add.add(uid);
      // debugPrint(fresh.likes.runtimeType.toString());
      // await tx.update(product.reference, {'Likes': _add });
    });
  }

  Future<void> downCount(Product product) async {
    Firestore.instance.runTransaction((tx) async {
      final freshSnapshot = await tx.get(product.reference);
      final fresh = Product.fromSnapshot(freshSnapshot);
      // var _sub = new List<dynamic>.from(fresh.likes);
      // _sub.remove(uid);
      // await tx.update(product.reference, {'Likes': _sub});
    });
  }


  @override
  Widget build(BuildContext context) {
    String category;
    String productUid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: Text(
          'Detail',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        actions: <Widget>[
          //TODO: UID가 다르다면 non-activate
           IconButton(
              icon: Icon(Icons.create),
              onPressed: () =>productUid.compareTo(uid) == 0 ? Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => EditingScreen(id:id,initCategory:category,))) : null
           ),
          IconButton(
            icon: Icon(Icons.delete),
              onPressed: () {
                if (productUid.compareTo(uid) == 0){
                  Firestore.instance.collection('Product').document(id).delete();
                  Navigator.of(context).pop();
                 }
                }
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance.collection('Product').document(id).snapshots(),
        builder: (context,snapshot) {
          if(snapshot.hasData){
            Product product = Product.fromSnapshot(snapshot.data);
            category = product.category;
            return SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Hero(
                //   transitionOnUserGestures: true,
                //   tag: product.name,
                //   child: Material(
                //     child: Container(
                //           width: MediaQuery.of(context).size.width,
                //           height: MediaQuery.of(context).size.height*0.3,
                //           child: Image.network(
                //             product.image,
                //           fit: BoxFit.fill,
                //         ),
                //     ),
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.fromLTRB(30.0, 8.0, 16.0, .0),
                  child: Text(
                    "<${product.category}>",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 24.0
                    )
                  )
                ),
                Container(
                  // padding: EdgeInsets.fromLTRB(30.0, 8.0, 16.0, .0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.5,
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.blueAccent
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: Colors.redAccent,
                            ),
                            onPressed: () { _upAndDown(context, product);

                            },//TODO: list에 uid추가 or remove
                            //TODO: 만약에 list에 내 uid가 존재 하지 않으면 snackbar and list에 추가
                            //TODO: 존재하면 snackbar에 결고를 준다.
                              //TODO: SNACKBAR의 Undo를 누르면 리스트에서 제거.
                          ),
                          // Text(
                          //   // product.likes.length.toString(),
                          //   style: TextStyle(
                          //     color: Colors.redAccent,
                          //     fontSize:  18.0
                          //   ),
                          // )
                        ],
                      ),
                      
                    ],
                  )
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(30.0, 8.0, 16.0, .0),
                  child: Text(
                    "{}",
                    style: TextStyle(
                          color: Colors.blue[200],
                          fontSize:  18.0
                        ),
                  )
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(30.0, 8.0, 16.0, .0),
                  child: Text(
                    product.info
                  )
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.2,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(30.0, 8.0, 16.0, .0),
                  child: Text(
                    // 'creator : <${product.uid}>\n${product.created}:Created\n${product.modify}:Modified',
                    "sdf",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey
                    ),
                  ),
                )
              ],
            ),
          );
          }
          return CircularProgressIndicator();
        }
      )
    );
  }
}


