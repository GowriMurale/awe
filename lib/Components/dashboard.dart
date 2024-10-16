
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_core/amplify_core.dart';
import 'package:awe_project/Screens/apply_leave_screen.dart';
import 'package:awe_project/Screens/leave_view_screen.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../models/LeaveStatus.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return DesktopDashboard();
        } else if (constraints.maxWidth >= 800 && constraints.maxWidth < 1200) {
          return TabletDashboard();
        } else {
          return  MobileDashboard();
        }
      },
    );
  }
}

class DesktopDashboard extends StatefulWidget {
  const DesktopDashboard({super.key});

  @override
  State<DesktopDashboard> createState() => _DesktopDashboardState();
}

class _DesktopDashboardState extends State<DesktopDashboard> {

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

  void filterLeaveData() {
    if (from.text.isEmpty && to.text.isEmpty) {
      // If no dates are selected, show all data
      setState(() {
        filteredLeaveData = allLeaveData;
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

      // Convert TemporalDate to DateTime using the 'getDateTime()' method
      final leaveFromDate = leave.fromDate!.getDateTime(); // Convert TemporalDate to DateTime
      final leaveToDate = leave.toDate!.getDateTime();     // Convert TemporalDate to DateTime

      bool afterFrom = fromDate != null
          ? leaveFromDate.isAfter(fromDate!) || leaveFromDate.isAtSameMomentAs(fromDate!)
          : true;
      bool beforeTo = toDate != null
          ? leaveToDate.isBefore(toDate!) || leaveToDate.isAtSameMomentAs(toDate!)
          : true;

      return afterFrom && beforeTo;
    }).toList();

    setState(() {
      filteredLeaveData = tempFiltered;
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

  void _showCancelDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
    final Size size = MediaQuery.of(context).size;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          width: size.width * 0.300,
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
                  SizedBox(width: size.width * 0.085),
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


  /// Helper function to build a detail row in the dialog
    Widget _buildDetailRow(String title, String value, Size size) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: size.width * 0.050), // Left padding
          SizedBox(
            width: size.width * 0.2, // Adjust title width
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.030), // Spacing between title and value
          Expanded( // Allow text to wrap if necessary
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    }




    @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
     return
    // Row(
    //   children: [
    // // Sidebar container
    // Container(
    //   width: size.width * 0.150, // Adjust width as necessary
    //   height:size.height* 0.900, // Sidebar takes full height
    //   color: grey, // Background color for sidebar
    //   child: Column(
    //     children: [
    //       SizedBox(height: size.height * 0.20),
    //       GestureDetector(
    //         onTap: (){
    //           Get.to(ApplyLeaveScreen());
    //         },
    //         child: Container(
    //           width: size.width * 0.125,
    //           height:size.height* 0.048,
    //           decoration: BoxDecoration(
    //             color: Colors.yellowAccent,
    //             borderRadius: BorderRadius.circular(10),
    //           ),
    //           child: Row(
    //             children: [
    //               SizedBox(width: size.width * 0.02,),
    //             SizedBox(
    //               height: 18,
    //               width: 22,
    //               child: Image.asset('assets/images/leave.png',color: Colors.black,),
    //             ),
    //               SizedBox(width: size.width * 0.01,),
    //               Text('Leaves',style: TextStyle(fontSize: 18,fontFamily: 'Inter', color:Colors.black),),
    //             ],
    //           ),
    //         ),
    //       ),
    //       SizedBox(height: size.height * 0.05),
    //       // Add more widgets here as per your sidebar content
    //     ],
    //   ),
    // ),
    // return
      Column(
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
              Text('Welcome',style: TextStyle(color: black,fontSize:26 ,fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
              SizedBox(width: size.width * 0.01,),
              Text('Nur Hafiza',style: TextStyle(color: griesh,fontFamily:'Inter',fontSize: 28,fontWeight: FontWeight.bold),)
            ],
          ),
          SizedBox(height: size.height * 0.015,),
          employeeInfoCard(
            context,
            'Trainer',          // Employee Type
            '12/10/2024',       // Date of Joining
            'Permanent',        // Contract Type
            'Engineer',         // Department
            'Offshore',         // Location
          ),
          SizedBox(height: size.height * 0.185,),
            Row(
              children: [
              SizedBox(width: size.width * 0.185),
                Text(
                    'My Recent Leave',
                      style: TextStyle(color: Colors.black, fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                SizedBox(width: size.width * 0.286),
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
                padding:  EdgeInsets.only(left: size.width * 0.175,top: size.height * 0.02),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          // border: TableBorder.all(color: grey),
                          headingRowHeight: size.height * 0.050,
                          dataRowHeight: size.height * 0.055,
                          columnSpacing: size.width * 0.040,
                          columns: [
                            DataColumn(label: Text('Leave Type', style: headerTextStyle)),
                            DataColumn(label: Text('From', style: headerTextStyle)),
                            DataColumn(label: Text('To', style: headerTextStyle)),
                            DataColumn(label: Text('Days', style: headerTextStyle)),
                            DataColumn(label: Text('Reason', style: headerTextStyle)),
                            DataColumn(label: Text('Approver', style: headerTextStyle)),
                            DataColumn(label: Text('Status', style: headerTextStyle)),
                          ],
                          rows: filteredLeaveData
                              .where((leave) => leave != null) // Filter out null values
                              .map((leave) {
                            return DataRow(
                              cells: [
                                DataCell(GestureDetector(
                                  onDoubleTap: () {
                                    _showCancelDialog(context, filteredLeaveData.indexOf(leave), leave!);
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
                                DataCell(Text('Pending', style: rowTextStyle)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
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
          )
        ],
    );


  }
}

class TabletDashboard extends StatefulWidget {
  const TabletDashboard({super.key});


  @override
  State<TabletDashboard> createState() => _TabletDashboardState();
}

class _TabletDashboardState extends State<TabletDashboard> {

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

  void filterLeaveData() {
    if (from.text.isEmpty && to.text.isEmpty) {
      // If no dates are selected, show all data
      setState(() {
        filteredLeaveData = allLeaveData;
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

      // Convert TemporalDate to DateTime using the 'getDateTime()' method
      final leaveFromDate = leave.fromDate!.getDateTime(); // Convert TemporalDate to DateTime
      final leaveToDate = leave.toDate!.getDateTime();     // Convert TemporalDate to DateTime

      bool afterFrom = fromDate != null
          ? leaveFromDate.isAfter(fromDate!) || leaveFromDate.isAtSameMomentAs(fromDate!)
          : true;
      bool beforeTo = toDate != null
          ? leaveToDate.isBefore(toDate!) || leaveToDate.isAtSameMomentAs(toDate!)
          : true;

      return afterFrom && beforeTo;
    }).toList();

    setState(() {
      filteredLeaveData = tempFiltered;
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

  void _showCancelDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
    final Size size = MediaQuery.of(context).size;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          width: size.width * 0.300,
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
                  SizedBox(width: size.width * 0.085),
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
    return Column(
      children: [
        SizedBox(height: size.height * 0.01,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: size.width* 0.12,),
            // IconButton(onPressed: (){
            //   Get.back();
            // }, icon: Icon(Icons.arrow_back,size: 20,color: Colors.black,)),
            // SizedBox(width: size.width* 0.14,),
            Text('Welcome',style: TextStyle(color: black,fontSize:26 ,fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
            SizedBox(width: size.width * 0.01,),
            Text('Nur Hafiza',style: TextStyle(color: griesh,fontFamily:'Inter',fontSize: 28,fontWeight: FontWeight.bold),)
          ],
        ),
        SizedBox(height: size.height * 0.015,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
           tabemployeeInfoCard(
              context,
              'Trainer',          // Employee Type
              '12/10/2024',       // Date of Joining
              'Permanent',        // Contract Type
              'Engineer',         // Department
              'Offshore',         // Location
            ),
          ],
        ),
        SizedBox(height: size.height * 0.185,),
        Row(
          children: [
            SizedBox(width: size.width * 0.145),
            Text(
              'My Recent Leave',
              style: TextStyle(color: Colors.black, fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: size.width * 0.286),
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
              padding:  EdgeInsets.only(left: size.width * 0.145,top: size.height * 0.02),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        // border: TableBorder.all(color: grey),
                        headingRowHeight: size.height * 0.050,
                        dataRowHeight: size.height * 0.055,
                        columnSpacing: size.width * 0.040,
                        columns: [
                          DataColumn(label: Text('Leave Type', style: headerTextStyle)),
                          DataColumn(label: Text('From', style: headerTextStyle)),
                          DataColumn(label: Text('To', style: headerTextStyle)),
                          DataColumn(label: Text('Days', style: headerTextStyle)),
                          DataColumn(label: Text('Reason', style: headerTextStyle)),
                          DataColumn(label: Text('Approver', style: headerTextStyle)),
                          DataColumn(label: Text('Status', style: headerTextStyle)),
                        ],
                        rows: filteredLeaveData
                            .where((leave) => leave != null) // Filter out null values
                            .map((leave) {
                          return DataRow(
                            cells: [
                              DataCell(GestureDetector(
                                onDoubleTap: () {
                                  _showCancelDialog(context, filteredLeaveData.indexOf(leave), leave!);
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
                              DataCell(Text('Pending', style: rowTextStyle)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
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
        )
      ],
    );
  }
}


class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

      ],
    );
  }
}


Widget container1(Color color,String text,IconData icon,double width){
  return Container(
    width: width,
    height: 40,
    color: color,
    child: Row(
      children: [
        SizedBox(width: 15,),
        Icon(icon,size: 14,color: grey,),
        SizedBox(width: 15,),
        Text(text,style: TextStyle(fontFamily: 'Inter',fontSize: 14,color: black),),
      ],
    ),
  );
}

Widget container2(String text,String no, Color color,BuildContext context ){
  final Size size = MediaQuery.of(context).size;
  return Card(
    elevation: 2,
    child: Container(
      width: size.width * 0.105,
      height:size.height *  0.102,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
              color: Colors.grey.shade400,
              width: 1
          )
      ),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.007,),
          Text(text,style: TextStyle(color: color,fontFamily: 'Inter',fontSize: 18,fontWeight: FontWeight.bold),),
          SizedBox(height: size.height * 0.003),
          Text(no,style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 21,fontWeight: FontWeight.bold),)
        ],
      ),
    ),
  );
}

Widget tabcontainer2(String text,String no, Color color,BuildContext context ){
  final Size size = MediaQuery.of(context).size;
  return Card(
    elevation: 2,
    child: Container(
      width: size.width * 0.143,
      height: size.height * 0.115,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          border: Border.all(
              color: Colors.grey.shade400,
              width: 1
          )
      ),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.015,),
          Text(text,style: TextStyle(color: color,fontFamily: 'Inter',fontSize: 18,fontWeight: FontWeight.bold),),
          SizedBox(height: size.height * 0.005),
          Text(no,style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 20,fontWeight: FontWeight.bold),)
        ],
      ),
    ),
  );
}

// class EmployeeTable1 extends StatefulWidget {
//   @override
//   _EmployeeTable1State createState() => _EmployeeTable1State();
// }
//
// class _EmployeeTable1State extends State<EmployeeTable1> {
//   final ScrollController _scrollController = ScrollController();
//   List<Leave> leaveList = []; // Define a list to hold leave data
//
//   @override
//   void initState() {
//     super.initState();
//     fetchLeaveApplications(); // Fetch leave data when the widget initializes
//   }
//
//   Future<void> fetchLeaveApplications() async {
//     try {
//       // Replace with your actual method to fetch leaves from AWS
//       List<Leave> fetchedLeaves = await getLeavesFromAWS();
//       setState(() {
//         leaveList = fetchedLeaves; // Update the leaveList state
//       });
//     } catch (e) {
//       print("Error fetching leave applications: $e");
//     }
//   }
//
//   // Future<List<Leave>> getLeavesFromAWS() async {
//   //   // Implement your logic to fetch leave data from AWS
//   //   final dynamoDb = DynamoDB(region: 'us-east-1'); // Specify your region
//   //
//   //   // Assuming you have a table called 'LeaveApplications'
//   //   final response = await dynamoDb.scan(table: 'LeaveApplications');
//   //
//   //   List<Leave> leaves = [];
//   //
//   //   for (var item in response.items) {
//   //     leaves.add(Leave.fromMap(item)); // Convert the item to Leave object
//   //   }
//   //
//   //   return leaves;
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//
//     // Define the text style for the header row
//     TextStyle headerTextStyle = TextStyle(
//       fontFamily: 'Inter',
//       fontWeight: FontWeight.bold, // Bold font for header
//       fontSize: 14,
//       color: Colors.black,
//     );
//
//     // Define the text style for the data rows
//     TextStyle rowTextStyle = TextStyle(
//       fontFamily: 'Inter',
//       fontSize: 13,
//       color: Colors.black,
//     );
//
//     return Container(
//       color: Colors.white, // Set the background color to white
//       child: Column(
//         children: [
//           SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: DataTable(
//               headingRowHeight: size.height * 0.050,
//               dataRowHeight: size.height * 0.055,
//               columnSpacing: size.width * 0.040,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: Colors.grey, width: 1), // Outline border for the table
//                 borderRadius: BorderRadius.circular(10), // Rounded corners for the table
//               ),
//               columns: [
//                 DataColumn(label: Text('Leave Type', style: headerTextStyle)),
//                 DataColumn(label: Text('From', style: headerTextStyle)),
//                 DataColumn(label: Text('To', style: headerTextStyle)),
//                 DataColumn(label: Text('Days', style: headerTextStyle)),
//                 DataColumn(label: Text('Reason', style: headerTextStyle)),
//                 DataColumn(label: Text('Approver', style: headerTextStyle)),
//                 DataColumn(label: Text('Status', style: headerTextStyle)),
//               ],
//               rows: leaveList.map((leave) {
//                 return DataRow(cells: [
//                   DataCell(Text(leave.leaveType, style: rowTextStyle)),
//                   DataCell(Text('${leave.fromDate.toLocal()}'.split(' ')[0], style: rowTextStyle)),
//                   DataCell(Text('${leave.toDate.toLocal()}'.split(' ')[0], style: rowTextStyle)),
//                   DataCell(Text(leave.days.toString(), style: rowTextStyle)),
//                   DataCell(Text(leave.reason, style: rowTextStyle)),
//                   DataCell(Text(leave.approver, style: rowTextStyle)),
//                   DataCell(Text(leave.status, style: rowTextStyle)),
//                 ]);
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Define your Leave class


class TabEmployeeTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Define the text style for the header row
    TextStyle headerTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold, // Bold font for header
      fontSize: 13,
      color: Colors.black,
    );

    // Define the text style for the data rows
    TextStyle rowTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      color: Colors.black,
    );

    // Create a list of data rows for demonstration
    List<DataRow> rows = List<DataRow>.generate(
      4, // Example number of rows, dynamically adjust based on your data
          (index) => DataRow(
        cells: [
          DataCell(Text('Casual', style: rowTextStyle)),
          DataCell(Text('10/06/2024', style: rowTextStyle)),
          DataCell(Text('12/06/2024', style: rowTextStyle)),
          DataCell(Text('2', style: rowTextStyle)),
          DataCell(Text('Traveling to Village', style: rowTextStyle)),
          DataCell(Text('Hassan Ali', style: rowTextStyle)),
          DataCell(Text(index % 2 == 0 ? 'Pending' : 'Approved', style: rowTextStyle)),
        ],
      ),
    );

    return Container(
      color: Colors.white, // Set the background color to white
      child: Column(
        children: [
          // Static header (remains in view while scrolling)
          // DataTable(
          //   headingRowHeight: 42,
          //   columnSpacing: 45,
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     border: Border.all(color: Colors.grey, width: 1), // Outline border for the table
          //     borderRadius: BorderRadius.circular(10), // Rounded corners for the table
          //   ),
          //
          //   rows: [], // Empty rows for the fixed header
          // ),
          // Fixed height for 4 rows + scrollable area
          SizedBox(
            height: 4 * 47.0, // 4 rows * row height (47.0)
            child: Container(
              // decoration: BoxDecoration(
              //   border: Border(
              //     top: BorderSide(color: Colors.grey, width: 1),  // Top border
              //     bottom: BorderSide(color: Colors.grey, width: 1),
              //   ),
              // ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowHeight: size.height * 0.053, // Remove header inside the scrollable table
                  dataRowHeight: size.height *  0.052,
                  columnSpacing: size.width * 0.044,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1), // Outline border for the table
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the table
                  ),
                  columns: [
                    DataColumn(label: Text('Leave Type', style: headerTextStyle)),
                    DataColumn(label: Text('From', style: headerTextStyle)),
                    DataColumn(label: Text('To', style: headerTextStyle)),
                    DataColumn(label: Text('Days', style: headerTextStyle)),
                    DataColumn(label: Text('Reason', style: headerTextStyle)),
                    DataColumn(label: Text('Approved', style: headerTextStyle)),
                    DataColumn(label: Text('Status', style: headerTextStyle)),
                  ],
                  rows: rows, // Scrollable data rows
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}







Container container3(Color color, String text, String name){
  return Container(
    child: Row(
      children: [
        SizedBox(width: 15,),
        CircleAvatar(
          radius: 17,
          backgroundColor: color,
          child: Text(text),
        ),
        SizedBox(width: 15,),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 35),
              child: Text(name,style: TextStyle(fontSize: 14,color: Colors.black,fontFamily: 'Inter'),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Text('April 20- Happy birthday',style: TextStyle(fontSize: 8,color: black,fontFamily: 'Inter'),),
            )
          ],
        )
      ],
    ),
  );
}

Widget dashContainer(BuildContext context,Color color,String text,IconData icon){
  final Size size = MediaQuery.of(context).size;
  return   Container(
    width: size.width * 0.125,
    height:size.height* 0.050,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        SizedBox(width: size.width * 0.02,),
        Icon(Icons.person_outline,size: 18,color: Colors.white,),
        SizedBox(width: size.width * 0.01,),
        Text('Leaves',style: TextStyle(fontSize: 18,fontFamily: 'Inter', color: Colors.white),),
      ],
    ),
  );
}

Widget employeeInfoCard(BuildContext context, String employeeType, String joiningDate, String contractType, String department, String location) {
  final Size size = MediaQuery.of(context).size;

  return Row(
    children: [
      SizedBox(width: size.width * 0.215),
      Container(
        width: size.width * 0.45,
        height: size.height * 0.115,
        color: pink, // Custom color
        child: Column(
          children: [
            SizedBox(height: size.height * 0.015),
            Row(
              children: [
                SizedBox(width: size.width * 0.024),
                Text(
                  'Employee Type',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
                Text(
                  'Date of joining',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
                Text(
                  'Contract Type',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
                Text(
                  'Department',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
                Text(
                  'Location',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.010),
            Row(
              children: [
                SizedBox(width: size.width * 0.026),
                Text(
                  employeeType,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.056),
                Text(
                  joiningDate,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.034),
                Text(
                  contractType,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.034),
                Text(
                  department,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.032),
                Text(
                  location,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}



Widget tabemployeeInfoCard(BuildContext context, String employeeType, String joiningDate, String contractType, String department, String location) {
  final Size size = MediaQuery.of(context).size;

  return Row(
    children: [
      SizedBox(width: size.width * 0.215),
      Container(
        width: size.width * 0.515,
        height: size.height * 0.110,
        color: pink, // Custom color
        child: Column(
          children: [
            SizedBox(height: size.height * 0.015),
            Row(
              children: [
                SizedBox(width: size.width * 0.024),
                Text(
                  'Employee Type',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
                Text(
                  'Date of joining',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
                Text(
                  'Contract Type',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
                Text(
                  'Department',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: size.width * 0.024),
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
                SizedBox(width: size.width * 0.026),
                Text(
                  employeeType,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.056),
                Text(
                  joiningDate,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.034),
                Text(
                  contractType,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.034),
                Text(
                  department,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: size.width * 0.032),
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
          ],
        ),
      ),
    ],
  );
}



class EmployeeTable extends StatefulWidget {
  @override
  _EmployeeTableState createState() => _EmployeeTableState();
}

class _EmployeeTableState extends State<EmployeeTable> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController from = TextEditingController();
  TextEditingController to = TextEditingController();

  // All leave data fetched from AWS Amplify
  List<LeaveStatus?> allLeaveData = [];

  // Filtered leave data based on date range
  List<LeaveStatus?> filteredLeaveData = [];

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

  /// Function to select a date using showDatePicker


  /// Fetch leave data from AWS Amplify GraphQL
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

  /// Filter leave data based on selected date range
  void filterLeaveData() {
    if (from.text.isEmpty && to.text.isEmpty) {
      // If no dates are selected, show all data
      setState(() {
        filteredLeaveData = allLeaveData;
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

      final leaveFromDate = DateTime.parse(leave.fromDate! as String);
      final leaveToDate = DateTime.parse(leave.toDate! as String);

      bool afterFrom = fromDate != null
          ? leaveFromDate.isAfter(fromDate!) || leaveFromDate.isAtSameMomentAs(fromDate!)
          : true;
      bool beforeTo = toDate != null
          ? leaveToDate.isBefore(toDate!) || leaveToDate.isAtSameMomentAs(toDate!)
          : true;

      return afterFrom && beforeTo;
    }).toList();

    setState(() {
      filteredLeaveData = tempFiltered;
    });
  }

  /// Delete a leave request from AWS DynamoDB
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

  /// Show a detailed cancel dialog for a specific leave
  void _showCancelDialog(BuildContext context, int rowIndex, LeaveStatus leave) {
    final Size size = MediaQuery.of(context).size;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          padding: EdgeInsets.all(8),
          width: size.width * 0.300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: SingleChildScrollView( // To handle overflow
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
                    SizedBox(width: size.width * 0.085),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.cancel_outlined, size: 22, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.014),
                _buildDetailRow('Name', 'Rahul kumar', size),
                _buildDetailRow('Job Title', 'Traine', size),
                _buildDetailRow('Badge', '505958', size),
                _buildDetailRow('Dept/Div', 'Engineer', size),
                _buildDetailRow('Leave Type', leave.leaveType ?? 'N/A', size),
                _buildDetailRow(
                  'Select Date',
                  '${DateFormat('dd/MM/yyyy').format(DateTime.parse(leave.fromDate! as String))} to ${DateFormat('dd/MM/yyyy').format(DateTime.parse(leave.toDate! as String))}',
                  size,
                ),
                _buildDetailRow('Apply to', leave.applyTo ?? 'N/A', size),
                _buildDetailRow('No of days', '${leave.days ?? 0} days', size),
                _buildDetailRow('Reason', leave.reason ?? 'N/A', size),
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
                SizedBox(height: size.height * 0.014,),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Helper function to build a detail row in the dialog
  Widget _buildDetailRow(String title, String value, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: size.width * 0.050), // Left padding
        SizedBox(
          width: size.width * 0.2, // Adjust title width
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(width: size.width * 0.030), // Spacing between title and value
        Expanded( // Allow text to wrap if necessary
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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

    return Column(
      children: [
        // Date Pickers Row

        SizedBox(height: size.height * 0.02),
        // Employee Table
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowHeight: size.height * 0.050,
            dataRowHeight: size.height * 0.055,
            columnSpacing: size.width * 0.040,
            columns: [
              DataColumn(label: Text('Leave Type', style: headerTextStyle)),
              DataColumn(label: Text('From', style: headerTextStyle)),
              DataColumn(label: Text('To', style: headerTextStyle)),
              DataColumn(label: Text('Days', style: headerTextStyle)),
              DataColumn(label: Text('Reason', style: headerTextStyle)),
              DataColumn(label: Text('Approver', style: headerTextStyle)),
              DataColumn(label: Text('Status', style: headerTextStyle)),
            ],
            rows: filteredLeaveData
                .where((leave) => leave != null) // Filter out null values
                .map((leave) {
              return DataRow(
                cells: [
                  DataCell(GestureDetector(
                    onDoubleTap: () {
                      _showCancelDialog(context, filteredLeaveData.indexOf(leave), leave!);
                    },
                    child: Text(leave!.leaveType ?? '', style: rowTextStyle),
                  )),
                  DataCell(Text(
                    leave!.fromDate != null
                        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(leave.fromDate! as String))
                        : '',
                    style: rowTextStyle,
                  )),
                  DataCell(Text(
                    leave.toDate != null
                        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(leave.toDate! as String))
                        : '',
                    style: rowTextStyle,
                  )),
                  DataCell(Text('${leave.days ?? 0} days', style: rowTextStyle)),
                  DataCell(Text(leave.reason ?? '', style: rowTextStyle)),
                  DataCell(Text(leave.applyTo ?? '', style: rowTextStyle)),
                  DataCell(Text('Pending', style: rowTextStyle)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}



// _buildDetailRow('Name', "Rahul Kumar", size),
// _buildDetailRow('Job Title', "Trainer", size),
// _buildDetailRow('Badge', "50598", size),
// _buildDetailRow('Dept/Div', "50598", size),
// _buildDetailRow('Leave Type', leave['Leave Type']!, size),
// _buildDetailRow('Select Date', '${leave['From']} to ${leave['To']}', size),
// _buildDetailRow('No of Days', '${leave['Days']} days', size),
// _buildDetailRow('Reason', leave['Reason']!, size),
// _buildDetailRow('Approver', leave['Approver']!, size),

// _buildDetailRow('Leave Type', leave.leaveType, size),
// _buildDetailRow('Select Date', '${leave.fromDate.format()} to ${leave.toDate.format()}', size),
// _buildDetailRow('Apply to', leave.applyTo, size),
// _buildDetailRow('No of days', '${leave.days} days', size),
// _buildDetailRow('Reason', leave.reason, size),
// SizedBox(height: size.height * 0.022),

// _buildDetailRow('Leave Type', leave.leaveType ?? 'N/A', size),
//
// // Updated date display logic
// _buildDetailRow(
// 'Select Date',
// '${DateFormat('dd/MM/yyyy').format(leave.fromDate!.getDateTime())} to ${DateFormat('dd/MM/yyyy').format(leave.toDate!.getDateTime())}',
// size,
// ),
// _buildDetailRow('Apply to', leave.applyTo ?? 'N/A', size),
// _buildDetailRow('No of days', '${leave.days ?? 0} days', size),
// _buildDetailRow('Reason', leave.reason ?? 'N/A', size),