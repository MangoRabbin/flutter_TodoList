import 'package:finalexam/constant/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

  FirebaseAuth user = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  
  bool anonymousSign;
  String defaultUrl = "https://firebasestorage.googleapis.com/v0/b/mobilefinalexam-66c65.appspot.com/o/default-image2.jpg?alt=media&token=85ba6ed0-82d9-40a2-a667-1a3a07d08058";

  @override
  void initState(){
    super.initState();
    anonymousSign =false;
  }
  void dispose(){
    super.dispose();
  }
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              if(anonymousSign){
                _googleSignIn.signOut();
              }
              user.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            }
            //TODO: 로그아웃 및 로그인 페이지로 이동.
          )
        ],
      ),
      body:  FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData){
            var data = snapshot.data;
            anonymousSign = snapshot.data.isAnonymous ? true : false;
            // setState((){
            //   data = snapshot.data;
            // anonymousSign = snapshot.data.isAnonymous ? true : false;
            // });
            return  Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(30.0, 8.0, 30.0, .0, ),
                    // child: snapshot.data.isEmailVerified ? Image.network(snapshot.data.photoUrl) : Image.network(snapshot.data.photoUrl),
                    child: Image.network(anonymousSign ? defaultUrl : data.photoUrl)
                  ),
                Container(
                        padding: EdgeInsets.fromLTRB(.0, 8.0, 16.0, .0),
                        child: Text(
                          '<${snapshot.data.uid}> ',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white
                        ),
                      ),
                  ),
                  Divider(color: Colors.white,),
                  Container(
                    child: Text(
                      anonymousSign  ? "anonymous" : data.email,
                      style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white
                        ),
                    ),
                  )
                ],
              ),
            );
          }
        }
      )
    );
  }
}


                      