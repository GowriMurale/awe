import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:awe_project/Screens/dashboard_screen.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../globals/datefield.dart';
import '../globals/leave_apply.dart';
import '../models/LeaveStatus.dart';
class ApplyLeave extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return DesktopLeave();
        } else if (constraints.maxWidth >= 800 && constraints.maxWidth < 1200) {
          return TabletLeave();
        } else {
          return  MobileLeave();
        }
      },
    );
  }
}

class DesktopLeave extends StatefulWidget {
  const DesktopLeave({super.key}); // Constructor with optional key

  @override
  State<DesktopLeave> createState() => _DesktopLeaveState(); // Create state without 'return'
}

class _DesktopLeaveState extends State<DesktopLeave> {
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
        String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
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
      DateTime? fromDate = DateFormat('MM/dd/yyyy').parse(from.text);
      DateTime? toDate = DateFormat('MM/dd/yyyy').parse(to.text);

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
        empID: empID,
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





// Example of how you would call this when the user selects a date



   String empID = 'awe101'; // Or fetch it dynamically during login
  TextEditingController userIdController=TextEditingController();
  TextEditingController passwordController=TextEditingController();
  Future<void> _signIn(BuildContext context) async {
    try {
      // Fetch auth session to check if user is already signed in
      var session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        // Assuming empID is fetched from attributes or stored in session
        // empID = 'awe101'; // Store the empID once logged in
        Get.off(() => DashBoardScreeen());
        return;
      }

      // Proceed with normal sign-in
      SignInResult res = await Amplify.Auth.signIn(
        username: userIdController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.isSignedIn) {
        // empID = 'awe101'; // Fetch or assign the employee ID
        Get.off(() => DashBoardScreeen());
      }
    } catch (e) {
      print("AuthException: ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return
      SingleChildScrollView(
        child: Column(
          children: [
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
            SizedBox(height: size.height * 0.015,),
            Row(
              children: [
                SizedBox(width: size.width * 0.22,),
                Text('Badge #:',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
                SizedBox(width: size.width * 0.038,),
                myContainer(context, '0001'),
                SizedBox(width: size.width * 0.088,),
                Text('Name:',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
                SizedBox(width: size.width * 0.051,),
                myContainer(context, 'Adinin'),
              ],
            ),
            SizedBox(height: size.height * 0.025,),
            Row(
              children: [
                SizedBox(width: size.width * 0.22,),
                Text('Dept/Dev:',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
                SizedBox(width: size.width * 0.033,),
                myContainer(context, 'Xyz'),
                SizedBox(width: size.width * 0.085,),
                Text('Job Title:',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
                SizedBox(width: size.width * 0.040,),
                myContainer(context, 'Worker'),
              ],
            ),
            SizedBox(height: size.height * 0.03,),
            Row(
              // Align error message properly
              children: [
                SizedBox(width: size.width * 0.22,),
                Text(
                  'Leave Type:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
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
                      height: size.height * 0.042,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey, // Keep the border color gray always
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        color: bgColor,
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

                SizedBox(width: size.width * 0.065),
                Text(
                  'Leave balance:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.010),
                myContainer(context, '04'),
              ],
            ),
            SizedBox(height: size.height * 0.03,),
            Row(
              children: [
                //Half day
                SizedBox(width: size.width * 0.22,),
                Text('Half day:',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
                SizedBox(width: size.width * 0.042,),
                Container(
                  width: size.width * 0.018,
                  height: size.height * 0.035,
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
                SizedBox(width: size.width * 0.31,),
                Text('From',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
                SizedBox(width: size.width * 0.145,),
                Text('To',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
                SizedBox(width: size.width * 0.15,),
                Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: size.height * 0.01,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align error messages properly
              children: [
                SizedBox(width: size.width * 0.22),
                Text(
                  'Select Date:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
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
                SizedBox(width: size.width * 0.03),
                DateField(
                  controller: to,
                  errorMessage: toDateError,
                  onTap: (context) => _selectDate(context, to, false),
                ),
                SizedBox(width: size.width * 0.025),
                // Days TextField
                Container(
                  width: size.width * 0.14,
                  height: size.height * 0.042,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: days,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1), // Keep border color grey
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      readOnly: true,
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
                    SizedBox(width: size.width * 0.22),
                    Text(
                      'Apply To:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: size.width * 0.035),
                    Text(
                      'Manager:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: size.width * 0.015),
                    Transform.scale(
                      scale: 1.5, // Adjust this value to change the checkbox size
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
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: size.width * 0.015),
                    Transform.scale(
                      scale: 1.5, // Adjust this value to change the checkbox size
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
              ],
            ),
            SizedBox(height: size.height * 0.012,),
            Row(
              children: [
                SizedBox(width: size.width * 0.32),
                Text(
                  'If Sick:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.005,),
            Row(
              children: [
                SizedBox(width: size.width * 0.32),
            Container(
            width: size.width * 0.14,
              height: size.height * 0.038,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade700,width: 1)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.004),
                  Text('Upload Medical Certificate',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: Colors.grey),),
                  SizedBox(width: size.width * 0.012),
                  Padding(
                    padding:  EdgeInsets.only(bottom: size.height * 0.8),
                    child: IconButton(onPressed: (){}, icon: Icon(Icons.file_upload_outlined,size: 18,color: black,)),
                  )
                ],
              )
            )
              ],
            ),

            SizedBox(height: size.height * 0.022,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Align error message properly
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: size.width * 0.22, bottom: size.height * 0.090),
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
                      height: size.height * 0.11, // Specify the height of the TextField
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: size.height * 0.022,),
            Row(
              children: [
                SizedBox(width: size.width * 0.38,),
                RichText(
                  text: TextSpan(
                    text: 'I have read and accept the ', // First part of the text
                    style: TextStyle(
                      color: Colors.black, // Default text color
                      fontSize: 16,
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
            SizedBox(height: size.height * 0.030,),
            Row(
              children: [
                SizedBox(width: size.width * 0.38,),
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
                    minWidth: size.width * 0.075,
                    height: size.height * 0.055,
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
                SizedBox(width: size.width * 0.03,),
                OutlinedButton(
                  onPressed: () {
                    Get.off(DashBoardScreeen());
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(size.width * 0.075, size.height * 0.055), // Similar to minWidth and height in MaterialButton
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
                )

              ],
            )

          ],
        ),
      );

  }

// Helper method to build rows with two containers
  Widget _buildRowWithContainers(Size size, String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        SizedBox(width: size.width * 0.22),
        Text(
          label1,
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: black, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: size.width * 0.038),
        myContainer(context, value1),
        SizedBox(width: size.width * 0.088),
        Text(
          label2,
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: black, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: size.width * 0.051),
        myContainer(context, value2),
      ],
    );
  }

// Method for Leave Type selection
  Widget _buildLeaveTypeRow(Size size) {
    return Row(
      children: [
        SizedBox(width: size.width * 0.22),
        Text(
          'Leave Type:',
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: size.width * 0.023),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leaveTypeError != null)
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  leaveTypeError!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            Container(
              width: size.width * 0.16,
              height: size.height * 0.042,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(2),
                color: bgColor,
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
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    icon: Icon(Icons.keyboard_arrow_down_outlined, size: 25, color: Colors.black),
                    isExpanded: true,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: size.width * 0.065),
        Text(
          'Leave balance:',
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: size.width * 0.010),
        myContainer(context, '04'),
      ],
    );
  }

// Half day checkbox row
  Widget _buildHalfDayRow(Size size) {
    return Row(
      children: [
        SizedBox(width: size.width * 0.22),
        Text(
          'Half day:',
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: black, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: size.width * 0.042),
        GestureDetector(
          onTap: () {
            setState(() {
              isHalfDay = !isHalfDay;
              if (_fromDate != null && _toDate != null) {
                _calculateDays();
              }
            });
          },
          child: Container(
            width: size.width * 0.018,
            height: size.height * 0.035,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              color: isHalfDay ? Colors.blue : Colors.transparent,
            ),
            child: Center(
              child: isHalfDay ? Icon(Icons.check, color: Colors.white, size: 20) : null,
            ),
          ),
        ),
      ],
    );
  }

// Date selection row
  Widget _buildDateSelectionRow(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: size.width * 0.22),
        Text(
          'Select Date:',
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: size.width * 0.022),
        DateField(
          controller: from,
          errorMessage: fromDateError,
          onTap: (context) => _selectDate(context, from, true),
        ),
        SizedBox(width: size.width * 0.03),
        DateField(
          controller: to,
          errorMessage: toDateError,
          onTap: (context) => _selectDate(context, to, false),
        ),
        SizedBox(width: size.width * 0.025),
        Container(
          width: size.width * 0.14,
          height: size.height * 0.042,
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: days,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }

// Apply To section with checkboxes
  Widget _buildApplyToRow(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (applyToError != null)
          Padding(
            padding: EdgeInsets.only(left: size.width * 0.22, bottom: 4),
            child: Text(
              applyToError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        Row(
          children: [
            SizedBox(width: size.width * 0.22),
            Text(
              'Apply To:',
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: size.width * 0.035),
            Text(
              'Manager:',
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: size.width * 0.015),
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: isManager,
                onChanged: (bool? newValue) {
                  setState(() {
                    isManager = newValue ?? false;
                  });
                },
                side: BorderSide(color: Colors.grey.shade500, width: 1.5),
              ),
            ),
            SizedBox(width: size.width * 0.035),
            Text(
              'Superior:',
              style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: size.width * 0.015),
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: !isManager, // Assuming this is the opposite of manager
                onChanged: (bool? newValue) {
                  setState(() {
                    isManager = !(newValue ?? true); // Toggle the opposite checkbox
                  });
                },
                side: BorderSide(color: Colors.grey.shade500, width: 1.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

// Reason text field
  Widget _buildReasonField(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason:',
          style: TextStyle(fontFamily: 'Inter', fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: size.height * 0.01),
        Container(
          width: size.width * 0.8,
          height: size.height * 0.1,
          child: TextField(
            controller: reason,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              hintText: 'Enter your reason here',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            maxLines: 3,
          ),
        ),
      ],
    );
  }

// Submit button


}

//tablet view
class TabletLeave extends StatefulWidget {
  const TabletLeave({super.key}); // Constructor with optional key

  @override
  State<TabletLeave> createState() => _TabletLeaveState(); // Create state without 'return'
}

class _TabletLeaveState extends State<TabletLeave> {
  TextEditingController leave=TextEditingController();
  TextEditingController from=TextEditingController();
  TextEditingController to=TextEditingController();
  TextEditingController reason=TextEditingController();
  TextEditingController  days=TextEditingController();


  final List<String> _leaveTypes = ['Annual Leave', 'Sick Leave', 'Hospitalisation Leave','Unpaid Authorised Leave','Marriage Leave',
    'Maternity/Paternity Leave','Compassionate Leave','Unpaid Unauthorised Leave'];
  final List<String> _roles = ['Manager','Supervisor'];
  String? _selectedRole;
  String? _selectedLeaveType;
  DateTime? selectedDate;
  bool isSelected=false;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isChecked = false;
  bool isHalfDay=false;
  String? selectedTicket;
  bool isManager=false;
  bool isSuperior=false;

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
        String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
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



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.05,),
        Row(
          children: [
            SizedBox(width: size.width * 0.20,),
            Text('Badge #:',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
            SizedBox(width: size.width * 0.042,),
            myContainer(context, '0001'),
            SizedBox(width: size.width * 0.088,),
            Text('Name:',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
            SizedBox(width: size.width * 0.072,),
            myContainer(context, 'Adinin'),
          ],
        ),
        SizedBox(height: size.height * 0.025,),
        Row(
          children: [
            SizedBox(width: size.width * 0.20,),
            Text('Dept/Dev:',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
            SizedBox(width: size.width * 0.035,),
            myContainer(context, 'Xyz'),
            SizedBox(width: size.width * 0.085,),
            Text('Job Title:',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
            SizedBox(width: size.width * 0.053,),
            myContainer(context, 'Worker'),
          ],
        ),
        SizedBox(height: size.height * 0.03,),
        Row(// Align error message properly
          children: [
            SizedBox(width: size.width * 0.20),
            Text(
              'Leave Type:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.020),

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
                  height: size.height * 0.042,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey, // Keep the border color gray always
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(2),
                    color: bgColor,
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
                                  fontSize: 15,
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
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.010),
            myContainer(context, '04'),
          ],
        ),
        SizedBox(height: size.height * 0.04,),
        Row(
          children: [
            //Half day
            SizedBox(width: size.width * 0.20,),
            Text('Half day:',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
            SizedBox(width: size.width * 0.042,),
            Container(
              width: size.width * 0.028,
              height: size.height * 0.038,
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
        SizedBox(height: size.height * 0.03,),
        Row(
          children: [
            SizedBox(width: size.width * 0.32,),
            Text('From',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
            SizedBox(width: size.width * 0.165,),
            Text('To',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
            SizedBox(width: size.width * 0.19,),
            Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,fontWeight: FontWeight.bold),),
          ],
        ),
        SizedBox(height: size.height * 0.015,),
        Row(
          children: [
            SizedBox(width: size.width * 0.20),
            Text(
              'Select Date:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                color: black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.020),

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
                  width: size.width * 0.18,
                  height: size.width * 0.028,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: from,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(4),
                        suffixIcon: IconButton(
                          onPressed: () => _selectDate(context, from, true),
                          icon: Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: black,
                          ),
                        ),
                        hintText: 'dd/mm/yyyy',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: grey, width: 1),
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
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
                  width: size.width * 0.18,
                  height: size.width * 0.028,
                  child: Material(
                    color: Colors.transparent,
                    child: TextField(
                      controller: to,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(4),
                        hintText: 'dd/mm/yyyy',
                        suffixIcon: IconButton(
                          onPressed: () => _selectDate(context, to, false),
                          icon: Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: black,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: grey, width: 1),
                          borderRadius: BorderRadius.circular(0),
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
              width: size.width * 0.16,
              height: size.width * 0.028,
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: days,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: grey, width: 1),
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  readOnly: true,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.03,),
        Row(
          children: [
            SizedBox(width: size.width * 0.20),
            Text(
              'Apply To:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.035),
            Text(
              'Manager:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.015),
            Transform.scale(
              scale: 1.5, // Adjust this value to change the checkbox size
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
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.015),
            Transform.scale(
              scale: 1.5, // Adjust this value to change the checkbox size
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
        SizedBox(height: size.height * 0.02,),
        SizedBox(height: size.height * 0.025,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensures vertical alignment
          children: <Widget>[
            // Adjust space before the label as needed
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.205, bottom: size.height * 0.090),
              child: Text(
                'Reason:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.048), // Adjust space between label and textfield as needed

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
                  height: size.height * 0.10, // Specify the height of the TextField
                  child: TextField(
                    controller: reason,
                    style: TextStyle(fontSize: 16), // Adjust text size within the TextField
                    maxLines: null, // Allows the TextField to expand vertically
                    expands: true, // Allows the TextField content to fill the available space
                    textAlignVertical: TextAlignVertical.top, // Centers text vertically
                    decoration: InputDecoration(
                      hintText: 'Text Here',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.only(top: 15, left: 10), // Padding inside the TextField
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: size.width * 0.01,),
        Row(
          children: [
            SizedBox(width: size.width * 0.33,),
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
            SizedBox(width: size.width * 0.35,),
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
                          onPressed: () {
                            // Action on Yes (confirmation)
                            Get.off(DashBoardScreeen()); // Close the dialog
                            // Proceed with applying leave
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
                minWidth: size.width * 0.11,
                height: size.height * 0.06,
                color: yellow,
                child: Text('Apply',style: TextStyle(fontFamily: 'Inter',fontSize: 13,fontWeight: FontWeight.bold,color: black),),
              ),
            ),
            SizedBox(width: size.width * 0.02,),
            OutlinedButton(
              onPressed: () {
                Get.off(DashBoardScreeen());
              },
              style: OutlinedButton.styleFrom(
                minimumSize: Size(size.width * 0.11, size.height * 0.06), // Similar to minWidth and height in MaterialButton
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
            )
          ],
        )

      ],
    );
  }
}

class MobileLeave extends StatelessWidget {
  const MobileLeave({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Widget myContainer(BuildContext context,String text){
  final Size size = MediaQuery.of(context).size;
  return    Container(
    width: size.width * 0.14,
    height: size.height * 0.038,
    decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade700,width: 1)
    ),
    child: Padding(
      padding:  EdgeInsets.all( 5.0),
      child: Text(text,style: TextStyle(color: Colors.grey.shade500,fontFamily: 'Inter',fontSize: 16),),
    ),
  );
}

