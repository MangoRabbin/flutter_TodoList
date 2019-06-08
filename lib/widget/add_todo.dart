import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:finalexam/provider/todo_db.dart';
import 'package:finalexam/model/item_model.dart';
import 'package:finalexam/widget/day_circle_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:finalexam/model/user_model.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class NewTodoInsertWidget extends StatefulWidget {
  String user;
  NewTodoInsertWidget({this.user});
  @override
  _NewTodoInsertWidgetState createState() => _NewTodoInsertWidgetState(user: this.user);
}

class _NewTodoInsertWidgetState extends State<NewTodoInsertWidget> {

  bool buttonInfoState;
  bool buttonTimeState;
  bool buttonCategoryState;

  final String user;
  _NewTodoInsertWidgetState({this.user});
  ScrollController _controller;

  final auth = FirebaseAuth.instance;
  DateTime today;
  DateTime tomorrow;
  DateTime afterDay;
  DateTime pickDay;
  Todo newTodo;
  bool activateButton = false;

  TextEditingController nameTextController = TextEditingController();
  TextEditingController infoTextController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode infoFocus = FocusNode();
  double height;
  String pickCategory;
  bool originalHeight;

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    tomorrow = today.add(Duration(days: 1));
    afterDay = today.add(Duration(days: 2));
    buttonInfoState = false;
    buttonTimeState = false;
    buttonCategoryState = false;
    pickCategory = "";
    originalHeight = true;
  }

  @override
  void dispose() {
    buttonTimeState = false;
    buttonInfoState = false;
    nameFocus.dispose();
    nameTextController.dispose();
    infoFocus.dispose();
    infoTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setHeight(context);
    return  RefreshIndicator(
      onRefresh: onRefresh,
      child: Container(
        height: height,
        child: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width*0.9,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.06,
                  margin: EdgeInsets.only(
                      left: 10.0, top: 10.0, right: 10.0),
                  padding: EdgeInsets.fromLTRB(16.0,16.0,16.0,0.0),
                  child: TextField(
                    autofocus: true,
                    controller: nameTextController,
                    onChanged: (str) => setState(() => activateButton = true),
                    focusNode: nameFocus,
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold
                    ),
                    decoration: InputDecoration.collapsed(
                        hintText: "새로운 할 일",
                        hintStyle: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                ),
                !buttonInfoState ? Container() :Container(
                  alignment: Alignment.center,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width*0.9,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.06,
                  margin: EdgeInsets.only(
                      left: 10.0, bottom: 1.0, right: 10.0),
                  padding: EdgeInsets.fromLTRB(16.0,0.0,16.0,0.0),
                  child: TextField(
                    autofocus: true,
                    controller: infoTextController,
                    focusNode: infoFocus,
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold
                    ),
                    decoration: InputDecoration.collapsed(
                        hintText: "세부정보 추가",
                        hintStyle: TextStyle(
                            fontSize: 13.0,
                            color: Colors.blueGrey
                        )
                    ),
                  ),
                ),
                pickCategory.length == 0 ? Container() :Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width*0.9,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.03,
                    margin: EdgeInsets.only(
                        left: 10.0, bottom: 10.0, right: 10.0,top: 10.0),
                    padding: EdgeInsets.fromLTRB(16.0,0.0,16.0,0.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.category, color: Colors.lightBlueAccent,),
                        SizedBox(width: 20.0,),
                        Text("$pickCategory")
                      ],
                    )

                ),
                buttonCategoryState ? _buildCategories(context) : Container(),
                buttonTimeState ? _dayButtons(context) : Container(),

                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.subject,
                        color: buttonInfoState ? Colors.lightBlueAccent :Colors.blueGrey,
                      ),
                      onPressed: () => setState(() => buttonInfoState = true),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                      ),
                      color: buttonTimeState ? Colors.lightBlueAccent :Colors.blueGrey,
                      onPressed: () => setState(() => buttonTimeState = true),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.category,
                      ),
                      color: buttonCategoryState ? Colors.lightBlueAccent :Colors.blueGrey,
                      onPressed: () => setState(() => buttonCategoryState = true),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.2,),
                    buttonTimeState ?Container() : FlatButton(
                        child: Text("저장하기", style: TextStyle(color: Colors.blueGrey),),
                        onPressed: activateButton ? ()  {
                          TodoDataBaseService().createTodo(Todo.toInsert(nameTextController.value.text, infoTextController.value.text, today,pickCategory));
                          Navigator.of(context).pop();
                        } : null
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future _selectDate() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2040),
      builder: (BuildContext context, Widget child){
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      }
    );
    if (picked != null){
      setState(() {
        pickDay = picked;
        TodoDataBaseService().createTodo(Todo.toInsert(nameTextController.value.text, infoTextController.value.text, pickDay,pickCategory));
        Navigator.of(context).pop();
      });
    }
  }

  Future _selectDates() async {
//    showDialog(context: null);
    List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: new DateTime.now(),
        initialLastDate: new DateTime.now(),
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2020)
    );
    if (picked != null && picked.length == 2) {
      DateTime start = picked[0];
      DateTime end = picked[1];
      Duration time = end.difference(start);
      print("ssssssssss${time.inDays.toInt().toString()}");
      
      for(int i = 0; i <= time.inDays.toInt() ; i++ ){
        TodoDataBaseService().createTodo(Todo.toInsert(nameTextController.value.text, infoTextController.value.text, start.add(Duration(days: i)) ,pickCategory));
      }
      Navigator.of(context).pop();
    }

  }


  Widget _buildCategories(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Divider(),
          FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance.collection('Users').document(user).collection("user").document("user").get(),
              builder: (context,snapshot) {
                if (snapshot.connectionState.index == 3)
                  return Padding(
                padding: const EdgeInsets.only(left:20.0, top: 5.0,bottom: 12.0),
                child: _buildCategoryButton(context, snapshot.data),
              );
                return Container();
            }
          ),
          Divider(),
        ],
      ),
    );
  }

  void setHeight(BuildContext context){
      height = MediaQuery.of(context).size.height*0.17;

    if(buttonTimeState) {
      height += MediaQuery.of(context).size.height*0.07;
    }
    if(buttonInfoState) {
      height += MediaQuery.of(context).size.height*0.06;
    }
    if(buttonCategoryState) {
      height += MediaQuery.of(context).size.height*0.12;
    }
    else if( buttonCategoryState && pickCategory.trim().length == 0){
      height = MediaQuery.of(context).size.height*0.12;
      height += MediaQuery.of(context).size.height*0.2;
    }
    if(pickCategory.trim().compareTo("") != 0){
      height += MediaQuery.of(context).size.height*0.06;
    }
  }

  Widget _buildCategoryButton(BuildContext context, DocumentSnapshot doc){
    CurrentUser user = CurrentUser.fromFirestore(doc);
    return Container(
      height: MediaQuery.of(context).size.height*0.06,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: user.categories.map((category){
            if(category.toString().compareTo("All") != 0){
              return Padding(
                padding: const EdgeInsets.only(right:8.0),
                child: InkWell(
                  onTap: () => setState(() {
                    pickCategory = category;
                    buttonCategoryState = false;
                  }),
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width*0.25,
                    child: Text(
                      category.toString(),
                      style: TextStyle(
                          color: pickCategory.compareTo(category) == 0 ? Colors.lightBlueAccent : Colors.grey,
                          fontSize: 13.0
                      ),
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: pickCategory.compareTo(category) == 0 ? Colors.lightBlueAccent : Colors.grey,
                        )
                    ),
                  ),
                ),
              );
            }
            return Container();
          }).toList(),
        )
      )
    );
  }

  Widget _dayButtons(BuildContext context) {
    return FittedBox(
        child: Row(
          children: <Widget>[
            // 4 button
            // today.
            DayCircleButton(
              title: "오늘",
              icon: Icons.arrow_upward,
              color: Colors.lightBlueAccent,
              callback: () async {
                pickDay = today;
                TodoDataBaseService().createTodo( Todo.toInsert(nameTextController.value.text, infoTextController.value.text, today,pickCategory));
                Navigator.of(context).pop();
              },
              activateButton: activateButton,
            ),
            // tomorrow
            DayCircleButton(
              title: "내일",
              icon: Icons.arrow_forward,
              color: Colors.pinkAccent[100],
              callback: () async {
                TodoDataBaseService().createTodo( Todo.toInsert(nameTextController.value.text, infoTextController.value.text, tomorrow,pickCategory));
                Navigator.of(context).pop();
              },
              activateButton: activateButton,
            ),
            // after day
            DayCircleButton(
              title: "이후",
              icon: Icons.near_me,
              color: Colors.teal[300],
              callback: () async {
                _selectDate();
              },
              activateButton: activateButton,

            ),
            // repeat day.
            DayCircleButton(
              title: "반복",
              icon: Icons.sync,
              color: Colors.indigoAccent,
              callback: (){
                //달력. 선택과
                // 요일 선택,
                _selectDates();
              },
              activateButton: activateButton,

            ),
          ],
        ));
  }

  Future onRefresh() async {
    await new Future.delayed(Duration(seconds: 3));
    return ;
  }
}

