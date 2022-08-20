import 'package:flutter/material.dart';
import 'package:streetcheck/home_page.dart';

class StreetCheckApp extends StatelessWidget {
  const StreetCheckApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'StreetCheck'),
    );
  }
}
