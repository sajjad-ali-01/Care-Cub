import 'package:doctor/Doctorlist.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(DoctorsApp());
}
class DoctorsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,

      title: 'Doctors Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DoctorList(),
    );
  }
}
