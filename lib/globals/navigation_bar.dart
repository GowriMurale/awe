import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import 'my_colors.dart';
class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  DateTime now = DateTime.now(); // Get the current date and time
  String formattedDate = DateFormat(' dd/MM/yyyy    HH:mm:ss').format(DateTime.now());



  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Row(
              children: [
                SizedBox(width: 20,),
                Center(
                  child: Container(
                    height: 190,
                    width: 190,
                    child: Image.asset('assets/images/awe logo.png',fit: BoxFit.contain),),),
              ]),
          Spacer(), // Pushes the next widgets to the right
          Icon(Icons.mail_outline_outlined),
          SizedBox(width: 30), // spacing between icons
          Icon(Icons.notifications_outlined),
          SizedBox(width: 70), // spacing between icons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome Mdm Wong',
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontStyle: FontStyle.normal), // Reduce height between lines
              ),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    fontStyle: FontStyle.normal), // Same height to ensure no spacing
              ),
            ],
          ),
          SizedBox(width: 30,),
          Center(
            child: Container(
              height: 50,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/user image.png'),
                radius: 30,
                child: Container(
                  height: 30,
                  width: 100,
                  padding: EdgeInsets.only(left: 25,bottom: 2,top: 10),
                  child: IconButton(
                    onPressed: () {
                      _showPopupMenu(context);
                    }, icon: Icon(Icons.edit_outlined,),
                  ),
                ),

              ),),),
          SizedBox(width: 30), // spacing between the profile and app bar end
        ],
        toolbarHeight: 75.0,
      ),
    );
  }
}

void _showEditDialog(BuildContext context) {
  TextEditingController firstName=TextEditingController();
  TextEditingController lastName=TextEditingController();
  TextEditingController email=TextEditingController();
  TextEditingController position=TextEditingController();
  TextEditingController mobile=TextEditingController();
  TextEditingController dob=TextEditingController();
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
void _showPopupMenu(BuildContext context) {
  showMenu(
    color: Colors.white,
    context: context,
    position: RelativeRect.fromLTRB(100, 70, 5, 300), // Position of the menu
    items: [
      PopupMenuItem<int>(
        value: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //SizedBox(height: 20,),
            Container(
              height: 50,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/user image.png'),
                radius: 30,
                child: Container(
                  height: 30,
                  width: 100,
                  padding: EdgeInsets.only(left: 25,bottom: 2,top: 10),
                  child: IconButton(
                    onPressed: () {
                      _showEditDialog(context);
                    }, icon: Icon(Icons.edit_outlined,),
                  ),
                ),),),
            //SizedBox(height: 1,),
            Text('Personal Info Edit',
              style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontStyle: FontStyle.normal),),
            SizedBox(height: 7,),
            Divider(
              thickness: 4.0,
              color: Colors.black54,
            ),
            SizedBox(height: 3,),
            Row(
                children: [
                  Container(
                    height: 28,
                    width: 125,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),),
                  SizedBox(width: 5,),
                  Container(
                    height: 28,
                    width: 125,
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),),
                ]),
            SizedBox(height: 10,),
            Container(
              height: 28,
              width: 330,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),

              ),),
            SizedBox(height: 10,),
            Container(
              height: 28,
              width: 330,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),),
            SizedBox(height: 10),
            Row(
                children: [
                  Container(
                    height: 30,
                    width: 135,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          BorderSide(color: Colors.yellow, width: 3), // Change border color and width
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                        ),
                      ),
                      child: Text('Change Password',style: TextStyle(
                          fontSize: 10,fontWeight: FontWeight.bold,color: Colors.black)),
                    ),
                  ),

                  SizedBox(width: 10,),
                  Container(
                    height: 30,
                    width: 110,
                    child: Material(
                      elevation: 5.0, // Add shadow/elevation
                      borderRadius: BorderRadius.circular(7), // Rounded corners
                      color: Colors.transparent, // To prevent color overrides
                      child: MaterialButton(
                        onPressed: () {
                          // Action on press
                        },
                        color: Colors.yellow,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 50)
                ]),
          ],
        ),
      ),
    ],
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