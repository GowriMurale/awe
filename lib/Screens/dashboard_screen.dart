
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:awe_project/Components/dashboard.dart';
import 'package:awe_project/Components/helper_class.dart';
import 'package:awe_project/Screens/signup_screen.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:awe_project/globals/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../globals/navigation_bar.dart';
import '../models/CandidateApplicationForm.dart';
import '../models/LeaveStatus.dart';
import 'apply_leave_screen.dart';
import 'login_screen.dart';
class DashBoardScreeen extends StatefulWidget {
  @override
  State<DashBoardScreeen> createState() => _DashBoardScreeenState();
}

class _DashBoardScreeenState extends State<DashBoardScreeen> {

  //NAV BAR METHODS
  DateTime now = DateTime.now(); // Get the current date and time
  String formattedDate = DateFormat(' dd/MM/yyyy    HH:mm:ss').format(DateTime.now());

  final TextEditingController userIdController = TextEditingController();
  final box = GetStorage();
  Future<void> storeTempIdLocally() async {
    final box = GetStorage();
    box.write('tempId', "TEMP001");  // Hardcoded tempId
    print("TempId 'TEMP001' stored locally");
  }

  // Method to retrieve tempId from local storage
  String? getTempIdFromStorage() {
    final box = GetStorage();
    return box.read('tempId');  // Retrieve tempId from local storage
  }

  // Fetch candidate application data using the stored tempId
  Future<void> fetchCandidateApplicationData(BuildContext context) async {
    try {
      // Get the stored tempId (e.g., 'TEMP001')
      final box = GetStorage();
      String tempId = box.read('tempId') ?? '';  // Retrieve tempId from storage

      if (tempId.isEmpty) {
        _showErrorDialog(context, 'No tempId found in local storage.');
        return;
      }

      // Query the API to get candidate application details using tempId
      final request = ModelQueries.list(
        CandidateApplicationForm.classType,
        where: CandidateApplicationForm.TEMPID.eq(tempId), // Query using tempId
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        print('Errors: ${response.errors}');
        _showErrorDialog(context, 'Failed to fetch application data.');
        return;
      }

      List<CandidateApplicationForm?> candidateApplications = response.data?.items ?? [];
      print(candidateApplications);

      if (candidateApplications.isNotEmpty && candidateApplications.first != null) {
        var candidate = candidateApplications.first;
        print(candidate);

        // Store candidate data locally for later use
        box.write('name', candidate?.name ?? 'N/A');
        box.write('email', candidate?.email ?? 'N/A');
        box.write('contactNo', candidate?.contactNo ?? 'N/A');

        print("Candidate Name: ${candidate?.name}");
        print("Candidate Email: ${candidate?.email}");
        print("Candidate Contact No: ${candidate?.contactNo}");
      } else {
        _showErrorDialog(context, 'No data found for the provided tempId.');
      }
    } catch (e) {
      print('Failed to fetch candidate data: $e');
      _showErrorDialog(context, 'An unexpected error occurred.');
    }
  }

  String name = 'N/A';
  String email = 'N/A';
  String contactNo = 'N/A';

  // @override
  // void initState(){
  //   super.initState();
  //   loadUserData();
  // }

  void loadUserData() {
    setState(() {
      name = box.read('name') ?? 'N/A';
      email = box.read('email') ?? 'N/A';
      contactNo = box.read('contactNo') ?? 'N/A';
    });
  }


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
              SizedBox(height: 10,),
              Container(
                height: 70,
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user image.png'),
                  radius: 25,
                  child: Container(
                    width: 100, // Width of the button
                    height: 30, // Height of the button
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 13) ,
                    child: IconButton(
                        color: Colors.black,
                        iconSize: 15,
                        padding: EdgeInsets.all(20),
                        onPressed: () {
                          _showPopupMenu(context);
                        }, icon: Icon(Icons.photo_camera_outlined,)
                    ),
                  ),
                ),
              ),

              SizedBox(height: 5,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        height: 20,
                        padding: EdgeInsets.only(left: 12),
                        child:Text('Personal Info',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontStyle: FontStyle.normal),)
                    ),
                    SizedBox(width: 90,),
                    GestureDetector(
                      onTap: (){
                        _showEditDialog(context);
                      },
                      child: RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Edit',
                                style: TextStyle(fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                  fontStyle: FontStyle.normal,
                                  decoration: TextDecoration.underline,
                                ),
                                // Use GestureRecognizer to detect taps
                              ),
                            ]),),
                    )]),
              SizedBox(height: 7,),
              Divider(
                thickness: 1.5,
                color: Colors.black45,
              ),
              SizedBox(height: 3,),
              Container(
                height: 32,
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white, // Background color of the container
                  border: Border.all(
                    color: Colors.grey, // Border color
                    width: 1, // Border width
                  ),
                  borderRadius: BorderRadius.circular(7), // Optional: rounded corners
                ),

                child: Row(
                    children: [
                      SizedBox(width: 20,),
                      Text('Nur Hafiza',
                        style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black87),),]),
              ),
              SizedBox(height: 10,),
              Container(
                height: 32,
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white, // Background color of the container
                  border: Border.all(
                    color: Colors.grey, // Border color
                    width: 1, // Border width
                  ),
                  borderRadius: BorderRadius.circular(7), // Optional: rounded corners
                ),
                child: Row(children: [
                  SizedBox(width: 20,),
                  Text(
                    '8056863355',
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black87),),
                ]),),
              SizedBox(height: 10,),
              Container(
                width: 280,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white, // Background color of the container
                  border: Border.all(
                    color: Colors.grey, // Border color
                    width: 1, // Border width
                  ),
                  borderRadius: BorderRadius.circular(7), // Optional: rounded corners
                ),
                child:Row(children: [
                  SizedBox(width: 20,),
                  Text(
                    'adinin@gmail.com',
                    style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.black87),
                  ),
                ]),),

              SizedBox(height: 10),
              Row(
                  children: [
                    Container(
                      height: 30,
                      width: 135,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(() => changePasswordScreen(username: userIdController.text.trim()));
                        },
                        style: ButtonStyle(
                          side: MaterialStateProperty.all(
                            BorderSide(color: Colors.yellow, width: 3), // Change border color and width
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7), // Rounded corners
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
                      child: TextButton(
                        onPressed: () {
                          _confirmSignOut(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(7), // Rounded corners
                          ),
                        ),
                        child: Row(
                            children: [
                              SizedBox(width: 20,) ,
                              Text('Logout',style: TextStyle(
                                  fontSize: 10,fontWeight: FontWeight.bold,color: Colors.black)),
                              SizedBox(width: 5,) ,
                              Icon(Icons.logout_outlined),
                            ]),
                      ),),
                    SizedBox(height: 50)
                  ]),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController fullName=TextEditingController();
    TextEditingController email=TextEditingController();
    TextEditingController mobile=TextEditingController();

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
                  Text('Full Name', style: TextStyle(fontSize: 14)),
                  SizedBox(width: size.width * 0.093,),
                  // Text('Last Name', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: size.height * 0.007,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width* 0.080,),
                  newContainer(context, fullName,'Nur Hafiza'),
                  // myContainer(context, lastName),
                ],
              ),
              SizedBox(height:size.height * 0.020,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  Text('Mobile Number', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: size.height *0.007,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  newContainer(context, mobile,'8056863355')
                ],
              ),
              SizedBox(height:size.height * 0.020,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  Text('Email Address', style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: size.height *0.007,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.080,),
                  newContainer(context, email,'adinin@gmail.com')
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

  //DASHBOARD METHODS
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();
  List<LeaveStatus?> allLeaveData = []; // Your leave data
  List<LeaveStatus?> filteredLeaveData = [];
  TextStyle headerTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Colors.black,
  );

  TextStyle rowTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    color: Colors.black,
  );
  // Filtered leave data based on date range

  @override
  void initState() {
    super.initState();
    fetchLeaveData(); // Fetch data when the widget initializes
  }
  @override
  void dispose() {
    from.dispose();
    to.dispose();
    super.dispose();
  }
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
      filterLeaveData(); // Call filter function whenever a new date is picked
    }
  }

  Future<void> fetchLeaveData() async {
    try {
      // Define the GraphQL query
      final request = ModelQueries.list(LeaveStatus.classType);
      final response = await Amplify.API.query(request: request).response;

      // Check for errors
      if (response.errors.isNotEmpty) {
        print('Errors: ${response.errors}');
        _showAlertDialog('Error', 'Failed to fetch leave data.');
        return;
      }

      // Parse the leave data
      List<LeaveStatus?> leaveStatuses = response.data?.items ?? [];

      setState(() {
        allLeaveData = leaveStatuses;
      });

      // Initially, show all data
      filterLeaveData();
    } catch (e) {
      print('Failed to fetch leave data: $e');
      _showAlertDialog('Error', 'An unexpected error occurred.');
    }
  }
  List<String> leaveStatuses = [];

  void filterLeaveData() {
    if (from.text.isEmpty && to.text.isEmpty) {
      setState(() {
        filteredLeaveData = allLeaveData;
        // Initialize leaveStatuses based on the length of filteredLeaveData
        leaveStatuses = List.generate(filteredLeaveData.length, (index) {
          if (index % 3 == 0) {
            return 'Pending';
          } else if (index % 3 == 1) {
            return 'Approved';
          } else {
            return 'Rejected';
          }
        });
      });
      return;
    }

    DateTime? fromDate;
    DateTime? toDate;

    try {
      if (from.text.isNotEmpty) {
        fromDate = DateFormat('dd/MM/yyyy').parse(from.text);
      }
      if (to.text.isNotEmpty) {
        toDate = DateFormat('dd/MM/yyyy').parse(to.text);
      }
    } catch (e) {
      print('Error parsing dates: $e');
      _showAlertDialog('Error', 'Invalid date format.');
      return;
    }

    List<LeaveStatus?> tempFiltered = allLeaveData.where((leave) {
      if (leave == null || leave.fromDate == null || leave.toDate == null) return false;

      final leaveFromDate = leave.fromDate!.getDateTime();
      final leaveToDate = leave.toDate!.getDateTime();

      bool afterFrom = fromDate != null
          ? leaveFromDate.isAfter(fromDate) || leaveFromDate.isAtSameMomentAs(fromDate)
          : true;
      bool beforeTo = toDate != null
          ? leaveToDate.isBefore(toDate) || leaveToDate.isAtSameMomentAs(toDate)
          : true;

      return afterFrom && beforeTo;
    }).toList();

    setState(() {
      filteredLeaveData = tempFiltered;
      // Initialize leaveStatuses based on the length of filteredLeaveData
      leaveStatuses = List.generate(filteredLeaveData.length, (index) {
        if (index % 3 == 0) {
          return 'Pending';
        } else if (index % 3 == 1) {
          return 'Approved';
        } else {
          return 'Rejected';
        }
      });
    });
  }

  Future<void> deleteLeave(LeaveStatus leaveToDelete) async {
    try {
      final request = ModelMutations.delete(leaveToDelete);
      final response = await Amplify.API.mutate(request: request).response;

      // Check for errors
      if (response.errors.isNotEmpty) {
        print('Errors deleting leave: ${response.errors}');
        _showAlertDialog('Error', 'Failed to delete leave request.');
        return;
      }

      // Remove the deleted leave from both lists
      setState(() {
        allLeaveData.removeWhere((leave) => leave?.id == leaveToDelete.id);
        filteredLeaveData.removeWhere((leave) => leave?.id == leaveToDelete.id);
      });

      print('Leave deleted successfully: ${leaveToDelete.toString()}');

      _showAlertDialog('Success', 'Leave request deleted successfully.');
    } catch (e) {
      print('Failed to delete leave: $e');
      _showAlertDialog('Error', 'An unexpected error occurred.');
    }
  }

  /// Show an AlertDialog using GetX
  void _showAlertDialog(String title, String content) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _pendingDialog(BuildContext context, int rowIndex, LeaveStatus leave, Function(String) onStatusChanged) {
    final Size size = MediaQuery.of(context).size;
    String status = 'Pending'; // Initialize the status locally

    Get.dialog(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              padding: EdgeInsets.all(8),
              width: size.width * 0.310,
              decoration: BoxDecoration(
                color: Color(0xFF1F1F1).withOpacity(1.0),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: size.height * 0.012),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: size.width * 0.128),
                      Text(
                        'Pending',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 22,fontWeight: FontWeight.bold ,color: Colors.black),
                      ),
                      SizedBox(width: size.width * 0.075),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.cancel_outlined, size: 26, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.058,),
                      Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.045,),
                      Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.057,),
                      Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.048,),
                      Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.035,),
                      Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.016,),
                      Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.048,),
                      Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.035,),
                      Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.050,),
                      Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                      SizedBox(width:size.width *  0.050,),
                      Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.024),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.121),
                      MaterialButton(
                        minWidth: size.width * 0.062,
                        height: size.height * 0.052,
                        onPressed: () {
                          _showCancelConfirmation(context, onStatusChanged);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                        ),
                        color: Colors.yellow,
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.018),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  void _tabpendingDialog(BuildContext context, int rowIndex, LeaveStatus leave,Function(String) onStatusChanged) {
    final Size size = MediaQuery.of(context).size;
    String status = 'Pending'; // Initialize the status locally

    Get.dialog(
      StatefulBuilder( // Use StatefulBuilder to manage state within the dialog
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              padding: EdgeInsets.all(8),
              width: size.width * 0.4,
              decoration: BoxDecoration(
                color: Color(0xFF1F1F1).withOpacity(1.0),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: size.height * 0.012),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: size.width * 0.160),
                      Text(
                        'Pending',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black),
                      ),
                      SizedBox(width: size.width * 0.110),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.cancel_outlined, size: 24, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.074,),
                      Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.058,),
                      Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.074,),
                      Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.060,),
                      Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.046,),
                      Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.020,),
                      Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.062,),
                      Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.047,),
                      Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.057,),
                      Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                      SizedBox(width:size.width *  0.066,),
                      Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.025),
                  Row(
                    children: [
                      SizedBox(width:size.width *  0.152,),
                      MaterialButton(
                        minWidth: size.width * .085,
                        height: size.height * 0.050,
                        onPressed: () {
                          _showCancelConfirmation(context, onStatusChanged);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 15, fontFamily: 'Inter'),
                        ),
                        color: Colors.yellow,
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.018),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );

    // Refresh the DataTable to reflect the updated status in UI (if necessary)
  }

  void _phonependingDialog(BuildContext context, int rowIndex, LeaveStatus leave,Function(String) onStatusChanged) {
    final Size size = MediaQuery.of(context).size;
    String status = 'Pending'; // Initialize the status locally

    Get.dialog(
      StatefulBuilder( // Use StatefulBuilder to manage state within the dialog
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              padding: EdgeInsets.all(8),
              width: size.width * 0.65,
              decoration: BoxDecoration(
                color: dialog,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: size.height * 0.012),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: size.width * 0.210),
                      Text(
                        'Pending',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 18,fontWeight: FontWeight.bold ,color: Colors.black),
                      ),
                      SizedBox(width: size.width * 0.090),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.cancel_outlined, size: 22, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.126),
                      Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.092,),
                      Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.122,),
                      Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.098,),
                      Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.064,),
                      Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.021,),
                      Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.095,),
                      Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.063,),
                      Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width:size.width *  0.063,),
                      Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                      SizedBox(width:size.width *  0.097,),
                      Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                    ],
                  ),
                  SizedBox(height: size.height * 0.025),
                  Row(
                    children: [
                      SizedBox(width:size.width *  0.195,),
                      MaterialButton(
                        minWidth: size.width * .135,
                        height: size.height * 0.050,
                        onPressed: () {
                          _showCancelConfirmation(context, onStatusChanged);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
                        ),
                        color: Colors.yellow,
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.018),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );

    // Refresh the DataTable to reflect the updated status in UI (if necessary)
  }

// Confirmation dialog before canceling the request
  void _showCancelConfirmation(BuildContext context, Function(String) onStatusChanged) {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel'),
        content: Text('Are you sure want to cancel leave request'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the confirmation dialog
            },
            child: Text('No',style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the confirmation dialog
              onStatusChanged('Cancelled');
              _showCancelSuccess(context);
            },
            child: Text('Yes',style: TextStyle(color: Colors.green),),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

// Success dialog after cancellation
  void _showCancelSuccess(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Success'),
        content: Text('Leave request canceled successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the success dialog
              Navigator.pop(context); // Close the pending dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }





  void _rejectedDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
    final Size size = MediaQuery.of(context).size;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          width: size.width * 0.310,
          decoration: BoxDecoration(
            color: Color(0xFF1F1F1).withOpacity(1.0),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: size.height * 0.012),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.120),
                  Text(
                    'Rejected',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold,color: Colors.black),
                  ),
                  SizedBox(width: size.width * 0.080),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.cancel_outlined, size: 26, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.014),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.052,),
                  Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.038,),
                  Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.050,),
                  Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.039,),
                  Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.028,),
                  Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.047,),
                  Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.013,),
                  Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.044,),
                  Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.029,),
                  Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.045,),
                  Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.022),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Comments',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.028,),
                 Container(
                   width: size.width * 0.15,
                   height: size.height * 0.07,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     border: Border.all(color: grey,width: 1)
                   ),
                   child: Text('  Rejected we have production \n   please planing leave latter',style: TextStyle(color: black,fontSize: 14,fontFamily: 'Inter'),),
                 )
                ],
              ),
              SizedBox(height: size.height * 0.022),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _approvedDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
    final Size size = MediaQuery.of(context).size;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          width: size.width * 0.310,
          decoration: BoxDecoration(
            color: Color(0xFF1F1F1).withOpacity(1.0),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: size.height * 0.012),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.123),
                  Text(
                    'Approved',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold,color: Colors.black),
                  ),
                  SizedBox(width: size.width * 0.080),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.cancel_outlined, size: 26, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.016),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.052,),
                  Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.039,),
                  Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.050,),
                  Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.041,),
                  Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.027,),
                  Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.047,),
                  Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.013,),
                  Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.044,),
                  Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.031,),
                  Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.047,),
                  Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.020),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }


  void _tabCancelDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
    final Size size = MediaQuery.of(context).size;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          width: size.width * 0.360,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: size.height * 0.012),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width * 0.100),
                  Text(
                    'View Form',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 22, color: Colors.black),
                  ),
                  SizedBox(width: size.width * 0.095),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.cancel_outlined, size: 22, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.014),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.043,),
                  Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.030,),
                  Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.041,),
                  Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.032,),
                  Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.020,),
                  Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Select Date',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.020,),
                  Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.037,),
                  Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.022,),
                  Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.014,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width:size.width *  0.050,),
                  Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                  SizedBox(width:size.width *  0.040,),
                  Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ],
              ),
              SizedBox(height: size.height * 0.022),
              MaterialButton(
                minWidth: size.width * .065,
                height: size.height * 0.03,
                onPressed: () {
                  print(leave);
                  deleteLeave(leave); // Delete leave from AWS DynamoDB
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel Leave',
                  style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                ),
                color: Colors.yellow,
                textColor: Colors.black,
              ),
              SizedBox(height: size.height * 0.014),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return HelperClass(
        desktop: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(''),
            flexibleSpace: Container(
              decoration: BoxDecoration(
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0), // Height of the border
              child: Container(
                color: Colors.black12, // Border color
                height: 1.0, // Height of the border
              ),
            ),
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
              // Icon(Icons.mail_outline_outlined),
              SizedBox(width: 30), // spacing between icons
              Icon(Icons.notifications_outlined),

              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    Container(
                      width: 15.0,  // Set the width
                      height: 15.0, // Set the height
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,  // Circular shape
                        color: Colors.yellow,      // Background color
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: TextStyle(fontSize:9,fontWeight:FontWeight.bold,color: Colors.black),
                        ),
                      ),
                    ),]),
              SizedBox(width: 70), // spacing between icons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Nur Hafiza',
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
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Container(
                        height: size.height * 0.095,
                        child: CircleAvatar(
                            backgroundImage: AssetImage('assets/images/user image.png'),
                            radius: 23,
                            child:Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                //mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    height:size.height * 0.035,
                                    width:size.width * 0.070,
                                    padding: EdgeInsets.only(left: size.width * 0.010,top: size.height * 0.006,),
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.grey.shade300,
                                            shape: CircleBorder()
                                        ),
                                        onPressed: () {
                                          _showPopupMenu(context);
                                        }, child: Icon(Icons.edit_outlined,size: 10,color: Colors.black87,)
                                    ),)])
                        ),
                      ),),]),
              SizedBox(width: 30), // spacing between the profile and app bar end
            ],
            toolbarHeight: 75.0,
          ),
          backgroundColor: Colors.white,
          body:
          SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: size.width* 0.19,),
                      // IconButton(onPressed: (){
                      //   Get.back();
                      // }, icon: Icon(Icons.arrow_back,size: 20,color: Colors.black,)),
                      // SizedBox(width: size.width* 0.14,),
                      Text('Welcome',style: TextStyle(color: black,fontSize:24 ,fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
                      SizedBox(width: size.width * 0.01,),
                      Text('Nur Hafiza',style: TextStyle(color: griesh,fontFamily:'Inter',fontSize: 26,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.025,),
                  Row(
                    children: [
                      SizedBox(width: size.width* 0.180,),
                      employeeInfoCard(
                        context,
                        'Trainer',          // Employee Type
                        '12/10/2024',       // Date of Joining
                        'Permanent',        // Contract Type
                        'Engineer',         // Department
                        'Offshore',
                        size.width * 0.60,
                        size.height * 0.105,
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.046,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.188),
                      Text('OffShore',style: TextStyle(color: dashgrey,fontFamily: 'Inter',fontSize: 20,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.183),
                      Container(
                        width: size.width * 0.6,
                        height: size.height * 0.21,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300,width: 1),
                          borderRadius: BorderRadius.circular(5),
                          color: white
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.010,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.205),
                                Text('Total AL/SL/UA',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.040),
                                Text('Leave Taken',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.040),
                                Text('Remaining',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.040),
                                Text('Leave Request',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            SizedBox(height: size.height * 0.010,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.095),
                                Text('Annual Leave',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.060),
                                Container(
                                  width: size.width * 0.042,
                                  height: size.height * 0.035,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300,width: 1),
                                    color: Colors.white,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                      child: Text('7',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),)),
                                ),
                                SizedBox(width: size.width * 0.052),
                                shoreContainer(context, '4',15),
                                SizedBox(width: size.width * 0.052),
                                shoreContainer(context, '3',15),
                                SizedBox(width: size.width * 0.052),
                                shoreContainer(context, '1',15),
                              ],
                            ),
                            SizedBox(height: size.height * 0.010,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.095),
                                Text('Sick Leave',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.072),
                                shoreContainer(context, '7',15),
                                SizedBox(width: size.width * 0.052),
                                shoreContainer(context, '4',15),
                                SizedBox(width: size.width * 0.052),
                                shoreContainer(context, '3',15),
                                SizedBox(width: size.width * 0.052),
                                shoreContainer(context, '1',15),
                              ],
                            ),
                            SizedBox(height: size.height * 0.012,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.095),
                                Text('Unpaid Authorize',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 14,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.046),
                                shoreContainer(context, '0',15),
                                SizedBox(width: size.width * 0.030),
                              ],
                            ),

                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: size.height * 0.060,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.190),
                      Text(
                        'My Recent Leave',
                        style: TextStyle(color: Colors.black, fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: size.width * 0.328),
                      Container(
                        width: size.width * 0.082,
                        height: size.height * 0.034,
                        color: Colors.white,
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: from,
                            style: TextStyle(
                              fontSize: 12, // Set a smaller font size for the picked date
                              color: Colors.black, // You can also control the color of the text
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5, bottom: 6),
                              hintText: 'From',
                              hintStyle: TextStyle(fontSize: 12),
                              suffixIcon: IconButton(
                                padding:   EdgeInsets.only(bottom: 0.04),
                                onPressed: () => _selectDate(context, from), // Correct the onPressed
                                icon: Icon(
                                  Icons.calendar_month,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: grey, width: 1), // Keep border color grey
                                borderRadius: BorderRadius.circular(0),
                              ),

                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.018),
                      Container(
                        width: size.width * 0.082,
                        height: size.height * 0.034,
                        color: Colors.white,
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: to,
                            style: TextStyle(
                              fontSize: 12, // Set a smaller font size for the picked date
                              color: Colors.black, // You can also control the color of the text
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5, bottom: 6),
                              hintText: 'To',
                              hintStyle: TextStyle(fontSize: 12),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.only(bottom: 0.04),
                                onPressed: () => _selectDate(context, to), // Correct the onPressed
                                icon: Icon(
                                  Icons.calendar_month,
                                  size: 15,
                                  color: Colors.black,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: grey, width: 1), // Keep border color grey
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),


                  Row(
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(left: size.width * 0.175,top: size.height * 0.025),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: filteredLeaveData.isNotEmpty
                              ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowHeight: filteredLeaveData.isEmpty ? 0 : size.height * 0.050,
                              dataRowHeight: size.height * 0.055,
                              columnSpacing: size.width * 0.045,
                              columns: [
                                DataColumn(label: Text('Leave Type', style: headerTextStyle)),
                                DataColumn(label: Text('From', style: headerTextStyle)),
                                DataColumn(label: Text('To', style: headerTextStyle)),
                                DataColumn(label: Text('Days', style: headerTextStyle)),
                                DataColumn(label: Text('Reason', style: headerTextStyle)),
                                DataColumn(label: Text('Approver', style: headerTextStyle)),
                                DataColumn(label: Text('Status', style: headerTextStyle)),
                              ],
                              rows: filteredLeaveData.map((leave) {
                                int index = filteredLeaveData.indexOf(leave);

                                return DataRow(
                                  cells: [
                                    DataCell(GestureDetector(
                                      onTap: () {
                                        if (leaveStatuses[index] == 'Pending') {
                                          _pendingDialog(context, index, leave, (newStatus) {
                                            setState(() {
                                              leaveStatuses[index] = newStatus;
                                            });
                                          });
                                        } else if (leaveStatuses[index] == 'Approved') {
                                          _approvedDialog(context, index, leave);
                                        } else if (leaveStatuses[index] == 'Rejected') {
                                          _rejectedDialog(context, index, leave);
                                        }
                                      },
                                      child: Text(leave!.leaveType ?? '', style: rowTextStyle),
                                    )),
                                    DataCell(Text(
                                      leave.fromDate != null
                                          ? DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())
                                          : '',
                                      style: rowTextStyle,
                                    )),
                                    DataCell(Text(
                                      leave.toDate != null
                                          ? DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())
                                          : '',
                                      style: rowTextStyle,
                                    )),
                                    DataCell(Text('${leave.days ?? 0} days', style: rowTextStyle)),
                                    DataCell(Text(leave.reason ?? '', style: rowTextStyle)),
                                    DataCell(Text(leave.applyTo ?? '', style: rowTextStyle)),
                                    DataCell(Text(leaveStatuses[index], style: rowTextStyle)), // Display the status dynamically
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                              : SizedBox(),
                        ),

                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.032,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.42,),
                      MaterialButton(
                        onPressed: (){
                          Get.to(()=>ApplyLeaveScreen());
                        },
                        minWidth: size.width * 0.085,
                        height: size.height * 0.060,
                        color: yellow,
                        child: Text('Apply Leave',style: TextStyle(fontFamily: 'Inter,',fontSize: 15,fontWeight: FontWeight.bold,color: black),),
                      ),
                      SizedBox(width: size.width * 0.015,),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {

                            },
                            child: Text(
                              "Request Ticket",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none, // Remove default underline
                              ),
                            ),
                          ),
                          // Add space between text and line
                          Container(
                            height: 1,
                            color: blue, // Custom underline color
                            width: size.width * 0.065, // Set the underline width as needed
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: size.height * 0.022,),
                ],
              ),
            ),
        ),

        //TAB VIEW
        tablet: Scaffold(
          appBar: AppBar(
            backgroundColor:bgColor,
            title: Text(''),
            flexibleSpace: Container(
              decoration: BoxDecoration(
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0), // Height of the border
              child: Container(
                color: Colors.black12, // Border color
                height: 1.0, // Height of the border
              ),
            ),
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
              // Icon(Icons.mail_outline_outlined),
              SizedBox(width: 30), // spacing between icons
              Icon(Icons.notifications_outlined),

              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    Container(
                      width: 15.0,  // Set the width
                      height: 15.0, // Set the height
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,  // Circular shape
                        color: Colors.yellow,      // Background color
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: TextStyle(fontSize:9,fontWeight:FontWeight.bold,color: Colors.black),
                        ),
                      ),
                    ),]),
              SizedBox(width: 70), // spacing between icons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Nur Hafiza',
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
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Container(
                        height: 75,
                        child: CircleAvatar(
                            backgroundImage: AssetImage('assets/images/user image.png'),
                            radius: 28,
                            child:Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                //mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    height:22,
                                    width: 500,
                                    padding: EdgeInsets.only(left: 24,top: 3,),
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.grey.shade300,
                                            shape: CircleBorder()
                                        ),
                                        onPressed: () {
                                          _showPopupMenu(context);
                                        }, child: Icon(Icons.edit_outlined,size: 10,color: Colors.black87,)
                                    ),)])
                        ),
                      ),),]),
              SizedBox(width: 30), // spacing between the profile and app bar end
            ],
            toolbarHeight: 75.0,
          ),
          backgroundColor: Colors.white,
          body:
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: size.width* 0.15,),
                      // IconButton(onPressed: (){
                      //   Get.back();
                      // }, icon: Icon(Icons.arrow_back,size: 20,color: Colors.black,)),
                      // SizedBox(width: size.width* 0.14,),
                      Text('Welcome',style: TextStyle(color: black,fontSize:24 ,fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
                      SizedBox(width: size.width * 0.01,),
                      Text('Nur Hafiza',style: TextStyle(color: griesh,fontFamily:'Inter',fontSize: 26,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.025,),
                  Row(
                    children: [
                      SizedBox(width: size.width* 0.13,),
                      tabemployeeInfoCard(context, 'Trainer', '12/10/2024', 'Permanent', 'Engineer', 'Offshore',  size.width * 0.72,
                         size.height * 0.110,),
                    ],
                  ),
                  SizedBox(height: size.height * 0.034,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.148),
                      Text('Off Shore',style: TextStyle(color: dashgrey,fontFamily: 'Inter',fontSize: 18,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  SizedBox(height: size.height * 0.014,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.128),
                      Container(
                        width: size.width * 0.72,
                        height: size.height * 0.21,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300,width: 1),
                            borderRadius: BorderRadius.circular(7),
                            color: white
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 0.018,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.205),
                                Text('Total AL/SL/UA',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.040),
                                Text('Leave Taken',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.040),
                                Text('Remaining',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.040),
                                Text('Leave Request',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            SizedBox(height: size.height * 0.010,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.095),
                                Text('Annual Leave',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.063),
                                Container(
                                  width: size.width * 0.042,
                                  height: size.height * 0.035,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300,width: 1),
                                    color: Colors.white,
                                  ),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text('7',style: TextStyle(fontFamily: 'Inter',fontSize: 13,color: black,fontWeight: FontWeight.bold),)),
                                ),
                                SizedBox(width: size.width * 0.063),
                                shoreContainer(context, '4',13),
                                SizedBox(width: size.width * 0.062),
                                shoreContainer(context, '3',13),
                                SizedBox(width: size.width * 0.058),
                                shoreContainer(context, '1',13),
                              ],
                            ),
                            SizedBox(height: size.height * 0.010,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.095),
                                Text('Sick Leave',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.078),
                                shoreContainer(context, '7',13),
                                SizedBox(width: size.width * 0.063),
                                shoreContainer(context, '4',13),
                                SizedBox(width: size.width * 0.062),
                                shoreContainer(context, '3',13),
                                SizedBox(width: size.width * 0.059),
                                shoreContainer(context, '1',13),
                              ],
                            ),
                            SizedBox(height: size.height * 0.012,),
                            Row(
                              children: [
                                SizedBox(width: size.width * 0.095),
                                Text('Unpaid Authorize',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),),
                                SizedBox(width: size.width * 0.044),
                                shoreContainer(context, '0',13),
                                SizedBox(width: size.width * 0.052),

                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: size.height * 0.057,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.145),
                      Text(
                        'My Recent Leave',
                        style: TextStyle(color: Colors.black, fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: size.width * 0.376),
                      Container(
                        width: size.width * 0.094,
                        height: size.height * 0.034,
                        color: Colors.white,
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: from,
                            style: TextStyle(
                              fontSize: 09, // Set a smaller font size for the picked date
                              color: Colors.black, // You can also control the color of the text
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5, bottom: 6),
                              hintText: 'From',
                              hintStyle: TextStyle(fontSize: 12),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.only(bottom: 0.5),
                                onPressed: () => _selectDate(context, from), // Correct the onPressed
                                icon: Icon(
                                  Icons.calendar_month,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: grey, width: 1), // Keep border color grey
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.018),
                      Container(
                        width: size.width * 0.094,
                        height: size.height * 0.034,
                        color: Colors.white,
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: to,
                            style: TextStyle(
                              fontSize: 09, // Set a smaller font size for the picked date
                              color: Colors.black, // You can also control the color of the text
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 5, bottom: 6),
                              hintText: 'To',
                              hintStyle: TextStyle(fontSize: 12),
                              suffixIcon: IconButton(
                              padding:   EdgeInsets.only(bottom: 0.5),
                                onPressed: () => _selectDate(context, to), // Correct the onPressed
                                icon: Icon(
                                  Icons.calendar_month,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: grey, width: 1), // Keep border color grey
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(left: size.width * 0.115,top: size.height * 0.02),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: filteredLeaveData.isNotEmpty
                              ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowHeight: filteredLeaveData.isEmpty ? 0 : size.height * 0.050,
                              dataRowHeight: size.height * 0.048,
                              columnSpacing: size.width * 0.038,
                              columns: [
                                DataColumn(label: Text('Leave Type', style: tabheaderTextStyle)),
                                DataColumn(label: Text('From', style: tabheaderTextStyle)),
                                DataColumn(label: Text('To', style: tabheaderTextStyle)),
                                DataColumn(label: Text('Days', style: tabheaderTextStyle)),
                                DataColumn(label: Text('Reason', style: tabheaderTextStyle)),
                                DataColumn(label: Text('Approver', style: tabheaderTextStyle)),
                                DataColumn(label: Text('Status', style: tabheaderTextStyle)),
                              ],
                              rows: filteredLeaveData.map((leave) {
                                int index = filteredLeaveData.indexOf(leave);

                                return DataRow(
                                  cells: [
                                    DataCell(GestureDetector(
                                      onTap: () {
                                        if (leaveStatuses[index] == 'Pending') {
                                          _tabpendingDialog(context, index, leave, (newStatus) {
                                            setState(() {
                                              leaveStatuses[index] = newStatus;
                                            });
                                          });
                                        } else if (leaveStatuses[index] == 'Approved') {
                                          _tabapprovedDialog(context, index, leave);
                                        } else if (leaveStatuses[index] == 'Rejected') {
                                          _tabrejectedDialog(context, index, leave);
                                        }
                                      },
                                      child: Text(leave!.leaveType ?? '', style: tabrowTextStyle),
                                    )),
                                    DataCell(Text(
                                      leave.fromDate != null
                                          ? DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())
                                          : '',
                                      style: tabrowTextStyle,
                                    )),
                                    DataCell(Text(
                                      leave.toDate != null
                                          ? DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())
                                          : '',
                                      style: tabrowTextStyle,
                                    )),
                                    DataCell(Text('${leave.days ?? 0} days', style: tabrowTextStyle)),
                                    DataCell(Text(leave.reason ?? '', style: tabrowTextStyle)),
                                    DataCell(Text(leave.applyTo ?? '', style: tabrowTextStyle)),
                                    DataCell(Text(leaveStatuses[index], style: rowTextStyle)), // Display the status dynamically
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                              : SizedBox(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.032,),
                  Row(
                    children: [
                      SizedBox(width: size.width * 0.42,),
                      MaterialButton(
                        onPressed: (){
                          Get.to(()=>ApplyLeaveScreen());
                        },
                        minWidth: size.width * 0.085,
                        height: size.height * 0.060,
                        color: yellow,
                        child: Text('Apply Leave',style: TextStyle(fontFamily: 'Inter,',fontSize: 15,fontWeight: FontWeight.bold,color: black),),
                      ),
                      SizedBox(width: size.width * 0.015,),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Request Ticket",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none, // Remove default underline
                              ),
                            ),
                          ),
                          // Add space between text and line
                          Container(
                            height: 1,
                            color: blue, // Custom underline color
                            width: size.width * 0.065, // Set the underline width as needed
                          ),
                        ],
                      )

                    ],
                  ),
                  SizedBox(height: size.height * 0.026),
                ],
              ),
            ),
        ),

        //MOBILE VIEW
        mobile:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0), // Height of the border
              child: Container(
                color: Colors.black12, // Border color
                height: 1.0, // Height of the border
              ),),
            actions: [
              Row(
                  children: [
                    SizedBox(width: 10,),
                    Center(
                      child: Container(
                        height: 130,
                        width: 130,
                        child: Image.asset('assets/images/awe logo.png',fit: BoxFit.contain),),),
                  ]),
              Spacer(),
              SizedBox(width: 50), // spacing between icons
              Icon(Icons.notifications_outlined),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    Container(
                      width: 15.0,  // Set the width
                      height: 15.0, // Set the height
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,  // Circular shape
                        color: Colors.yellow,      // Background color
                      ),
                      child: Center(
                        child: Text(
                          '1',
                          style: TextStyle(fontSize:9,fontWeight:FontWeight.bold,color: Colors.black),
                        ),
                      ),
                    ),]),
              SizedBox(width: 10), // spacing between icons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Nur Hafiza',
                    style: TextStyle(fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        fontStyle: FontStyle.normal), // Reduce height between lines
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        fontStyle: FontStyle.normal), // Same height to ensure no spacing
                  ),
                ],
              ),
              SizedBox(width: 10,),
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Container(
                        height: 75,
                        child: CircleAvatar(
                            backgroundImage: AssetImage('assets/images/user image.png'),
                            radius: 22,
                            child:Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                //mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(
                                    height:25,
                                    width: 450,
                                    padding: EdgeInsets.only(left: 20,top: 1,),
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.grey.shade300,
                                            shape: CircleBorder()
                                        ),
                                        onPressed: () {
                                          _showPopupMenu(context);
                                        }, child: Icon(Icons.edit_outlined,size: 10,color: Colors.black87,)
                                    ),)])
                        ),
                      ),),]),
              SizedBox(width: 10),
            ],
            toolbarHeight: 75.0,
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(height: size.height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: size.width* 0.10,),
                  Text('Welcome',style: TextStyle(color: black,fontSize:18 ,fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
                  SizedBox(width: size.width * 0.01,),
                  Text('Nur Hafiza',style: TextStyle(color: griesh,fontFamily:'Inter',fontSize: 20,fontWeight: FontWeight.bold),)
                ],
              ),
              SizedBox(height: size.height * 0.015,),
              Row(
                children: [
                  SizedBox(width: size.width* 0.045,),
                  mobileInfoCard(context,'12/10/2024','Engineer', 'offshore'),
                ],
              ),
              SizedBox(height: size.height * 0.035,),
              Row(
                children: [
                  SizedBox(width: size.width * 0.08),
                  Text('OffShore',style: TextStyle(color: dashgrey,fontFamily: 'Inter',fontSize: 16,fontWeight: FontWeight.bold),)
                ],
              ),
              SizedBox(height: size.height * 0.015,),
              Row(
                children: [
                  SizedBox(width: size.width * 0.060),
                  Container(
                    width: size.width * 0.88,
                    height: size.height * 0.175,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300,width: 1),
                        borderRadius: BorderRadius.circular(7),
                        color: white
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.016,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.215),
                            Text('Total AL/SL/UA',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.040),
                            Text('Leave Taken',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.040),
                            Text('Remaining',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.040),
                            Text('Leave Request',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold),),
                          ],
                        ),
                        SizedBox(height: size.height * 0.012,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.065),
                            Text('Annual Leave',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.065),
                            Container(
                              width: size.width * 0.062,
                              height: size.height * 0.025,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300,width: 1),
                                color: Colors.white,
                              ),
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text('7',style: TextStyle(fontFamily: 'Inter',fontSize: 10,color: black,fontWeight: FontWeight.bold),)),
                            ),
                            SizedBox(width: size.width * 0.104),
                            mobileContainer(context, '4', 10),
                            SizedBox(width: size.width * 0.090),
                            mobileContainer(context, '3', 10),
                            SizedBox(width: size.width * 0.090),
                            mobileContainer(context, '1', 10),
                          ],
                        ),
                        SizedBox(height: size.height * 0.012,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.065),
                            Text('Sick Leave',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.090),
                            mobileContainer(context, '7', 10),
                            SizedBox(width: size.width * 0.104),
                            mobileContainer(context, '4', 10),
                            SizedBox(width: size.width * 0.090),
                            mobileContainer(context, '3', 10),
                            SizedBox(width: size.width * 0.090),
                            mobileContainer(context, '1', 10),
                          ],
                        ),
                        SizedBox(height: size.height * 0.013,),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.065),
                            Text('Unpaid Authorize',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 10,fontWeight: FontWeight.bold),),
                            SizedBox(width: size.width * 0.032),
                            mobileContainer(context, '', 10),

                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: size.height * 0.025,),
              Row(
                children: [
                  SizedBox(width: size.width * 0.075),
                  Text(
                    'My Recent Leave',
                    style: TextStyle(color: Colors.black, fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: size.width * 0.266),
                  Container(
                    width: size.width * 0.180,
                    height: size.height * 0.030,
                    color: Colors.white,
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: from,
                        style: TextStyle(
                          fontSize: 7.5, // Set a smaller font size for the picked date
                          color: Colors.black, // You can also control the color of the text
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 5, bottom: 6),
                          hintText: 'From',
                          hintStyle: TextStyle(fontSize: 11),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0.05),
                            onPressed: () => _selectDate(context, from), // Correct the onPressed
                            icon: Icon(
                              Icons.calendar_month,
                              size: 11,
                              color: Colors.black,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: grey, width: 1), // Keep border color grey
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.018),
                  Container(
                    width: size.width * 0.180,
                    height: size.height * 0.030,
                    color: Colors.white,
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        controller: to,
                        style: TextStyle(
                          fontSize: 7.5, // Set a smaller font size for the picked date
                          color: Colors.black, // You can also control the color of the text
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 5, bottom: 6),
                          hintText: 'To',
                          hintStyle: TextStyle(fontSize: 11),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0.05),
                            onPressed: () => _selectDate(context, to), // Correct the onPressed
                            icon: Icon(
                              Icons.calendar_month,
                              size: 11,
                              color: Colors.black,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: grey, width: 1), // Keep border color grey
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding:  EdgeInsets.only(left: size.width * 0.030,top: size.height * 0.02),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: filteredLeaveData.isNotEmpty
                          ? SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowHeight: filteredLeaveData.isEmpty ? 0 : size.height * 0.042,
                          dataRowHeight: size.height * 0.040,
                          columnSpacing: size.width * 0.026,
                          columns: [
                            DataColumn(label: Text('Leave Type', style: phoneheaderTextStyle)),
                            DataColumn(label: Text('From', style: phoneheaderTextStyle)),
                            DataColumn(label: Text('To', style: phoneheaderTextStyle)),
                            DataColumn(label: Text('Days', style: phoneheaderTextStyle)),
                            DataColumn(label: Text('Reason', style: phoneheaderTextStyle)),
                            DataColumn(label: Text('Approver', style: phoneheaderTextStyle)),
                            DataColumn(label: Text('Status', style: phoneheaderTextStyle)),
                          ],
                          rows: filteredLeaveData.map((leave) {
                            int index = filteredLeaveData.indexOf(leave);

                            return DataRow(
                              cells: [
                                DataCell(GestureDetector(
                                  onTap: () {
                                    if (leaveStatuses[index] == 'Pending') {
                                      _phonependingDialog(context, index, leave, (newStatus) {
                                        setState(() {
                                          leaveStatuses[index] = newStatus;
                                        });
                                      });
                                    } else if (leaveStatuses[index] == 'Approved') {
                                      _phoneapprovedDialog(context, index, leave);
                                    } else if (leaveStatuses[index] == 'Rejected') {
                                      _phonerejectedDialog(context, index, leave);
                                    }
                                  },

                                  child: Text(leave!.leaveType ?? '', style: phonerowTextStyle),
                                )),
                                DataCell(Text(
                                  leave.fromDate != null
                                      ? DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())
                                      : '',
                                  style: phonerowTextStyle,
                                )),
                                DataCell(Text(
                                  leave.toDate != null
                                      ? DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())
                                      : '',
                                  style: phonerowTextStyle,
                                )),
                                DataCell(Text('${leave.days ?? 0} days', style: phonerowTextStyle)),
                                DataCell(Text(leave.reason ?? '', style: phonerowTextStyle)),
                                DataCell(Text(leave.applyTo ?? '', style: phonerowTextStyle)),
                                DataCell(Text(leaveStatuses[index], style: phonerowTextStyle)),
                              ],
                            );
                          }).toList(),
                        ),
                      )
                          : SizedBox(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.025,),
              Row(
                children: [
                  SizedBox(width: size.width * 0.3,),
                  MaterialButton(
                    onPressed: (){
                      Get.to(()=>ApplyLeaveScreen());
                    },
                    minWidth: size.width * 0.075,
                    height: size.height * 0.055,
                    color: yellow,
                    child: Text('Apply Leave',style: TextStyle(fontFamily: 'Inter,',fontSize: 15,fontWeight: FontWeight.bold,color: black),),
                  ),
                  SizedBox(width: size.width * 0.015,),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Request Ticket",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none, // Remove default underline
                          ),
                        ),
                      ),
                      // Add space between text and line
                      Container(
                        height: 1,
                        color: blue, // Custom underline color
                        width: size.width * 0.065, // Set the underline width as needed
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        paddingWidth: size.width * 0.1,
        bgColor: bgColor);
  }
}

Widget newContainer(BuildContext context, TextEditingController controller,String text){
  final Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width * 0.24,
    height: size.height * 0.038, // Increase the height for better alignment
    child: Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 16), // Adjust font size if necessary
        decoration: InputDecoration(
          hintText: text,
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
    height: size.height * 0.038,
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

Widget employeeInfoCard(BuildContext context, String employeeType, String joiningDate, String contractType, String department, String location,double width, double height) {
  final Size size = MediaQuery.of(context).size;

  return
      Container(
      width: width,
        height: height,
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(5),
         border: Border.all(color: Colors.grey.shade300,width: 1),
         color: white
       ), // Custom color
        child: Column(
          children: [
            SizedBox(height: size.height * 0.015),
            Row(
              children: [
                SizedBox(width: size.width * 0.124),
                Text(
                  'Date of joining',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    color: Colors.black,

                  ),
                ),
                SizedBox(width: size.width * 0.085),
                Text(
                  'Department',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    color: Colors.black,

                  ),
                ),
                SizedBox(width: size.width * 0.074),
                Text(
                  'Location',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    color: Colors.black,

                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.010),
            Row(
              children: [
                SizedBox(width: size.width * 0.124),
                Text(
                  joiningDate,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.108),
                Text(
                  department,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.092),
                Text(
                  location,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Spacer(), // Pushes the line to the bottom
            Divider(
              color: Colors.yellow, // Yellow line color
              thickness: 3, // Thickness of the yellow line
              height: 0, // No spacing above or below the line
            ),
          ],
        ),
      );
}

Widget shoreContainer(BuildContext context, String text,double font){
  final Size size = MediaQuery.of(context).size;
  return  Container(
    width: size.width * 0.042,
    height: size.height * 0.035,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300,width: 1),
      color: Colors.white,
    ),
    child: Align(
        alignment: Alignment.center,
        child: Text(text,style: TextStyle(fontFamily: 'Inter',fontSize: font,color: black,fontWeight: FontWeight.bold),)),
  );
}

Widget tabemployeeInfoCard(BuildContext context, String employeeType, String joiningDate, String contractType, String department, String location,double width, double height) {
  final Size size = MediaQuery.of(context).size;

  return
      Container(
       width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.grey.shade300,width: 1),
          color: white
        ), // Custom color
        child: Column(
          children: [
            SizedBox(height: size.height * 0.015),
            Row(
              children: [
                SizedBox(width: size.width * 0.074),

                SizedBox(width: size.width * 0.055),
                Text(
                  'Date of joining',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.115),
                Text(
                  'Department',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.115),
                Text(
                  'Location',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.010),
            Row(
              children: [
                SizedBox(width: size.width * 0.130),
                Text(
                  joiningDate,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.125),
                Text(
                  department,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.127),
                Text(
                  location,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Spacer(), // Pushes the line to the bottom
            Divider(
              color: Colors.yellow, // Yellow line color
              thickness: 3, // Thickness of the yellow line
              height: 0, // No spacing above or below the line
            ),
          ],
        ),
      );
}


void _tabapprovedDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
  final Size size = MediaQuery.of(context).size;
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(8),
        width: size.width * 0.4,
        decoration: BoxDecoration(
          color: Color(0xFF1F1F1).withOpacity(1.0),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: size.height * 0.012),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: size.width * 0.165),
                Text(
                  'Approved',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 20,fontWeight: FontWeight.bold ,color: Colors.black),
                ),
                SizedBox(width: size.width * 0.090),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel_outlined, size: 24, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.016),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.075,),
                Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.058,),
                Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.073,),
                Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.057,),
                Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.042,),
                Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.016,),
                Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.059,),
                Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.043,),
                Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.062,),
                Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.020),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void _tabrejectedDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
  final Size size = MediaQuery.of(context).size;
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(8),
        width: size.width * 0.4,
        decoration: BoxDecoration(
            color: Color(0xFF1F1F1).withOpacity(1.0),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: size.height * 0.012),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: size.width * 0.165),
                Text(
                  'Rejected',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black),
                ),
                SizedBox(width: size.width * 0.090),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel_outlined, size: 24, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.014),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.074,),
                Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.056,),
                Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.070,),
                Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.055,),
                Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.040,),
                Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.016,),
                Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.058,),
                Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.041,),
                Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.062,),
                Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.022),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.060,),
                Text('Comments',style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
                SizedBox(width:size.width *  0.039,),
                Container(
                  width: size.width * 0.175,
                  height: size.height * 0.057,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: grey,width: 1)
                  ),
                  child: Text('  Rejected we have production \n   please planing leave latter',style: TextStyle(color: black,fontSize: 12,fontFamily: 'Inter'),),
                )
              ],
            ),
            SizedBox(height: size.height * 0.018),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

TextStyle tabheaderTextStyle = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.bold,
  fontSize: 13,
  color: Colors.black,
);

TextStyle tabrowTextStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  color: Colors.black,
);

Widget mobileInfoCard(BuildContext context, String joinindate, String department, String location){
  final Size size = MediaQuery.of(context).size;
  return  Container(
    width: size.width * 0.90,
    height: size.height * 0.093,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300,width: 1),
        color: Colors.white
    ),
    child: Column(
      children: [
        SizedBox(height: size.height * 0.015),
        Row(
          children: [
            SizedBox(width: size.width * 0.100),
            Text(
              'Date of joining',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.034),
       
            SizedBox(width: size.width * 0.100),
            Text(
              'Department',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: size.width * 0.130),
            Text(
              'Location',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.010),
        Row(
          children: [
            SizedBox(width: size.width * 0.108),
            Text(
              joinindate,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            SizedBox(width: size.width * 0.150),
            Text(
              department,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            SizedBox(width: size.width * 0.148),
            Text(
             location,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Spacer(), // Pushes the line to the bottom
        Divider(
          color: Colors.yellow, // Yellow line color
          thickness: 3, // Thickness of the yellow line
          height: 0, // No spacing above or below the line
        ),
      ],
    ),
  );
}

Widget mobileContainer(BuildContext context, String text,double font){
  final Size size = MediaQuery.of(context).size;
  return  Container(
    width: size.width * 0.062,
    height: size.height * 0.025,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300,width: 1),
      color: Colors.white,
    ),
    child: Align(
        alignment: Alignment.center,
        child: Text(text,style: TextStyle(fontFamily: 'Inter',fontSize: font,color: black,fontWeight: FontWeight.bold),)),
  );
}

void _phoneapprovedDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
  final Size size = MediaQuery.of(context).size;
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(8),
        width: size.width * 0.65,
        decoration: BoxDecoration(
          color: dialog,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: size.height * 0.012),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: size.width * 0.205),
                Text(
                  'Approved',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 18,fontWeight: FontWeight.bold ,color: Colors.black),
                ),
                SizedBox(width: size.width * 0.150),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel_outlined, size: 20, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.016),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.075,),
                Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.058,),
                Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.073,),
                Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.057,),
                Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.042,),
                Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.016,),
                Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.059,),
                Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.043,),
                Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.061,),
                Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.062,),
                Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.020),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void _phonerejectedDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
  final Size size = MediaQuery.of(context).size;
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(8),
        width: size.width * 0.65,
        decoration: BoxDecoration(
          color: dialog,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: size.height * 0.012),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: size.width * 0.240),
                Text(
                  'Rejected',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 18,fontWeight: FontWeight.bold ,color: Colors.black),
                ),
                SizedBox(width: size.width * 0.150),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel_outlined, size: 22, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.014),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Name',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.118,),
                Text('Rahul Kumar',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Job Title',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.087,),
                Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Badge',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.115,),
                Text('50598',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Dept/Div',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.090,),
                Text('5058',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Leave Type',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.063,),
                Text(leave.leaveType ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Selected Dates',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.017,),
                Text('${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Apply to',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.092,),
                Text(leave.applyTo ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('No of days',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.064,),
                Text('${leave.days ?? 0} days',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.014,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Reason',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.097,),
                Text(leave.reason ?? 'N/A',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
              ],
            ),
            SizedBox(height: size.height * 0.022),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width:size.width *  0.068,),
                Text('Comments',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),),
                SizedBox(width:size.width *  0.053,),
                Container(
                  width: size.width * 0.295,
                  height: size.height * 0.050,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: grey,width: 1)
                  ),
                  child: Text('  Rejected we have production \n   please planing leave latter',style: TextStyle(color: black,fontSize: 10,fontFamily: 'Inter'),),
                )
              ],
            ),
            SizedBox(height: size.height * 0.018),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

TextStyle phoneheaderTextStyle = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.bold,
  fontSize: 8,
  color: Colors.black,
);

TextStyle phonerowTextStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 8.5,
  color: Colors.black,
);