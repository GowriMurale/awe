

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:awe_project/Screens/login_screen.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Navbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopNavbar();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return DesktopNavbar();
        } else {
          return MobileNavbar();
        }
      },
    );
  }
}

class DesktopNavbar extends StatefulWidget {
  @override
  State<DesktopNavbar> createState() => _DesktopNavbarState();
}

class _DesktopNavbarState extends State<DesktopNavbar> {
  TextEditingController firstName=TextEditingController();
  TextEditingController lastName=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController position=TextEditingController();
  TextEditingController mobile=TextEditingController();
  TextEditingController dob=TextEditingController();

  Future<void> _confirmSignOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
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

  bool _isEditing = false;

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  //Function to open dialog
  void _showEditDialog(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          width:  size.width * 0.410,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width * 0.025,),
                  Text(
                    "Personal Information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: size.width * 0.230,),
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.cancel_outlined,size: 25,color: black,))
                ],
              ),
              Divider(),
              SizedBox(height: size.height * 0.012,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.08,),
                  Text('First Name', style: TextStyle(fontSize: 14)),
                  SizedBox(width: size.width * 0.093,),
                  Text('Last Name', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: size.height * 0.007,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width* 0.080,),
                    myContainer(context, firstName),
                  SizedBox(width: size.width * 0.040,),
                  myContainer(context, lastName),
                ],
              ),
              SizedBox(height:size.height * 0.020,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  Text('Email address', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: size.height *0.007,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  newContainer(context, email)
                ],
              ),
              SizedBox(height:size.height * 0.020,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  Text('Position', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: size.height *0.007,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  newContainer(context, position)
                ],
              ),
              SizedBox(height:size.height * 0.020,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  Text('Mobile Number', style: TextStyle(fontSize: 14)),
                  SizedBox(width: size.width * 0.077,),
                  Text('Date of birth', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height:size.height * 0.007,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  myContainer(context, mobile),
                  SizedBox(width: size.width * 0.040,),
                  Container(
                    width: size.width * 0.10,
                    height: size.height * 0.032,
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: dob,
                        readOnly: true, // Makes the TextField read-only to prevent keyboard from appearing
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              // Show date picker when the calendar icon is pressed
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(), // Default to today's date
                                firstDate: DateTime(1900), // Start date for the date picker
                                lastDate: DateTime.now(), // End date for the date picker
                              );

                              if (selectedDate != null) {
                                // Format the selected date and update the TextField
                                String formattedDate = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                                dob.text = formattedDate; // Set the formatted date in the TextField
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: grey, width: 1),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          contentPadding: EdgeInsets.all(7),
                        ),
                      ),
                    ),
                  )


                ],
              ),
              SizedBox(height:size.height * 0.040,),
              MaterialButton(
                minWidth: size.width * .06,
                height: size.height * 0.03,
                onPressed: () {
                  Get.back(); // Close the dialog
                },
                child: Text('Save',style: TextStyle(fontSize: 16,fontFamily: 'Inter',),),
                color: Colors.yellow,
                textColor: Colors.black,
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
    );
  }



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Card(
          elevation: 1,
          child: Container(
            height: size.height * 0.125,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5),
                topLeft: Radius.circular(5),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: size.width * 0.005,
                    top: size.height * 0.003,
                  ),
                  child: Container(
                    width: size.width * 0.130,
                    decoration: BoxDecoration(),
                    child: Image.asset('assets/images/awe logo.png'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: size.width * 0.030,
                    top: size.height * 0.030,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: (){
                          _showEditDialog(context);
                          },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              child: Image.asset('assets/images/user image.png'),
                            ),
                          ],
                        ),
                      ),
                      // if (_isEditing)
                        // SingleChildScrollView(
                        //   child: Container(
                        //     width: size.width * 0.135,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(5),
                        //       color: Colors.grey.shade100,
                        //     ),
                        //     child: Column(
                        //       children: [
                        //         SizedBox(height: size.height * 0.004),
                        //         GestureDetector(
                        //           onTap: (){
                        //             // _showEditDialog(context);
                        //             },
                        //           child: CircleAvatar(
                        //             radius: 15,
                        //             child: Image.asset('assets/images/user image.png'),
                        //           ),
                        //         ),
                        //         SizedBox(height: size.height * 0.003),
                        //         Text(
                        //           'Personal Edit Info',
                        //           style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: Colors.black),
                        //         ),
                        //         Divider(),
                        //         SizedBox(height: size.height * 0.010),
                        //         Row(
                        //             mainAxisAlignment: MainAxisAlignment.start,
                        //           children: [
                        //             SizedBox(width: size.width * 0.020),
                        //             Container(
                        //               width: size.width * 0.038,
                        //               height:  size.height * 0.028,
                        //               decoration: BoxDecoration(
                        //                 color: Colors.white,
                        //                 border: Border.all(color: Colors.grey.shade400),
                        //                 borderRadius: BorderRadius.circular(2),
                        //               ),
                        //               child: Text(
                        //                 'mdm',
                        //                 style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: Colors.black),
                        //               ),
                        //             ),
                        //             SizedBox(width: size.width * 0.020),
                        //             Container(
                        //               width: size.width * 0.038,
                        //               height:  size.height * 0.028,
                        //               decoration: BoxDecoration(
                        //                 color: Colors.white,
                        //                 border: Border.all(color: Colors.grey.shade400),
                        //                 borderRadius: BorderRadius.circular(2),
                        //               ),
                        //               child: Text(
                        //                 'wong',
                        //                 style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: Colors.black),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         SizedBox(height: size.height * 0.015),
                        //           Row(
                        //             mainAxisAlignment: MainAxisAlignment.start,
                        //             children: [
                        //               SizedBox(width: size.width * 0.020),
                        //               Container(
                        //                 width:size.width * 0.095,
                        //                 height: size.height *  0.028,
                        //                 decoration: BoxDecoration(
                        //                   color: Colors.white,
                        //                   border: Border.all(color: Colors.grey.shade400),
                        //                   borderRadius: BorderRadius.circular(2),
                        //                 ),
                        //                 child: Text(
                        //                   '234568456',
                        //                   style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: Colors.black),
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         SizedBox(height: size.height * 0.010),
                        //         Row(
                        //           children: [
                        //             SizedBox(width: size.width * 0.020),
                        //             Container(
                        //               width:size.width * 0.095,
                        //               height: size.height *  0.028,
                        //               decoration: BoxDecoration(
                        //                 color: Colors.white,
                        //                 border: Border.all(color: Colors.grey.shade400),
                        //                 borderRadius: BorderRadius.circular(2),
                        //               ),
                        //               child: Text(
                        //                 'adinin@gmail.com',
                        //                 style: TextStyle(fontSize: 14,fontFamily: 'Inter',color: Colors.black),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         SizedBox(height: size.height * 0.015),
                        //         Row(
                        //           children: [
                        //             SizedBox(width: size.width * 0.010),
                        //             MaterialButton(
                        //               onPressed: () {},
                        //               minWidth: size.width * 0.020,
                        //               height:size.height * 0.032,
                        //               color: Colors.white,
                        //               child: Text(
                        //                 'Change Password',
                        //                 style: TextStyle(
                        //                   color: Colors.black,
                        //                   fontSize: 12,fontFamily: 'Inter'
                        //                 ),
                        //               ),
                        //             ),
                        //             SizedBox(width: size.width * 0.010),
                        //             MaterialButton(
                        //               onPressed: () {
                        //                 _confirmSignOut(context);
                        //               },
                        //               minWidth: size.width * 0.020,
                        //               height:size.height * 0.032,
                        //               color: yellow,
                        //               child: Text(
                        //                 'Log out',
                        //                 style: TextStyle(
                        //                   color: Colors.black,
                        //                   fontSize: 12,fontFamily: 'Inter'
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  }
}

class MobileNavbar extends StatelessWidget {
  const MobileNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

      ],
    );
  }
}

Widget myContainer(BuildContext context, TextEditingController controller){
  final Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width * 0.10,
    height: size.height * 0.036,
    child: Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: grey,width: 1),
            borderRadius: BorderRadius.circular(0),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.010, horizontal: size.width * 0.007),
        ),

      ),
    ),
  );
}

Widget newContainer(BuildContext context, TextEditingController controller){
  final Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width * 0.24,
    height: size.height * 0.05, // Increase the height for better alignment
    child: Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 16), // Adjust font size if necessary
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: grey, width: 1),
            borderRadius: BorderRadius.circular(0),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.010, horizontal: size.width * 0.007), // Adjust vertical padding
        ),
      ),
    ),
  );

}