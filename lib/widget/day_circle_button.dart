import 'package:flutter/material.dart';

class DayCircleButton extends StatelessWidget {
  final Function callback;
  final String title;
  final IconData icon;
  final Color color;
  final bool activateButton;
  DayCircleButton({
    @required this.title,
    @required this.callback,
    @required this.icon,
    @required this.color,
    @required this.activateButton
  });


  

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      padding: EdgeInsets.only(),
        onPressed: activateButton ?  callback : null,
        borderSide: BorderSide(
            color: color,
          width: 2.4
        ),
        shape: CircleBorder(),
            child: Container(
          width: 60.0,
          height: 60.0,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Icon(
                  icon,
                  color: color,
                  size: 30.0,
                ),
              ),
              Text(
                  title,
                style: TextStyle(
                  fontSize: 16.0,
                  color: color
                ),
              )
            ],
        )),
    );
  }
}
