
import 'package:awe_project/Components/dashboard.dart';
import 'package:awe_project/globals/navbar.dart';
import 'package:flutter/material.dart';
import '../Components/leave_management.dart';

class LeaveViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //     begin: Alignment.centerLeft,
          //     end: Alignment.centerRight,
          //     colors: [
          //       Color.fromRGBO(195, 20, 50, 1.0),
          //       Color.fromRGBO(36, 11, 54, 1.0)
          //     ]),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Navbar(),
              ManagementView(),
            ],
          ),
        ),
      ),
    );
  }
}