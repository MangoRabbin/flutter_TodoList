import 'package:flutter/material.dart';

import 'package:finalexam/screen/signin_screen.dart';



class FinalExam extends StatelessWidget {
  
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          title: 'FinalExam',
          home: SignInScreen(),
           initialRoute: '/login',
          routes: {
            '/login':(context) => SignInScreen(),
          },
    );
  }
}
