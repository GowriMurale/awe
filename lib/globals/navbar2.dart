import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../Screens/login_screen.dart';
import 'my_colors.dart';
class Navbar2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopNavbar2();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return DesktopNavbar2();
        } else {
          return MobileNavbar2();
        }
      },
    );
  }
}

class DesktopNavbar2 extends StatefulWidget {
  @override
  State<DesktopNavbar2> createState() => _DesktopNavbar2State();
}

class _DesktopNavbar2State extends State<DesktopNavbar2> {
  Future<void> _confirmSignOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to Log out?'),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Just close the dialog
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog before signing out
              await _signOut(context); // Call the sign out method
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Amplify.Auth.signOut();
      Get.offAll(() => LoginScreen()); // Redirect to login screen
    } on AuthException catch (e) {
      _showErrorDialog(context, e.message);
    }
  }



  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Card(
      elevation: 1,
      child: Container(
        height: size.height * 0.08,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(topRight: Radius.circular(5),topLeft: Radius.circular(5),bottomLeft: Radius.zero,bottomRight: Radius.zero),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: size.width * 0.007,
              top: size.height * 0.003,
            ),
            child: Container(
              width: size.width * 0.145,
              decoration: BoxDecoration(),
            child: Image.asset('assets/images/awe logo.png'),
                    ),
          ),

            SizedBox(width: size.width * 0.75,),
            GestureDetector(
              onTap: (){
                _confirmSignOut(context);
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 21,
                    child: Image.asset('assets/images/user image.png'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileNavbar2 extends StatelessWidget {
  const MobileNavbar2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

      ],
    );
  }
}