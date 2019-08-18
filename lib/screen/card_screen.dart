import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalexam/screen/main_todo_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finalexam/screen/detail_item_screen.dart';
import 'package:finalexam/model/user_model.dart';
import 'package:finalexam/model/item_model.dart';
import 'package:finalexam/provider/todo_db.dart';
import 'package:finalexam/widget/add_todo.dart';
import 'package:finalexam/widget/insert_category_widget.dart';
import 'package:finalexam/screen/calendar_screen.dart';



class CardPage extends StatefulWidget {
  final String user;
  CardPage({this.user});
  @override
  _CardPageState createState() => new _CardPageState(user: this.user);
}

class _CardPageState extends State<CardPage> with TickerProviderStateMixin{


  _CardPageState({this.user});
  final db = TodoDataBaseService();
  final auth = FirebaseAuth.instance;
  List<Widget> cards;
  var appColors = [Color.fromRGBO(231, 129, 109, 1.0),Color.fromRGBO(99, 138, 223, 1.0),Color.fromRGBO(111, 194, 173, 1.0), Color.fromRGBO(133,199, 231, 1.0), Color.fromRGBO(126, 231, 109, 1.0), Color.fromRGBO(241, 109, 109, 1.0),Color.fromRGBO(231,109,219,1.0)];
  var cardIndex = 0;
  ScrollController scrollController;
  var currentColor = Color.fromRGBO(231, 129, 109, 1.0);
  int categoryLength ;
  final String user;

  AnimationController animationController;
  ColorTween colorTween;
  CurvedAnimation curvedAnimation;
  TextEditingController nameController = TextEditingController();
  int weekCheck;
  DateTime date;
  Animation<int> alpha ;

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
//    weekdayV1 = weekdayValue1[DateTime.now().weekday-1];
    weekCheck = DateTime.now().weekday % 7 - 1;
    date = DateTime.now();
    categoryLength = 2;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }



  Widget _buildBody(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('Users').document(user).collection("user").document("user").snapshots(),
      builder: (context,snapshot) {
        if (snapshot.data.exists) return _buildList(context, snapshot.data);
        else if (!snapshot.hasData) return LinearProgressIndicator();
        else return  Container();
      },
    );
  }

  Widget _buildList(BuildContext context, DocumentSnapshot docs) {
    CurrentUser user = CurrentUser.fromFirestore(docs);
    if(user.categories != null){
      categoryLength = user.categories.length;
      return Container(
        child: ListView(
            physics: NeverScrollableScrollPhysics(),
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            children:
              user.categories.map((doc) => _buildCardItem(context, doc)).toList()

        ),
      );
    }
    return Container();
  }

  Widget _buildCardItem(BuildContext context, String category) {
    return GestureDetector(
      child: Card(
        child: Container(
          width: MediaQuery.of(context).size.width*0.9,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.fromLTRB(8.0,10.0,0,20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Text("$category Tasks", style: TextStyle(color: currentColor,fontSize: 20.0,),),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 18.0),
                            child:
                            category.compareTo("All") ==0 || category.compareTo("Scheduled") == 0 ? Container():IconButton(
                              icon: Icon(Icons.delete,color: Colors.deepOrangeAccent,),
                              onPressed: () => TodoDataBaseService().categoryDelete(category),
                            ),

                          )
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height*0.60,
                      child: SingleChildScrollView(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: category.compareTo("All") == 0 ? Firestore.instance.collection('Users').document(user).collection('Todos').where('Done', isEqualTo: false).snapshots() : Firestore.instance.collection('Users').document(user).collection('Todos').where('Done', isEqualTo: false).where("Category",isEqualTo: category).snapshots(),
                          builder: (context,snapshot) {
                            if (!snapshot.hasData) return LinearProgressIndicator();
                            else{
                              if(snapshot.data.documents.length == 0){
                                return Container();
                              }
                              return Column(
                                  children : snapshot.data.documents.map((doc) => _buildTodoList(context, doc)).toList()
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
        ),
      ),

      onHorizontalDragEnd: (details) {
        animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
        curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn);
        animationController.addListener(() {
          setState(() {
//            currentColor = colorTween.evaluate(curvedAnimation);
            alpha = IntTween(begin: cardIndex, end: categoryLength).animate(curvedAnimation);
            currentColor = appColors[cardIndex % appColors.length +1];
          });
        });

        if(details.velocity.pixelsPerSecond.dx > 0) {
          if(cardIndex>0) {
            cardIndex--;
//            colorTween = ColorTween(begin:currentColor,end:appColors[cardIndex]);
          }
        }else {
          if(cardIndex<categoryLength-1) {
            cardIndex++;
//            colorTween = ColorTween(begin: currentColor,
//                end: appColors[(cardIndex % appColors.length) + 1]);
          }
        }
        setState(() {
          scrollController.animateTo((cardIndex)*MediaQuery.of(context).size.width*0.92, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
        });

//        colorTween.animate(curvedAnimation);

        animationController.forward( );

      },
    );
  }

  Widget _buildTodoList(BuildContext context, DocumentSnapshot doc) {
    final todo = Todo.fromFireStore(doc);
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left: 15.0),
        alignment: Alignment.centerLeft,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                MaterialButton(
                  onPressed: () => db.doneButtonTodo(todo.id, todo.done),
                  child: Checkbox(
                      value: todo.done,
                      onChanged: null
                  ),
                ),
                Text(
                  "${todo.name}",
                  style: TextStyle(
                      decoration: todo.done ? TextDecoration.lineThrough : TextDecoration.none,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black87
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right:10.0),
                  child: Text("${todo.time.toDate().month}월 ${todo.time.toDate().day}일",style: TextStyle(color: Colors.grey,fontSize: 12.0),),
                )
                ],
            ),
            Divider()
          ],
        )
      ),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  DetailItemScreen(
                    id:todo.id, name : todo.name, info : todo.info, pickedDay: todo.time.toDate(), uid: user, pickedCategory: todo.category,))),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: new Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,30.0,0.0,12.0),
                        child: Text(
                            "해야 할 목록",
                            style: TextStyle(fontSize: 30.0,)
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height*0.75,
                    width: MediaQuery.of(context).size.width*0.9,
                    child: _buildBody(context)
                )

              ],
            ),
          ),
        ),
      ),

      bottomSheet: _deactivateBottomWidget(context),
      floatingActionButton:  Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton.extended(
            heroTag: "할 일 추가",
              backgroundColor: currentColor,
              onPressed: () => _todoInsert(),
              label: Row(
                children: <Widget>[
                  Icon(Icons.add),
                  Text("할 일 추가")
                ],
              )
          ),
          SizedBox( height: MediaQuery.of(context).size.height*0.01),
          FloatingActionButton.extended(
            heroTag: "카테고리 추가",
              backgroundColor: currentColor,
              onPressed: () => _categoryInsert(),
              label: Row(
                children: <Widget>[
                  Icon(Icons.add_to_photos),
                  Text("카테고리 추가")
                ],
              )
          ),
        ],

      ), floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                onPressed: () =>  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TodoMainScreen(user: user,) ), (Route<dynamic> route) => false),
                icon: Icon(
                  Icons.dehaze,
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


  Future<void> _todoInsert () async {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context){
          return Material(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  child: NewTodoInsertWidget(user: user,)
              ),
            ),
          );
        });
  }
  Future<void> _categoryInsert () async {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context){
          return Material(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container
                (
                  child: NewCategoryInsertWidget()
              ),

            ),
          );
        });
  }

}

