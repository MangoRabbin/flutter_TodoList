import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:finalexam/widget/todolist_widget.dart';

import 'package:finalexam/widget/add_todo.dart';


import 'package:finalexam/screen/card_screen.dart';
import 'package:finalexam/screen/calendar_screen.dart';



class TodoMainScreen extends StatefulWidget {
  String user;
  TodoMainScreen({this.user});
  @override
  _TodoMainScreenState createState() => _TodoMainScreenState(user: this.user);
}

class _TodoMainScreenState extends State<TodoMainScreen> {
  _TodoMainScreenState({this.user});
  final auth = FirebaseAuth.instance;
  final String user;
  DateTime today;
  DateTime tomorrow;
  DateTime pickDay;
  DateTime yesterday;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    today = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    tomorrow = today.add(Duration(days: 1));
    yesterday = DateTime(today.year,today.month,today.day-1,23,59);
  }
  
  int changeDaytoInt(DateTime time){
    return int.parse(time.year.toString()+"${time.month.toString().length == 2 ? time.month.toString() : "0"+time.month.toString()}" + "${time.day.toString().length == 2? time.day.toString() : "0" + time.day.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<String>.value(value: user),
      ],
      child: Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                  controller:  scrollController,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 100.0),
                    child: Column(
                        children: <Widget>[
                          InkWell(
                            child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 10.0),
                                child: Text(
                                  "ToDo Tasks!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 27,
                                  ),
                                )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ListTile(
                              title: Text(
                                "못 끝낸 일",
                                style: TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.redAccent
                                ),
                              ),
                            ),
                          ),
                          TodoList(day: changeDaytoInt(today),mode: 3,user: user),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ListTile(
                              title: Text(
                                "오늘(${today.month}/${today.day})",
                                style: TextStyle(
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                          ),
                          TodoList(day: changeDaytoInt(today),mode: 0,user: user,),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ListTile(
                              title: Text(
                                "내일(${tomorrow.month}/${tomorrow.day})",
                                style: TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.blueAccent
                                ),
                              ),
                            ),
                          ),
                          TodoList(day: changeDaytoInt(tomorrow),mode: 1, user: user),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ListTile(
                              title: Text(
                                "이후 (${tomorrow.add(Duration(days:1)).month}/${tomorrow.add(Duration(days:1)).day}~)",
                                style: TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.green
                                ),
                              ),
                            ),
                          ),
                          TodoList(day: changeDaytoInt(tomorrow),mode: 2 , user: user),
                          Divider(),
                        ]
                    ),
                  )
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            onPressed: () => _todoInsert(),
            label: Row(
              children: <Widget>[
                Icon(Icons.add),
                Text("할일 추가하기")
              ],
            ),
          ),floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          bottomSheet: _deactivateBottomWidget(context)
      ),
    );

  }



  Widget _deactivateBottomWidget(BuildContext context) {
    return Material(
      shadowColor: Colors.black,
      elevation: 70.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.1,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12,width: 1.8,style: BorderStyle.solid)),
//                borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 9.0),
              child: IconButton(
                onPressed: () =>Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CardPage(user: user,) ), (Route<dynamic> route) => false),
                icon: Icon(
                  Icons.filter_none,
                  color: Colors.black,
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 9.0),
              child: IconButton(
                onPressed: () =>Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CalendarScreen(user: user,) ), (Route<dynamic> route) => false),
                icon: Icon(
                  Icons.calendar_today,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future onRefresh() async {
    await new Future.delayed(Duration(seconds: 3));
    return Navigator.popAndPushNamed(context, '/main');
  }

  Future<void> _todoInsert () async {
    return showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (BuildContext context){
      return Material(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
              child: NewTodoInsertWidget(user: user)
          ),
        ),
      );
    });
  }



}



