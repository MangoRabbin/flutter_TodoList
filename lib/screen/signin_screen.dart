import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      // Navigator.of(context).pushNamed('/home');
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

  Future<void> _signInAnonymous() async {
    FirebaseUser user = await _auth.signInAnonymously();
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    if (user != null) {
      // Navigator.of(context).pushNamed('/home');
      print("여기 있다."+user.uid);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context){
    
    return Scaffold(
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
            SignInButton(
              Buttons.Email,
              onPressed: ()  => _signInAnonymous()
            )
          ],
        ),
      )
    );
  }
}
