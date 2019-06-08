import 'package:flutter/material.dart';
import 'package:finalexam/app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(FinalExam()));
}

