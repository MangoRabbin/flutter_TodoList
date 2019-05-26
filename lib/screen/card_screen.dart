import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:finalexam/model/card_item_model.dart';
import 'package:finalexam/model/item_model.dart';

var t  = DateTime.now();

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{

  var appColors = [Color.fromRGBO(231, 129, 109, 1.0),Color.fromRGBO(99, 138, 223, 1.0),Color.fromRGBO(111, 194, 173, 1.0), Color.fromRGBO(133,199, 231, 1.0), Color.fromRGBO(126, 231, 109, 1.0), Color.fromRGBO(241, 109, 109, 1.0),Color.fromRGBO(231,109,219,1.0)];
  var cardIndex = 0;
  ScrollController scrollController;
  var currentColor = Color.fromRGBO(231, 129, 109, 1.0);

  var cardsList = [CardItemModel("Personal", Icons.account_circle, 9, 0.83),CardItemModel("Work", Icons.work, 12, 0.24),CardItemModel("Home", Icons.home, 7, 0.32)];

  AnimationController animationController;
  ColorTween colorTween;
  CurvedAnimation curvedAnimation;
  int weekCheck;

  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    weekCheck = DateTime.now().weekday % 7 - 1;
  }

  Widget _addCard(BuildContext context) {
    return InkWell(
      onTap: () =>  Navigator.of(context).pushNamed('/add'),
          child: Card(
        child: Container(
          width: 250.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.add, color: appColors[0]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Icon(Icons.add_circle,color: appColors[0],)
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text("add", style: TextStyle(fontSize: 28.0),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Product').orderBy('Day',descending: false).snapshots(),
      builder: (context,snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        else{
          if(!snapshot.hasData){
            return _addCard(context);
          }
          return _buildList(context,snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>docs) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      children: docs.map((doc) => _buildCardItem(context, doc)).toList(),
    );
  }

  Widget _buildCardItem(BuildContext context, DocumentSnapshot data) {
     return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                width: 250.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: <Widget>[
                    //       Icon(cardsList[position].icon, color: appColors[position],),
                    //       Icon(Icons.more_vert, color: Colors.grey,),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text("${data.documentID}day Tasks", style: TextStyle(color: Colors.grey),),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          //   child: Text("${data.metadata}", style: TextStyle(fontSize: 28.0),),
                          // ),
                          StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance.collection('Product').document(data.documentID).collection(data.documentID).snapshots(),
                            builder: (context,snapshot) {
                              if (!snapshot.hasData) return LinearProgressIndicator();
                              else{
                                if(snapshot.data.documents.length == 0){
                                  return Text("TODO");
                                }
                                return Column(
                                  children : snapshot.data.documents.map((doc) => _buildTodoList(context, doc)).toList()
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),
            ),
          ),
          onHorizontalDragEnd: (details) {

            animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
            curvedAnimation = CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn);
            animationController.addListener(() {
              setState(() {
                currentColor = colorTween.evaluate(curvedAnimation);
              });
            });

            if(details.velocity.pixelsPerSecond.dx > 0) {
              if(cardIndex>0) {
                cardIndex--;
                colorTween = ColorTween(begin:currentColor,end:appColors[cardIndex]);
              }
            }else {
              if(cardIndex<appColors.length) {
                cardIndex++;
                colorTween = ColorTween(begin: currentColor,
                    end: appColors[cardIndex]);
              }
            }
            setState(() {
              scrollController.animateTo((cardIndex)*256.0, duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
            });

            colorTween.animate(curvedAnimation);

            animationController.forward( );

          },
        );
  }
  // Future _changeDone(BuildContext context, Product product) async {
  //   DocumentReference doc = Firestore.instance.collection('Product').
  // }

  Widget _buildTodoList(BuildContext context, DocumentSnapshot doc) {
    final product = Product.fromSnapshot(doc);
    return ListTile(
      title: Text(product.name),
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: currentColor,
      appBar: new AppBar(
        title: new Text("TODO", style: TextStyle(fontSize: 16.0),),
        backgroundColor: currentColor,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search),
          ),
        ],
        elevation: 0.0,
      ),
      body: new Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Row(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 32.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Icon(Icons.account_circle, size: 45.0, color: Colors.white,),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0,16.0,0.0,12.0),
                      child: Text("Hello, User.", style: TextStyle(fontSize: 30.0, color: Colors.white, fontWeight: FontWeight.w400),),
                    ),
                    Text("여기는 total, done, not yet 부분", style: TextStyle(color: Colors.white))
                    // Text("Looks like feel good.", style: TextStyle(color: Colors.white),),
                    // Text("You have 3 tasks to do today.", style: TextSrtyle(color: Colors.white,),),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 16.0),
                  child: Text(DateTime.now().month.toString() + DateTime.now().day.toString() + DateTime.now().year.toString(), style: TextStyle(color: Colors.white),),
                ),
                Container(
                  height: 350.0,
                  child: _buildBody(context)
                ),
              ],
            )
          ],
        ),
      ),
      drawer: Drawer(),
    );
  }
}