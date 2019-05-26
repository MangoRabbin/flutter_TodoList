import 'package:flutter/material.dart';
import 'package:finalexam/constant/constant.dart';
// import 'package:flutter/semantics.dart';
import 'package:finalexam/model/item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:finalexam/screen/detail_screen.dart';



// final FirebaseAuth _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
 }
 
 class _HomeScreenState extends State<HomeScreen>{
   List<String> dropdownValue1 = ['ALL','accessories','home','clothing'];
   List<String> dropdownValue2 = ['ASC','DESC'];

   String dropdownV1;
   String dropdownV2;

   @override
   void initState() {
     super.initState();
     dropdownV1 = 'ALL';
     dropdownV2 = 'ASC';
   }

   @override
   void dispose() {
     super.dispose();
   }

  Stream<QuerySnapshot> changeSearchMode() {
      if (dropdownValue1.indexOf(dropdownV1) == 0)  return Firestore.instance.collection('Product').orderBy('Price',descending: dropdownV2 == "ASC" ? false : true).snapshots();
      return Firestore.instance.collection('Product').where('Category',isEqualTo:dropdownValue1[dropdownValue1.indexOf(dropdownV1)]).orderBy('Price',descending: dropdownV2 == "ASC" ? false : true).snapshots();
    
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: changeSearchMode(),
      builder: (context,snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        else{
          if(snapshot.data.documents.length == 0){
            return Container(
              child: Center(
                child: Text("Nothing"),
              ),
            );
          }
          return _buildList(context,snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return GridView.count(
      primary: false,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      crossAxisCount: 1,
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildGridItem(context,data)).toList(),
    );
  }

  Widget _buildGridItem(BuildContext context, DocumentSnapshot data) {
    final product = Product.fromSnapshot(data);
    return Container(
      width: 1.0,
      height: 1.0,
      // child: Text(product.likes.length.toString()),
      // color: product.likes.length > 1 ? Colors.blueAccent: product.likes.length == 1 ? Colors.green : Colors.white
    );
    // return Card(
    //   clipBehavior: Clip.antiAlias,
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: <Widget>[
    //       Hero(
    //         tag: product.name,
    //         child: Container(
    //           width: MediaQuery.of(context).size.width*1,
    //           height: MediaQuery.of(context).size.height*0.114,
    //           child: Image.network(
    //             product.image,
    //             fit: BoxFit.fill
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Container(
    //               padding: EdgeInsets.fromLTRB(20.0, 8.0, 16.0, .0),
    //               child: Text(
    //                 product.name,
    //                 style: TextStyle(
    //                   fontSize: 13.0,
    //                   fontWeight: FontWeight.bold
    //                 ),
    //                 maxLines: 1,
    //               ),
    //             ),
    //             Container(
    //               padding: EdgeInsets.fromLTRB(20.0, 8.0, 16.0, .0),
    //               child: Text(
    //                 "\$ ${product.price.toString()}",
    //                 style: TextStyle(
    //                   fontSize: 13.0,
    //                   fontWeight: FontWeight.bold
    //                 ),
    //               ),
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: <Widget>[
    //                 FutureBuilder(
    //                 future: FirebaseAuth.instance.currentUser(),
    //                 builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
    //                   if (snapshot.hasData){
    //                      String uid = snapshot.data.uid;
    //                   return FlatButton(
    //                     onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DetailScreen(id: data.documentID, uid: uid))),
    //                     child: Text(
    //                       "more",
    //                       style: TextStyle(
    //                         color: Colors.lightBlue
    //                       ),
    //                     ),
    //                   );}}
    //                 )
    //               ],
    //             )
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
  
  

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         backgroundColor: Colors.grey,
         centerTitle: true,
         title: Text("Main", style: myTextStyle,),
         leading: IconButton(
           icon: Icon(Icons.person),
           onPressed: () => Navigator.of(context).pushNamed('/profile'),
         ),
         actions: <Widget>[
           IconButton(
             icon: Icon(Icons.add),
             onPressed: () => Navigator.of(context).pushNamed('/add'),
           )
         ],
       ),
       body: SingleChildScrollView(
           child: Column(
           mainAxisAlignment: MainAxisAlignment.start,
           children: <Widget>[
             Container(
               padding: EdgeInsets.only(top: 20.0,bottom: 20.0),
              //  height: ScreenUtil.height*0.2,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: <Widget>[
                   DropdownButton<String>(
                     value: dropdownV1,
                     onChanged: (v) => setState((){dropdownV1 = v;}),
                     items: dropdownValue1.map<DropdownMenuItem<String>>((String value){
                       return DropdownMenuItem<String>(
                         value: value,
                         child: Text(value)
                       );
                     }).toList(),
                   ),
                   SizedBox(
                     width: MediaQuery.of(context).size.width*0.2
                   ),
                   DropdownButton<String>(
                     value: dropdownV2,
                     onChanged: (v) => setState((){dropdownV2 = v;}),
                     items: dropdownValue2.map<DropdownMenuItem<String>>((String value){
                       return DropdownMenuItem<String>(
                         value: value,
                         child: Text(value)
                       );
                     }).toList(),
                   )
                 ],
               ),
             ),
              _buildBody(context)
           ],
         ),
       ),
     );
   }
 }