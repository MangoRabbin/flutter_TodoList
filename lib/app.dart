import 'package:flutter/material.dart';


import 'package:finalexam/screen/signin_screen.dart';
import 'package:finalexam/screen/home.dart';
import 'package:finalexam/screen/register_screen.dart';
import 'package:finalexam/screen/google_sign_screen.dart';
import 'package:finalexam/screen/addition_screen.dart';
import 'package:finalexam/screen/profile_screen.dart';
import 'package:finalexam/screen/card_screen.dart';


class FinalExam extends StatelessWidget {
  
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinalExam',
      home: HomeScreen(),
      initialRoute: '/card',
      routes: {
        '/login':(context) => SignInScreen(),
        '/home': (context) => HomeScreen(),
        // '/register' : (context) => RegisterPage(),
        '/googleSignin' : (context) => SignInPage(),
        '/add' : (context) => AdditionScreen(),
        '/profile' : (context) => ProfileScreen(),
        '/card' : (context) => MyHomePage()
      },
    );
  }
}