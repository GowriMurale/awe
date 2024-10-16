import 'dart:io';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:awe_project/Components/apply_leave.dart';
import 'package:awe_project/Components/helper_class.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:awe_project/globals/navbar2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../globals/datefield.dart';
import '../models/LeaveStatus.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
class ApplyLeaveScreen extends StatefulWidget {
  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  TextEditingController leave=TextEditingController();
  TextEditingController from=TextEditingController();
  TextEditingController to=TextEditingController();
  TextEditingController reason=TextEditingController();
  TextEditingController  days=TextEditingController();

  final List<String> _leaveTypes = ['Annual Leave', 'Sick Leave', 'Hospitalisation Leave','Unpaid Authorised Leave','Marriage Leave',
    'Maternity/Paternity Leave','Compassionate Leave','Unpaid Unauthorised Leave'];

  String? _selectedRole;
  String? _selectedLeaveType;
  DateTime? selectedDate;
  bool isSelected=false;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isChecked = false;
  bool isHalfDay=false;
  bool isManager=false;
  bool isSuperior=false;
  String? selectedTicket;

  String? leaveTypeError;
  String? fromDateError;
  String? toDateError;
  String? applyToError;
  String? ticketError;
  String? reasonError;

  Future<void> _selectDate(BuildContext context, TextEditingController controller, bool isFromDate) async {
    DateTime firstDate = DateTime.now(); // Disable all previous dates

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate ? DateTime.now() : (_toDate ?? DateTime.now()),
      firstDate: firstDate, // No previous dates allowed
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
        controller.text = formattedDate;

        if (isFromDate) {
          _fromDate = pickedDate;
        } else {
          _toDate = pickedDate;
        }

        // Automatically calculate the number of days if both dates are selected
        if (_fromDate != null && _toDate != null) {
          _calculateDays();
        }
      });
    }
  }

  // Method to calculate the difference in days between two dates
  void _calculateDays() {
    if (_fromDate != null && _toDate != null) {
      // Calculate the difference in days between _fromDate and _toDate
      double dayDifference = _toDate!.difference(_fromDate!).inDays + 1;

      // If half-day is selected
      if (isHalfDay) {
        // Case 1: If the from and to dates are the same, the leave is half a day
        if (_fromDate == _toDate) {
          dayDifference = 0.5;
        }
        // Case 2: If the from and to dates are different, add 0.5 to the total days
        else {
          dayDifference -= 0.5; // Subtract 0.5 from the dayDifference to represent half of a day
        }
      }

      // Update the text field with the calculated days
      days.text = dayDifference.toString();
    }
  }

  bool _validateFields() {
    bool isValid = true;

    setState(() {
      // Reset all error messages
      leaveTypeError = null;
      fromDateError = null;
      toDateError = null;
      applyToError = null;
      ticketError = null;
      reasonError = null;

      // Validate Leave Type
      if (_selectedLeaveType == null || _selectedLeaveType!.isEmpty) {
        leaveTypeError = '* This field is required';
        isValid = false;
      }

      // Validate From Date
      if (from.text.isEmpty) {
        fromDateError = '* This field is required';
        isValid = false;
      }

      // Validate To Date
      if (to.text.isEmpty) {
        toDateError = '* This field is required';
        isValid = false;
      }

      // Validate Apply To (Manager or Superior checkbox)
      if (!isManager && !isSuperior) {
        applyToError = '* Please select either Manager or Superior.';
        isValid = false;
      }

      // Validate Reason
      if (reason.text.isEmpty) {
        reasonError = '* This field is required';
        isValid = false;
      }
    });

    return isValid;
  }


  Future<void> applyForLeave() async {
    // Get current user's ID
    String userId = await Amplify.Auth.getCurrentUser().then((user) => user.userId);

    if (_selectedLeaveType == null || from.text.isEmpty || to.text.isEmpty || days.text.isEmpty || reason.text.isEmpty) {
      // Show validation error dialog
      Get.defaultDialog(
        title: 'Error',
        content: Text('Please fill in all required fields.'),
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close the dialog
        },
      );
      return;
    }

    try {
      // Parse the from and to dates from the text fields
      DateTime? fromDate = DateFormat('dd/MM/yyyy').parse(from.text);
      DateTime? toDate = DateFormat('dd/MM/yyyy').parse(to.text);

      if (fromDate == null || toDate == null || fromDate.isAfter(toDate)) {
        Get.defaultDialog(
          title: 'Error',
          content: Text('Invalid date selection. Please check the from and to dates.'),
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Close the dialog
          },
        );
        return;
      }

      double numberOfDays = double.parse(days.text);
      print("Number of days: $numberOfDays");

      // Try to submit the leave request
      final leaveStatus = LeaveStatus(
        empID: userId, // Use current user's ID
        leaveType: _selectedLeaveType!,
        fromDate: TemporalDate(fromDate),
        toDate: TemporalDate(toDate),
        days: numberOfDays,
        applyTo: isManager ? 'Manager' : 'Superior',
        reason: reason.text,
      );
      final request = ModelMutations.create(leaveStatus);
      final response = await Amplify.API.mutate(request: request).response;
      print(response);

      if (response.errors.isNotEmpty || response.data == null) {
        // Show error dialog if mutation failed
        Get.defaultDialog(
          title: 'Error',
          content: Text('Failed to submit the leave application. Please try again.'),
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Close the dialog
          },
        );
      } else {
        // Show success dialog if mutation succeeded
        Get.defaultDialog(
          title: 'Success',
          content: Text('Your leave application has been submitted successfully.'),
          confirmTextColor: black,
          backgroundColor: Colors.white,
          buttonColor: Colors.grey.shade400,
          onConfirm: () {
            Get.back(); // Close the dialog
            Get.off(DashBoardScreeen()); // Navigate to Dashboard screen
          },
        );
      }
    } catch (e) {
      // Handle any unexpected errors
      Get.defaultDialog(
        title: 'Error',
        content: Text('An error occurred: $e'),
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close the dialog
        },
      );
    }
  }


  void _pickFile() async {
    print('File picker started...');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        PlatformFile file = result.files.first;

        print(file.name);
        print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);
      }
       else {
        print('No file selected');
      }
    } catch (e) {
      print('Error occurred while picking file: $e');
    }
  }

  //NAV BAR METHODS
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
    return HelperClass(
        desktop: Scaffold(
          backgroundColor: Colors.white,
          body:SingleChildScrollView(
            child: Column(
              children: [
              Card(
              elevation: 1,
              child: Container(
                height: size.height * 0.085,
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
            ),
                SizedBox(height: size.height * 0.015,),
                Row(
                  children: [
                    SizedBox(width: size.width * 0.15,),
                    IconButton(onPressed: (){
                      Get.back();
                    }, icon: Icon(Icons.arrow_back,size: 20,color: Colors.black,)),
                    SizedBox(width: size.width * 0.28,),
                    Text('Apply Leave',style: TextStyle(fontFamily: 'Inter',fontSize: 18,fontWeight: FontWeight.bold,color: black),),
                  ],
                ),
                SizedBox(height: size.height * 0.013,),
                Container(
                  width: size.width * 0.60,
                  height: size.height * 0.81,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300,width: 1),
                      color: pink
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.035,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.06,),
                            Text('Badge #:',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.038,),
                            myContainer(context, '0001'),
                            SizedBox(width: size.width * 0.088,),
                            Text('Name:',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.049,),
                            myContainer(context, 'Adinin'),
                          ],
                        ),
                        SizedBox(height: size.height * 0.023,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.06,),
                            Text('Dept/Dev:',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.033,),
                            myContainer(context, 'Xyz'),
                            SizedBox(width: size.width * 0.085,),
                            Text('Job Title:',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.040,),
                            myContainer(context, 'Worker'),
                          ],
                        ),
                        SizedBox(height: size.height * 0.025,),
                        Row(
                          // Align error message properly
                          children: [
                            SizedBox(width: size.width * 0.06,),
                            Text(
                              'Leave Type:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: size.width * 0.023),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Error message for Leave Type
                                if (leaveTypeError != null)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4), // Adjust padding above dropdown
                                    child: Text(
                                      leaveTypeError!,
                                      style: TextStyle(color: Colors.red, fontSize: 12), // Error text styling
                                    ),
                                  ),
                    
                                // Leave Type Dropdown
                                Container(
                                  width: size.width * 0.16,
                                  height: size.height * 0.038,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400, // Keep the border color gray always
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.white,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedLeaveType,
                                        hint: Padding(
                                          padding: EdgeInsets.only(left: size.width * 0.005),
                                          child: Text(
                                            'Select Type',
                                            style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: grey),
                                          ),
                                        ),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedLeaveType = newValue;
                                          });
                                        },
                                        items: _leaveTypes.map((String leaveType) {
                                          return DropdownMenuItem<String>(
                                            value: leaveType,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: size.width * 0.01),
                                              child: Text(
                                                leaveType,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          size: 25,
                                          color: Colors.black,
                                        ),
                                        isExpanded: true, // Ensures the dropdown takes full width
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    
                            SizedBox(width: size.width * 0.047),
                            Text(
                              'Leave balance:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: size.width * 0.018),
                            myContainer(context, '04'),
                          ],
                        ),
                        SizedBox(height: size.height * 0.025,),
                        Row(
                          children: [
                            //Half day
                            SizedBox(width: size.width * 0.06,),
                            Text('Half day:',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.037,),
                            Container(
                              width: size.width * 0.016,
                              height: size.height * 0.030,
                              color: Colors.white,
                              child: Material(
                                color: Colors.transparent,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isHalfDay = !isHalfDay; // Toggle half-day state
                                      if (_fromDate != null && _toDate != null) {
                                        _calculateDays(); // Recalculate days whenever half-day is toggled
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(0),
                                      border: Border.all(color: Colors.grey, width: 1),
                                      color: isHalfDay ? Colors.blue : Colors.transparent, // Optional: change color when selected
                                    ),
                                    child: Center(
                                      child: isHalfDay
                                          ? Icon(Icons.check, color: Colors.white, size: 20) // Show tick icon when selected
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.02,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.14,),
                            Text('From',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.14,),
                            Text('To',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.160,),
                            Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start, // Align error messages properly
                          children: [
                            SizedBox(width: size.width * 0.06),
                            Text(
                              'Select Date:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: size.width * 0.022),
                            // From Date Field
                            DateField(
                              controller: from,
                              errorMessage: fromDateError,
                              onTap: (context) => _selectDate(context, from, true),
                            ),
                            SizedBox(width: size.width * 0.040),
                            DateField(
                              controller: to,
                              errorMessage: toDateError,
                              onTap: (context) => _selectDate(context, to, false),
                            ),
                            SizedBox(width: size.width * 0.046),
                            // Days TextField
                    Container(
                      width: size.width * 0.08,
                      height: size.height * 0.036,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400, width: 1), // Set container border color
                      ),
                      child: TextField(
                        controller: days,
                        readOnly: true,
                        decoration: InputDecoration(
                          border: InputBorder.none, // Remove the TextField's internal border
                          contentPadding: EdgeInsets.all(14.0), // Optional: adjust padding as needed
                        ),
                      ),
                    ),
                    ],
                        ),
                        SizedBox(height: size.height * 0.03,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Aligns error to the left
                          children: [
                            // Conditionally show the error message above the checkboxes
                            if (applyToError != null)
                              Padding(
                                padding: EdgeInsets.only(left: size.width * 0.22, bottom: 4), // Align error message
                                child: Text(
                                  applyToError!,
                                  style: TextStyle(color: Colors.red, fontSize: 12), // Styling for error message
                                ),
                              ),
                    
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.06),
                                Text(
                                  'Apply To:',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.035),
                                Text(
                                  'Manager:',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.015),
                                Transform.scale(
                                  scale: 1.4, // Adjust this value to change the checkbox size
                                  child: Container(
                                    width: size.width * 0.014,
                                    height: size.height * 0.023,
                                    color: Colors.white,
                                    child: Checkbox(
                                      value: isManager,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          isManager = newValue ?? false;
                                        });// Validate all fields when user selects/deselects
                                      },
                                      side: BorderSide(
                                        color: Colors.grey.shade500, // Light grey border color
                                        width: 1,
                                      ),
                                      activeColor: Colors.blue, // Optional: change checkbox color when selected
                                      checkColor: Colors.white, // Optional: checkmark color
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.085),
                                Text(
                                  'Superior:',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.015),
                                Transform.scale(
                                  scale: 1.4, // Adjust this value to change the checkbox size
                                  child: Container(
                                    width: size.width * 0.014,
                                    height: size.height * 0.023,
                                    color: Colors.white,
                                    child: Checkbox(
                                      value: isSuperior,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          isSuperior = newValue ?? false;
                                        });
                                        // Validate all fields when user selects/deselects
                                      },
                                      side: BorderSide(
                                        color: Colors.grey.shade500,
                                        width: 1,
                                      ),
                                      activeColor: Colors.blue,
                                      checkColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.028,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.14),
                            Text(
                              'If Sick Leave:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.010,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.14),
                            Container(
                                width: size.width * 0.14,
                                height: size.height * 0.040,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade400,width: 1)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(width: size.width * 0.004),
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text('Upload Medical Certificate',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: Colors.grey),)),
                                    SizedBox(width: size.width * 0.012),
                                    Spacer(), // Space between text and icon
                                    Transform.translate( // Adjust the icon position with Transform.translate
                                      offset: Offset(1, -3), // Adjust the vertical offset as needed
                                      child: IconButton(
                                        onPressed: (){
                                          _pickFile();
                                        },
                                        icon: Icon(Icons.file_upload_outlined,size: 21,color: black,),
                    
                                      ),
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                    
                        SizedBox(height: size.height * 0.030,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align error message properly
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: size.width * 0.06, bottom: size.height * 0.090),
                              child: Text(
                                'Reason:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.042), // Adjust space between label and text field as needed
                    
                            // Reason TextField
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Error message for Reason
                                if (reasonError != null)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4), // Adjust padding below error message
                                    child: Text(
                                      reasonError!,
                                      style: TextStyle(color: Colors.red, fontSize: 12), // Error text styling
                                    ),
                                  ),
                    
                                Container(
                                  width: size.width * 0.3, // Specify the width of the TextField
                                  height: size.height * 0.10,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color:Colors.grey.shade400,width: 1),
                                  ),
                                  child: TextField(
                                    controller: reason,
                                    style: TextStyle(fontSize: 14), // Adjust text size within the TextField
                                    maxLines: null, // Allows the TextField to expand vertically
                                    expands: true, // Allows the TextField content to fill the available space
                                    textAlignVertical: TextAlignVertical.top, // Centers text vertically
                                    decoration: InputDecoration(
                                      hintText: 'Text Here',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.only(top: size.height * 0.015, left: size.width * 0.010), // Padding inside the TextField
                                     border: InputBorder.none
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    
                        SizedBox(height: size.height * 0.010,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.20,),
                            RichText(
                              text: TextSpan(
                                text: 'I have read and accept the ', // First part of the text
                                style: TextStyle(
                                  color: Colors.black, // Default text color
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                ),
                                children: [
                                  TextSpan(
                                    text: 'leave policies', // Clickable link
                                    style: TextStyle(
                                      color: Colors.blue, // Link color
                                      decoration: TextDecoration.underline, // Underline the link
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        const url = 'https://commonfiles.s3.ap-southeast-1.amazonaws.com/Policy/INSTRUCTION+FOR+APPLICATION+FOR+LEAVE+.pdf';
                                        if (await canLaunch(url)) {
                                          await launch(url, forceSafariVC: false); // Open in browser
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Could not launch the URL'),
                                            ),
                                          );
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.028,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.22,),
                            OutlinedButton(
                              onPressed: () {
                                Get.off(DashBoardScreeen());
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(size.width * 0.070, size.height * 0.050), // Similar to minWidth and height in MaterialButton
                                side: BorderSide(color: grey), // Define the border color for the outlined button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // Adjust the border radius as needed
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: black,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.03,),
                            Material(
                              borderRadius: BorderRadius.circular(45),
                              child: MaterialButton(
                                onPressed: () async {
                                  // Validate all fields before applying
                                  if (_validateFields()) {
                                    // Show confirmation popup with Yes and No buttons
                                    Get.defaultDialog(
                                      title: 'Confirm',
                                      content: Text('Are you sure you want to apply?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Get.back(); // Close the dialog
                                          },
                                          child: Text('No', style: TextStyle(color: Colors.red)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Get.back(); // Close the dialog first
                    
                                            // Proceed with creating the leave request
                                            await applyForLeave(); // This will show success/error dialogs based on the result
                                          },
                                          child: Text('Yes', style: TextStyle(color: Colors.green)),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Show error alert dialog if fields are missing
                                    Get.defaultDialog(
                                      title: 'Error',
                                      content: Text('Please fill all required fields.'),
                                      confirmTextColor: Colors.white,
                                      onConfirm: () {
                                        Get.back(); // Close the dialog
                                      },
                                    );
                                  }
                                },
                                minWidth: size.width * 0.070,
                                height: size.height * 0.050,
                                color: yellow,
                                child: Text(
                                  'Apply',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.020,),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.040,)
              ],
            ),
          )
        ),
        //TAB VIEW
        tablet: Scaffold(
          backgroundColor: Colors.white,
          body:
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                Card(
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
              ),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.15,),
                      IconButton(onPressed: (){
                        Get.back();
                      }, icon: Icon(Icons.arrow_back,size: 20,color: Colors.black,)),
                      SizedBox(width: size.width * 0.28,),
                      Text('Apply Leave',style: TextStyle(fontFamily: 'Inter',fontSize: 18,fontWeight: FontWeight.bold,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.015,),
                 Container(
                   width: size.width * 0.85,
                   height: size.height * 0.82,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.grey.shade300,width: 1),
                     color: pink
                   ),
                   child: SingleChildScrollView(
                     child: Column(
                       children: [
                         SizedBox(height: size.height * 0.035,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.10,),
                             Text('Badge #:',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                             SizedBox(width: size.width * 0.048,),
                             tabContainer(context, '0001'),
                             SizedBox(width: size.width * 0.067,),
                             Text('Name:',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                             SizedBox(width: size.width * 0.065,),
                             tabContainer(context, 'Adinin'),
                           ],
                         ),
                         SizedBox(height: size.height * 0.025,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.10,),
                             Text('Dept/Dev:',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                             SizedBox(width: size.width * 0.041,),
                             tabContainer(context, 'Xyz'),
                             SizedBox(width: size.width * 0.064,),
                             Text('Job Title:',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                             SizedBox(width: size.width * 0.052,),
                             tabContainer(context, 'Worker'),
                           ],
                         ),
                         SizedBox(height: size.height * 0.03,),
                         Row(// Align error message properly
                           children: [
                             SizedBox(width: size.width * 0.10),
                             Text(
                               'Leave Type:',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             SizedBox(width: size.width * 0.028),
              
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 // Error message for Leave Type
                                 if (leaveTypeError != null)
                                   Padding(
                                     padding: EdgeInsets.only(bottom: 4), // Adjust padding below error message
                                     child: Text(
                                       leaveTypeError!,
                                       style: TextStyle(color: Colors.red, fontSize: 12), // Error text styling
                                     ),
                                   ),
              
                                 // Leave Type Dropdown
                                 Container(
                                   width: size.width * 0.16,
                                   height: size.width * 0.025,
                                   decoration: BoxDecoration(
                                     border: Border.all(
                                       color: Colors.grey.shade400, // Keep the border color gray always
                                       width: 1,
                                     ),
                                     borderRadius: BorderRadius.circular(2),
                                     color: Colors.white,
                                   ),
                                   child: Material(
                                     color: Colors.transparent,
                                     child: DropdownButtonHideUnderline(
                                       child: DropdownButton<String>(
                                         value: _selectedLeaveType,
                                         hint: Padding(
                                           padding: EdgeInsets.all(4.0),
                                           child: Text(
                                             'Select Type',
                                             style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: grey),
                                           ),
                                         ),
                                         onChanged: (String? newValue) {
                                           setState(() {
                                             _selectedLeaveType = newValue;
                                           });
                                         },
                                         items: _leaveTypes.map((String leaveType) {
                                           return DropdownMenuItem<String>(
                                             value: leaveType,
                                             child: Padding(
                                               padding: EdgeInsets.only(left: size.width * 0.01),
                                               child: Text(
                                                 leaveType,
                                                 style: TextStyle(
                                                   fontFamily: 'Inter',
                                                   fontSize: 12,
                                                   color: Colors.black,
                                                 ),
                                               ),
                                             ),
                                           );
                                         }).toList(),
                                         icon: Icon(
                                           Icons.keyboard_arrow_down_outlined,
                                           size: 25,
                                           color: Colors.black,
                                         ),
                                         isExpanded: true, // Ensures the dropdown takes full width
                                       ),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
              
                             SizedBox(width: size.width * 0.065),
                             Text(
                               'Leave balance:',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             SizedBox(width: size.width * 0.018),
                             tabContainer(context, '04'),
                           ],
                         ),
                         SizedBox(height: size.height * 0.04,),
                         Row(
                           children: [
                             //Half day
                             SizedBox(width: size.width * 0.10,),
                             Text('Half day:',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                             SizedBox(width: size.width * 0.048,),
                             Container(
                               width: size.width * 0.026,
                               height: size.height * 0.035,
                               color: Colors.white,
                               child: Material(
                                 color: Colors.transparent,
                                 child: GestureDetector(
                                   onTap: () {
                                     setState(() {
                                       isHalfDay = !isHalfDay; // Toggle half-day state
                                       if (_fromDate != null && _toDate != null) {
                                         _calculateDays(); // Recalculate days whenever half-day is toggled
                                       }
                                     });
                                   },
                                   child: Container(
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(0),
                                       border: Border.all(color: Colors.grey.shade400, width: 1),
                                       color: isHalfDay ? Colors.blue : Colors.transparent, // Optional: change color when selected
                                     ),
                                     child: Center(
                                       child: isHalfDay
                                           ? Icon(Icons.check, color: Colors.white, size: 20) // Show tick icon when selected
                                           : null,
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: size.height * 0.02,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.21,),
                             Text('From',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                             SizedBox(width: size.width * 0.155,),
                             Text('To',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                             SizedBox(width: size.width * 0.17,),
                             Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black,fontWeight: FontWeight.bold),),
                           ],
                         ),
                         SizedBox(height: size.height * 0.009,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.10),
                             Text(
                               'Select Date:',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: black,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             SizedBox(width: size.width * 0.025),
              
                             // From Date Field
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 // Error message for From Date
                                 if (fromDateError != null)
                                   Padding(
                                     padding: EdgeInsets.only(bottom: 4), // Adjust padding below error message
                                     child: Text(
                                       fromDateError!,
                                       style: TextStyle(color: Colors.red, fontSize: 12), // Error text styling
                                     ),
                                   ),
              
                                 Container(
                                   width: size.width * 0.16,
                                   height: size.width * 0.025,
                                   decoration: BoxDecoration(
                                       color: Colors.white,
                                       border: Border.all(color: Colors.grey.shade400)
                                   ),
                                   child: TextField(
                                     controller: from,
                                     style: TextStyle(fontSize: 12),
                                     decoration: InputDecoration(
                                       border: InputBorder.none,
                                       contentPadding: EdgeInsets.all(12),
                                       suffixIcon: IconButton(
                                         padding: EdgeInsets.only(bottom: 0.05),
                                         onPressed: () => _selectDate(context, from, true),
                                         icon: Icon(
                                           Icons.calendar_today_outlined,
                                           size: 16,
                                           color: black,
                                         ),
                                       ),
                                       hintText: 'dd/mm/yyyy',
                                       hintStyle: TextStyle(fontSize: 14,),
              
                                     ),
                                   ),
                                 ),
                               ],
                             ),
              
                             SizedBox(width: size.width * 0.03),
              
                             // To Date Field
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 // Error message for To Date
                                 if (toDateError != null)
                                   Padding(
                                     padding: EdgeInsets.only(bottom: 4), // Adjust padding below error message
                                     child: Text(
                                       toDateError!,
                                       style: TextStyle(color: Colors.red, fontSize: 12), // Error text styling
                                     ),
                                   ),
              
                                 Container(
                                   width: size.width * 0.16,
                                   height: size.width * 0.025,
                                   decoration: BoxDecoration(
                                       color: Colors.white,
                                       border: Border.all(color: Colors.grey.shade400)
                                   ),
                                   child: TextField(
                                     controller: to,
                                     style: TextStyle(fontSize: 12),
                                     decoration: InputDecoration(
                                       border: InputBorder.none,
                                       contentPadding: EdgeInsets.all(12),
                                       hintText: 'dd/mm/yyyy',
                                       hintStyle: TextStyle(fontSize: 14,),
                                       suffixIcon: IconButton(
                                         padding: EdgeInsets.only(bottom: 0.05),
                                         onPressed: () => _selectDate(context, to, false),
                                         icon: Icon(
                                           Icons.calendar_today_outlined,
                                           size: 16,
                                           color: black,
                                         ),
                                       ),
                                     ),
                                   ),
                                 ),
                               ],
                             ),
              
                             SizedBox(width: size.width * 0.025),
              
                             // Days Field
                             Container(
                               width: size.width * 0.12,
                               height: size.width * 0.025,
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 border: Border.all(color: Colors.grey.shade400)
                               ),
                               child: TextField(
                                 controller: days,
                                 decoration: InputDecoration(
                                   contentPadding: EdgeInsets.all(14),
                                  border: InputBorder.none
                                 ),
                                 readOnly: true,
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: size.height * 0.03,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.10),
                             Text(
                               'Apply To:',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             SizedBox(width: size.width * 0.044),
                             Text(
                               'Manager:',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             SizedBox(width: size.width * 0.015),
                             Transform.scale(
                               scale: 1.3,
                               // Adjust this value to change the checkbox size
                               child: Checkbox(
                                 value: isManager,
                                 onChanged: (bool? newValue) {
                                   setState(() {
                                     isManager = newValue ?? false;
                                   });// Validate all fields when user selects/deselects
                                 },
                                 side: BorderSide(
                                   color: Colors.grey.shade500, // Light grey border color
                                   width: 1,
                                 ),
                                 activeColor: Colors.blue, // Optional: change checkbox color when selected
                                 checkColor: Colors.white, // Optional: checkmark color
                               ),
                             ),
                             SizedBox(width: size.width * 0.085),
                             Text(
                               'Superior:',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                             SizedBox(width: size.width * 0.015),
                             Transform.scale(
                               scale: 1.3, // Adjust this value to change the checkbox size
                               child: Checkbox(
                                 value: isSuperior,
                                 onChanged: (bool? newValue) {
                                   setState(() {
                                     isSuperior = newValue ?? false;
                                   });
                                   // Validate all fields when user selects/deselects
                                 },
                                 side: BorderSide(
                                   color: Colors.grey.shade500,
                                   width: 1,
                                 ),
                                 activeColor: Colors.blue,
                                 checkColor: Colors.white,
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: size.height * 0.025,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.205),
                             Text(
                               'If Sick:',
                               style: TextStyle(
                                 fontFamily: 'Inter',
                                 fontSize: 14,
                                 color: Colors.black,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: size.height * 0.010,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.205),
                             Container(
                                 width: size.width * 0.22,
                                 height: size.height * 0.038,
                                 decoration: BoxDecoration(
                                     color: Colors.white,
                                     border: Border.all(color: Colors.grey.shade400,width: 1)
                                 ),
              
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.start,
                                   children: [
                                     SizedBox(width: size.width * 0.004),
                                     Align(
                                         alignment: Alignment.center,
                                         child: Text('Upload Medical Certificate',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: Colors.grey),)),
                                     SizedBox(width: size.width * 0.012),
                                     Spacer(), // Space between text and icon
                                     Transform.translate( // Adjust the icon position with Transform.translate
                                       offset: Offset(1, -3), // Adjust the vertical offset as needed
                                       child: IconButton(
                                         onPressed: (){
                                           _pickFile();
                                         },
                                         icon: Icon(Icons.file_upload_outlined,size: 20,color: black,),
              
                                       ),
                                     ),
                                   ],
                                 )
                             )
                           ],
                         ),
                         SizedBox(height: size.height * 0.020,),
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start, // Ensures vertical alignment
                           children: <Widget>[
                             // Adjust space before the label as needed
                             Padding(
                               padding: EdgeInsets.only(left: size.width * 0.106, bottom: size.height * 0.075),
                               child: Text(
                                 'Reason:',
                                 style: TextStyle(
                                   fontFamily: 'Inter',
                                   fontSize: 16,
                                   color: Colors.black,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ),
                             SizedBox(width: size.width * 0.042), // Adjust space between label and textfield as needed
              
                             // Reason TextField with error message
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 // Error message for Reason
                                 if (reasonError != null)
                                   Padding(
                                     padding: EdgeInsets.only(bottom: 2), // Adjust padding below the error message
                                     child: Text(
                                       reasonError!,
                                       style: TextStyle(color: Colors.red, fontSize: 12), // Error text styling
                                     ),
                                   ),
              
                                 Container(
                                   width: size.width * 0.3, // Specify the width of the TextField
                                   height: size.height * 0.085,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey.shade400, width: 1)
                                    ),
                                   child: TextField(
                                     controller: reason,
                                     style: TextStyle(fontSize: 16), // Adjust text size within the TextField
                                     maxLines: null, // Allows the TextField to expand vertically
                                     expands: true, // Allows the TextField content to fill the available space
                                     textAlignVertical: TextAlignVertical.top, // Centers text vertically
                                     decoration: InputDecoration(
                                       border: InputBorder.none,
                                       hintText: 'Text Here',
                                       hintStyle: TextStyle(color: Colors.grey),
                                       contentPadding: EdgeInsets.only(top: 15, left: 10), // Padding inside the TextField
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ],
                         ),
                         SizedBox(height: size.height * 0.002,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.22,),
                             RichText(
                               text: TextSpan(
                                 text: 'I have read and accept ', // First part of the text
                                 style: TextStyle(
                                   color: Colors.black, // Default text color
                                   fontSize: 16,
                                   fontFamily: 'Inter',
                                 ),
                                 children: [
                                   TextSpan(
                                     text: 'the leave policies', // Clickable link
                                     style: TextStyle(
                                       color: Colors.blue, // Link color
                                       decoration: TextDecoration.underline, // Underline the link
                                     ),
                                     recognizer: TapGestureRecognizer()
                                       ..onTap = () async {
                                         const url = 'https://commonfiles.s3.ap-southeast-1.amazonaws.com/Policy/INSTRUCTION+FOR+APPLICATION+FOR+LEAVE+.pdf';
                                         if (await canLaunch(url)) {
                                           await launch(url, forceSafariVC: false); // Open in browser
                                         } else {
                                           ScaffoldMessenger.of(context).showSnackBar(
                                             SnackBar(
                                               content: Text('Could not launch the URL'),
                                             ),
                                           );
                                         }
                                       },
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: size.width * 0.02,),
                         Row(
                           children: [
                             SizedBox(width: size.width * 0.25,),
                             OutlinedButton(
                               onPressed: () {
                                 Get.off(DashBoardScreeen());
                               },
                               style: OutlinedButton.styleFrom(
                                 minimumSize: Size(size.width * 0.10, size.height * 0.050), // Similar to minWidth and height in MaterialButton
                                 side: BorderSide(color: grey), // Define the border color for the outlined button
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(0), // Adjust the border radius as needed
                                 ),
                               ),
                               child: Text(
                                 'Cancel',
                                 style: TextStyle(
                                   fontFamily: 'Inter',
                                   fontSize: 14,
                                   fontWeight: FontWeight.bold,
                                   color: black,
                                 ),
                               ),
                             ),
                             SizedBox(width: size.width * 0.02,),
                             Material(
                               borderRadius: BorderRadius.circular(45),
                               color: Colors.transparent,
                               child: MaterialButton(
                                 onPressed: () {
                                   // Validate all fields before applying
                                   if (_validateFields()) {
                                     // All fields are filled, show confirmation popup with Yes and No buttons
                                     Get.defaultDialog(
                                       title: 'Confirm',
                                       content: Text('Are you sure you want to apply?'),
                                       actions: [
                                         TextButton(
                                           onPressed: () {
                                             // Action on No (cancel)
                                             Get.back(); // Clo  se the dialog
                                           } ,
                                           child: Text('No', style: TextStyle(color: Colors.red)),
                                         ),
                                         TextButton(
                                           onPressed: () async {
                                             Get.back(); // Close the dialog first
              
                                             // Proceed with creating the leave request
                                             await applyForLeave(); // This will show success/error dialogs based on the result
                                           },
                                           child: Text('Yes', style: TextStyle(color: Colors.green)),
                                         )
                                       ],
                                     );
                                   } else {
                                     // Show error alert dialog if fields are missing
                                     Get.defaultDialog(
                                       title: 'Error',
                                       content: Text('Please fill all required fields.'),
                                       confirmTextColor: Colors.white,
                                       onConfirm: () {
                                         Get.back(); // Close the dialog
                                       },
                                     );
                                   }
                                 },
                                 minWidth: size.width * 0.10,
                                 height: size.height * 0.05,
                                 color: yellow,
                                 child: Text('Apply',style: TextStyle(fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold,color: black),),
                               ),
                             ),
                           ],
                         ),
                         SizedBox(height: size.height * 0.010,),
                       ],
                     ),
                   ),
                 ),
                  SizedBox(height: size.height * 0.025,),
                ],
              ),
            ),
        ),

        mobile: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Colors.white,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(1.0), // Height of the border
                child: Container(
                  color: Colors.black12, // Border color
                  height: 1.0, // Height of the border
                ),
              ),
              actions: [
                Row(
                  children: <Widget>[
                    Padding(
                      padding:  EdgeInsets.only(left: 1),
                      child: Container(
                        width: size.width * 0.160,
                        height: size.height * 0.0400,
                        child: Image.asset('assets/images/awe logo.png',),
                      ),
                    ),
                    SizedBox(width: size.width * 0.7,),
                    GestureDetector(
                      onTap: (){
                        _confirmSignOut(context);
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            child: Image.asset('assets/images/user image.png'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              ]),
          body:
          SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: size.width * 0.02,),
                    IconButton(onPressed: (){
                      Get.back();
                    }, icon: Icon(Icons.arrow_back,size: 18,color: Colors.black,)),
                    SizedBox(width: size.width * 0.25,),
                    Text('Apply Leave',style: TextStyle(fontFamily: 'Inter',fontSize: 15,fontWeight: FontWeight.bold,color: black),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                Container(
                  width: size.width * 0.93,
                  height: size.height * 0.80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300,width: 1),
                      color: pink
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.035,),
                      Row(
                        children: [
                          SizedBox(width: size.width * 0.04,),
                          Text('Badge #:',style: TextStyle(fontFamily: 'Inter',fontSize: 11,fontWeight: FontWeight.bold,color: black,),),
                          SizedBox(width: size.width * 0.020,),
                          phoneContainer(context, '0001'),
                          SizedBox(width: size.width * 0.0999,),
                          Text('Name:',style: TextStyle(fontFamily: 'Inter',fontSize: 11,fontWeight: FontWeight.bold,color: black,),),
                          SizedBox(width: size.width * 0.143,),
                          phoneContainer(context, 'Adinin'),
                        ],
                      ),
                      SizedBox(height: size.height * 0.034,),
                      Row(
                        children: [
                          SizedBox(width: size.width * 0.04,),
                          Text('Dept/Dev:',style: TextStyle(fontFamily: 'Inter',fontSize: 11,fontWeight: FontWeight.bold,color: black,),),
                          SizedBox(width: size.width * 0.010,),
                          phoneContainer(context, 'Xyz'),
                          SizedBox(width: size.width * 0.099,),
                          Text('Job Title:',style: TextStyle(fontFamily: 'Inter',fontSize: 11,fontWeight: FontWeight.bold,color: black,),),
                          SizedBox(width: size.width * 0.099,),
                          phoneContainer(context, 'Worker'),
                        ],
                      ),
                      SizedBox(height: size.height * 0.034,),
                      Row(
                        // Align error message properly
                        children: [
                          SizedBox(width: size.width * 0.04,),
                          Text(
                            'Leave Type:',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: size.width * 0.010),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Error message for Leave Type
                              if (leaveTypeError != null)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4), // Adjust padding above dropdown
                                  child: Text(
                                    leaveTypeError!,
                                    style: TextStyle(color: Colors.red, fontSize: 08), // Error text styling
                                  ),
                                ),
                              // Leave Type Dropdown
                              Container(
                                width: size.width * 0.24,
                                height: size.height * 0.032,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400, // Keep the border color gray always
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  color: Colors.white,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedLeaveType,
                                      hint: Padding(
                                        padding: EdgeInsets.only(left: size.width * 0.005),
                                        child: Text(
                                          'Select Type',
                                          style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: grey),
                                        ),
                                      ),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedLeaveType = newValue;
                                        });
                                      },
                                      items: _leaveTypes.map((String leaveType) {
                                        return DropdownMenuItem<String>(
                                          value: leaveType,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: size.width * 0.01),
                                            child: Text(
                                              leaveType,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 7,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        size: 23,
                                        color: Colors.black,
                                      ),
                                      isExpanded: true, // Ensures the dropdown takes full width
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: size.width * 0.015),
                          Text(
                            'Leave balance:',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: size.width * 0.029),
                          phoneContainer(context, '04'),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02,),
                      Row(
                        children: [
                          //Half day
                          SizedBox(width: size.width * 0.04,),
                          Text('Half day:',style: TextStyle(fontFamily: 'Inter',fontSize: 11,fontWeight: FontWeight.bold,color: black,),),
                          SizedBox(width: size.width * 0.049,),
                          Container(
                            width: size.width * 0.035,
                            height: size.height * 0.026,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade400, // Keep the border color gray always
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isHalfDay = !isHalfDay; // Toggle half-day state
                                  if (_fromDate != null && _toDate != null) {
                                    _calculateDays(); // Recalculate days whenever half-day is toggled
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  color: isHalfDay ? Colors.blue : Colors.transparent, // Optional: change color when selected
                                ),
                                child: Center(
                                  child: isHalfDay
                                      ? Icon(Icons.check, color: Colors.white, size: 20) // Show tick icon when selected
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.034,),
                      Row(
                        children: [
                          SizedBox(width: size.width * 0.20,),
                          Text('From',style: TextStyle(fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold,color: black,),),
                          SizedBox(width: size.width * 0.191,),
                          Text('To',style: TextStyle(fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold,color: black,),),
                          SizedBox(width: size.width * 0.21,),
                          Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold,color: black,),),
                        ],
                      ),
                      SizedBox(height: size.height * 0.008,),
                      Row(// Align error messages properly
                        children: [
                          SizedBox(width: size.width * 0.03,),
                          Text(
                            'Select Date:',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: size.width * 0.020),
                          // From Date TextField
                          PhoneField(
                            controller: from,
                            errorMessage: fromDateError,
                            onTap: (context) => _selectDate(context, from, true),
                          ),
                          SizedBox(width: size.width * 0.020),
                          PhoneField(
                            controller: to,
                            errorMessage: toDateError,
                            onTap: (context) => _selectDate(context, to, false),
                          ),
                          // To Date TextField
                          SizedBox(width: size.width * 0.040),
                          // Days TextField
                          Container(
                            width: size.width * 0.145,
                            height: size.height * 0.031,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade400,width: 1)
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: TextField(
                                controller: days,
                                readOnly: true,
                                style: TextStyle(
                                  fontSize: 11, // Set a smaller font size for the picked date
                                  color: Colors.black, // You can also control the color of the text
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(16),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.038,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Aligns error to the left
                        children: [
                          // Conditionally show the error message above the checkboxes
                          if (applyToError != null)
                            Padding(
                              padding: EdgeInsets.only(left: size.width * 0.22, bottom: 4), // Align error message
                              child: Text(
                                applyToError!,
                                style: TextStyle(color: Colors.red, fontSize: 08), // Styling for error message
                              ),
                            ),
                          Row(
                            children: [
                              SizedBox(width: size.width * 0.06),
                              Text(
                                'Apply To:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: size.width * 0.035),
                              Text(
                                'Manager:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: size.width * 0.015),
                              Transform.scale(
                                scale: 1.0, // Adjust this value to change the checkbox size
                                child: Checkbox(
                                  value: isManager,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      isManager = newValue ?? false;
                                    });// Validate all fields when user selects/deselects
                                  },
                                  side: BorderSide(
                                    color: Colors.grey.shade500, // Light grey border color
                                    width: 1,
                                  ),
                                  activeColor: Colors.blue, // Optional: change checkbox color when selected
                                  checkColor: Colors.white, // Optional: checkmark color
                                ),
                              ),
                              SizedBox(width: size.width * 0.085),
                              Text(
                                'Superior:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: size.width * 0.015),
                              Transform.scale(
                                scale: 1.0, // Adjust this value to change the checkbox size
                                child: Checkbox(
                                  value: isSuperior,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      isSuperior = newValue ?? false;
                                    });
                                    // Validate all fields when user selects/deselects
                                  },
                                  side: BorderSide(
                                    color: Colors.grey.shade500,
                                    width: 1,
                                  ),
                                  activeColor: Colors.blue,
                                  checkColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.025,),
                          Row(
                            children: [
                              SizedBox(width: size.width * 0.19),
                              Text(
                                'If Sick:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.009,),
                          Row(
                            children: [
                              SizedBox(width: size.width * 0.19),
                              Container(
                                  width: size.width * 0.55,
                                  height: size.height * 0.035,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey.shade400,width: 1)
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: size.width * 0.01),
                                      Align(
                                          alignment: Alignment.center,
                                          child: Text('Upload Medical Certificate',style: TextStyle(fontFamily: 'Inter',fontSize: 10,color: Colors.grey),)),
                                      Spacer(), // Space between text and icon
                                      Transform.translate( // Adjust the icon position with Transform.translate
                                        offset: Offset(1, -3), // Adjust the vertical offset as needed
                                        child: IconButton(
                                          onPressed: (){
                                            _pickFile();
                                          },
                                          icon: Icon(Icons.file_upload_outlined,size: 16,color: black,),
                                        ),
                                      ),
                                    ],
                                  )
                              )
                            ],
                          ),
                          SizedBox(height: size.height * 0.025,),
                          Row(
                            // Align error message properly
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: size.width * 0.07, bottom: size.height * 0.070),
                                child: Text(
                                  'Reason:',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.049), // Adjust space between label and text field as needed
                              // Reason TextField
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Error message for Reason
                                  if (reasonError != null)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 4), // Adjust padding below error message
                                      child: Text(
                                        reasonError!,
                                        style: TextStyle(color: Colors.red, fontSize: 08), // Error text styling
                                      ),
                                    ),

                                  Container(
                                    width: size.width * 0.49, // Specify the width of the TextField
                                    height: size.height * 0.06,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.grey.shade400,width: 1)
                                    ),
                                    child: TextField(
                                      controller: reason,
                                      style: TextStyle(fontSize: 14), // Adjust text size within the TextField
                                      maxLines: null, // Allows the TextField to expand vertically
                                      expands: true, // Allows the TextField content to fill the available space
                                      textAlignVertical: TextAlignVertical.top, // Centers text vertically
                                      decoration: InputDecoration(
                                        hintText: 'Text Here',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(color: Colors.grey),
                                        contentPadding: EdgeInsets.only(top: size.height * 0.015, left: size.width * 0.010), // Padding inside the TextField

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.006,),
                          Row(
                            children: [
                              SizedBox(width: size.width * 0.20,),
                              RichText(
                                text: TextSpan(
                                  text: 'I have read and accept the ', // First part of the text
                                  style: TextStyle(
                                    color: Colors.black, // Default text color
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'leave policies', // Clickable link
                                      style: TextStyle(
                                        color: Colors.blue, // Link color
                                        decoration: TextDecoration.underline, // Underline the link
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          const url = 'https://commonfiles.s3.ap-southeast-1.amazonaws.com/Policy/INSTRUCTION+FOR+APPLICATION+FOR+LEAVE+.pdf';
                                          if (await canLaunch(url)) {
                                            await launch(url, forceSafariVC: false); // Open in browser
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Could not launch the URL'),
                                              ),
                                            );
                                          }
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.035,),
                          Row(
                            children: [
                              SizedBox(width: size.width * 0.25,),
                              OutlinedButton(
                                onPressed: () {
                                  Get.off(DashBoardScreeen());
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(size.width * 0.020, size.height * 0.035), // Similar to minWidth and height in MaterialButton
                                  side: BorderSide(color: grey), // Define the border color for the outlined button
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4), // Adjust the border radius as needed
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: black,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.03,),
                              Material(
                                borderRadius: BorderRadius.circular(45),
                                child: MaterialButton(
                                  onPressed: () {
                                    // Validate all fields before applying
                                    if (_validateFields()) {
                                      // All fields are filled, show confirmation popup with Yes and No buttons
                                      Get.defaultDialog(
                                        title: 'Confirm',
                                        content: Text('Are you sure you want to apply?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              // Action on No (cancel)
                                              Get.back(); // Clo  se the dialog
                                            } ,
                                            child: Text('No', style: TextStyle(color: Colors.red)),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Get.back(); // Close the dialog first

                                              // Proceed with creating the leave request
                                              await applyForLeave(); // This will show success/error dialogs based on the result
                                            },
                                            child: Text('Yes', style: TextStyle(color: Colors.green)),
                                          ),
                                        ],
                                      );
                                    } else {
                                      // Show error alert dialog if fields are missing
                                      Get.defaultDialog(
                                        title: 'Error',
                                        content: Text('Please fill all required fields.'),
                                        confirmTextColor: Colors.white,
                                        onConfirm: () {
                                          Get.back(); // Close the dialog
                                        },
                                      );
                                    }
                                  },
                                  minWidth: size.width * 0.19,
                                  height: size.height * 0.035,
                                  color: yellow,
                                  child: Text('Apply',style: TextStyle(fontFamily: 'Inter',fontSize: 11,fontWeight: FontWeight.bold,color: black),),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        paddingWidth: size.width * 0.1,
        bgColor: Colors.white);
  }
}

Widget myContainer(BuildContext context,String text){
  final Size size = MediaQuery.of(context).size;
  return    Container(
    width: size.width * 0.123,
    height: size.width * 0.018,
    decoration: BoxDecoration(
      color: Colors.white,
        border: Border.all(color: Colors.grey.shade400,width: 1)
    ),
    child: Padding(
      padding:  EdgeInsets.all( 4.0),
      child: Text(text,style: TextStyle(color: Colors.grey.shade500,fontFamily: 'Inter',fontSize: 14),),
    ),
  );
}
Widget tabContainer(BuildContext context,String text){
  final Size size = MediaQuery.of(context).size;
  return    Container(
    width: size.width * 0.16,
    height: size.width * 0.025,
    decoration: BoxDecoration(
      color: Colors.white,
        border: Border.all(color: Colors.grey.shade400,width: 1)
    ),
    child: Padding(
      padding:  EdgeInsets.all( 4.0),
      child: Text(text,style: TextStyle(color: Colors.grey.shade500,fontFamily: 'Inter',fontSize: 14),),
    ),
  );
}

Widget phoneContainer(BuildContext context,String text){
  final Size size = MediaQuery.of(context).size;
  return    Container(
    width: size.width * 0.18,
    height: size.height * 0.030,
    decoration: BoxDecoration(
      color: Colors.white,
        border: Border.all(color: Colors.grey.shade400,width: 1)
    ),
    child: Padding(
      padding:  EdgeInsets.all( 2.0),
      child: Text(text,style: TextStyle(color: Colors.grey.shade500,fontFamily: 'Inter',fontSize: 11),),
    ),
  );
}


