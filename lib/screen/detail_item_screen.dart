import 'package:flutter/material.dart';
import 'package:finalexam/provider/todo_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalexam/model/user_model.dart';

class DetailItemScreen extends StatefulWidget {

  final String id;
  final String name;
  final String info;
  final DateTime pickedDay;
  final String uid;
  final String pickedCategory;

  DetailItemScreen(
  {
    @required this.id,
    @required this.name,
    @required this.info,
    @required this.uid,
    @required this.pickedDay,
    @required this.pickedCategory
  }
  );

  @override
  DetailItemScreenState createState() => DetailItemScreenState(id:this.id,name:this.name,info:this.info,pickedDay:this.pickedDay,uid:this.uid,pickedCategory: this.pickedCategory);
  
}

class DetailItemScreenState extends State<DetailItemScreen> {

  final String id;
  final String name;
  final String info;
  final DateTime pickedDay;
  final String uid;
  final String pickedCategory;
  String pickCategory;
  bool buttonCategoryState;

  DetailItemScreenState({this.id,this.name,this.info, this.pickedDay,this.uid,this.pickedCategory});

  TextEditingController nameTextController = TextEditingController();
  TextEditingController infoTextController = TextEditingController();
  FocusNode nameFocus;
  DateTime pickDay;


  @override
  void initState() {
    super.initState();
    nameTextController.text = name;
    infoTextController.text = info;
    pickDay = pickedDay;
    pickCategory = pickedCategory;
    buttonCategoryState = false;
    nameFocus = FocusNode();
  }

  @override
  void dispose() {
    nameFocus.dispose();
    nameTextController.dispose();
    infoTextController.dispose();
    super.dispose();
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
      });
      // TodoDataBaseService().createTodo("test", Todo.toInsert(nameTextController.value.text, infoTextController.value.text, pickDay));
    }
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Divider(),
          FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance.collection('Users').document(uid).collection("user").document("user").get(),
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

  Widget _buildCategoryButton(BuildContext context, DocumentSnapshot doc){
    CurrentUser user = CurrentUser.fromFirestore(doc);
    return Container(
        height: MediaQuery.of(context).size.height*0.06,
        child: SingleChildScrollView(
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

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('Users').document(uid).collection('user').document('user').snapshots(),
      builder: (context, snapshot) {
        FocusScope.of(context).requestFocus(nameFocus);
        var currentUser = CurrentUser.fromFirestore(snapshot.data);
        return Scaffold(
            body: SafeArea(
              child: Center(
               child: Container(
                 padding: EdgeInsets.fromLTRB(20.0,10.0, 20.0, 0.0),
                 child:Column(
                  children: <Widget>[
                    Row(
                     children: <Widget>[
                       IconButton(
                         icon: Icon(
                             Icons.arrow_back,
                           color: Colors.grey,
                         ),
                         onPressed: () async {
                           TodoDataBaseService().updateTodo(id, nameTextController.value.text, infoTextController.value.text, pickDay, pickCategory);
                           Navigator.of(context).pop();
                         },
                       ),
                       Spacer(),
                       IconButton(
                         icon: Icon(
                             Icons.delete,
                           color: Colors.grey,
                         ),
                         onPressed: () async {
                           TodoDataBaseService().removeDetailTodo(id,pickDay);
                           Navigator.of(context).pop();
                         },
                       )
                     ],
                 ),

                    Container(
                      padding: EdgeInsets.fromLTRB(15.0,20.0, 20.0, 0.0),
                      child: TextField(
                        controller: nameTextController,
                        focusNode: nameFocus,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold
                      ),
                      decoration: InputDecoration(
                          hintText: "제목입력",
                          hintStyle: TextStyle(
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold
                          )
                      ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(15.0,20.0, 20.0, 0.0),
                      child: TextField(
                        controller: infoTextController,
                        style: TextStyle(
                            fontSize: 23.0,
                            fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                            hintText: "세부내용",
                            hintStyle: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState((){
                        buttonCategoryState = true;
                      }),
                      child: Container(
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
                              Text("카테고리 : $pickCategory", style: TextStyle(fontSize: 17.0),)
                            ],
                          )

                      ),
                    ),
                    buttonCategoryState ? _buildCategories(context) : Container(),
                    InkWell(
                      onTap: () async => _selectDate(),
                      child: Container(
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
                              Icon(Icons.calendar_today,color: Colors.lightBlueAccent,),
                              SizedBox(width: 20.0,),
                              Text("${pickDay.month.toString()}월  ${pickDay.day.toString()} 일", style: TextStyle(color: Colors.lightBlueAccent),)
                            ],
                          )

                      ),
                    ),

                  ],
                ),
               ),
          ),
            ),
        );
      }
    );
  }
}
