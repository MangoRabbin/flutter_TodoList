import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:finalexam/screen/main_todo_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

class SignInScreen extends StatefulWidget {
  @override
  SignInScreenState createState() => SignInScreenState();
}
class SignInScreenState extends State<SignInScreen>{

  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  // bool _success;
  // String _userEmail;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    // _emailController.dispose();
    // _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signinGoogle() async{
    _googleSignIn.signOut();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    if (user != null) {
      var firestore = Firestore.instance.collection("Users").document(user.uid).collection("user").document("user").get();
       firestore.then((doc) {
         if(doc.data == null){
           Firestore.instance.collection('Users').document(user.uid).collection("user").document("user").setData({
             "Categories": ['All','Scheduled'],
             "Total" : 0,
             "Done" : 0,
            });
         }
       }).catchError((err) =>print("에러에러에러$err"));
      
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TodoMainScreen(user: user.uid,) ), (Route<dynamic> route) => false);
    }
  }


  @override
  Widget build(BuildContext context){
    
    return Provider<Future<FirebaseUser>>.value(
      value: _auth.currentUser(),
      child: Scaffold(
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cake,
                // size: 3.0,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.3),
              // FlatButton(
              //   child:Text("google"),
              //   onPressed: () async {
              //     _googleSignIn.signOut();
              //     final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
              //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
              //     final AuthCredential credential = GoogleAuthProvider.getCredential(
              //       accessToken: googleAuth.accessToken,
              //       idToken: googleAuth.idToken
              //     );
              //     final FirebaseUser user = await _auth.signInWithCredential(credential);
              //       assert(user.email != null);
              //       assert(user.displayName != null);
              //       assert(!user.isAnonymous);
              //       assert(await user.getIdToken() != null);

              //     final FirebaseUser currentUser = await _auth.currentUser();
              //     assert(user.uid == currentUser.uid);
              //     if (user != null) {
              //       // Navigator.of(context).pushNamed('/home');
              //       Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
              //     }
              //   }
              // ),
              SignInButton(
                Buttons.Google,
                onPressed: () => _signinGoogle()
              ),
//              SignInButton(
//                Buttons.Email,
//                onPressed: ()  => _signInAnonymous()
//              )
            ],
          ),
        )
      ),
    );
  }
}
