import 'package:finalexam/model/item_model.dart';
import 'package:flutter/material.dart';
import 'package:finalexam/provider/todo_db.dart';
import 'package:finalexam/screen/detail_item_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TodoList extends StatefulWidget {
  final int day;
  final int mode;
  final String user;
  TodoList({
    @required this.day,
    @required this.mode,
    @required this.user
  });
  @override
  _TodoListState createState() => _TodoListState(day: this.day, mode: this.mode, user:this.user);
}

class _TodoListState extends State<TodoList> {
  final db = TodoDataBaseService();
  final ScrollController scrollController = ScrollController();
  final int day;
  final int mode;
  final String user;

  _TodoListState({
    @required this.day,
    @required this.mode,
    @required this.user
  });

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> docs) {
    return Column(
      children: docs.map((doc) =>
          _buildListItem(context, Todo.fromFireStore(doc))).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, Todo todo) {
    switch(mode){
      case 0:
      case 1:
        return InkWell(
          onTap: () =>
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      DetailItemScreen(
                          id:todo.id, name : todo.name, info : todo.info, pickedDay: todo.time.toDate(), uid: user, pickedCategory: todo.category,))),
          child: _build(context, todo,),
        );
        break;
      case 2:
        if(todo.day > day){
          return InkWell(
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DetailItemScreen(
                          id:todo.id, name : todo.name, info : todo.info, pickedDay: todo.time.toDate(), uid: user, pickedCategory: todo.category,))),
            child: _build(context, todo,),
          );
        }
        return Container();
        break;
      case 3:
        if(todo.day < day){
          return InkWell(
            onTap: () =>
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DetailItemScreen(
                          id:todo.id, name : todo.name, info : todo.info, pickedDay: todo.time.toDate(), uid: user, pickedCategory: todo.category,))),
            child: _build(context, todo,),
          );
        }

    }
    return Container();
  }


  Widget _build(BuildContext context, Todo todo) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              MaterialButton(
                onPressed: () => db.doneButtonTodo(todo.id, todo.done),
                child: Checkbox(
                    value: todo.done,
                    onChanged: null
                ),
              ),
              Text(todo.name)
            ],
          ),
        ),
      ],
    );
  }

  int changeDaytoInt(DateTime time) {
    return int.parse(time.year.toString() + "${time.month
        .toString()
        .length == 2 ? time.month.toString() : "0" + time.month.toString()}" +
        "${time.day
            .toString()
            .length == 2 ? time.day.toString() : "0" + time.day.toString()}");
  }


  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case 0:
      case 1:
        return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('Users').document(user).collection('Todos').where("Done",isEqualTo: false).where("Day", isEqualTo: day).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return Column(
                  children: <Widget>[
                    Container(
                      child: _buildList(context, snapshot.data.documents),
                      padding: EdgeInsets.only(left: 20.0, right: 8.0),
                    ),
                  ],
                );
              }
              return Container();
            }
        );
        break;
      case 2:
      case 3:
        return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('Users').document(user).collection('Todos').where("Done",isEqualTo: false).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return Container(
                  child: _buildList(context, snapshot.data.documents),
                  padding: EdgeInsets.only(left: 20.0, right: 8.0),
                );
              }
              return Container();
            }
        );
        break;
    }
    return Container();
  }
}