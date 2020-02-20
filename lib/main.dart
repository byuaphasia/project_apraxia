///
/// Project Apraxia
/// A flutter application for clinicians to measure WSD of patients
///
/// Project Folders
/// page - all the "Pages" which are widgets that have a Scaffold widget
/// widget - the helper widgets
/// controller - the logic controllers
///


import 'package:flutter/material.dart';
import 'package:project_apraxia/page/SignInPage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,

        buttonTheme: ButtonThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)
          )
        )
      ),
      home: SignInPage(),
    );
  }
}
