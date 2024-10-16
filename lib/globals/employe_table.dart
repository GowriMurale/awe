import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployeeTable extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Define the text style for the header row
    TextStyle headerTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold, // Bold font for header
      fontSize: 14,
      color: Colors.black,
    );

    // Define the text style for the data rows
    TextStyle rowTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      color: Colors.black,
    );

    // Create a list of data rows for demonstration


    return Container(
      color: Colors.white, // Set the background color to white
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowHeight: size.height * 0.050, // Remove header inside the scrollable table
              dataRowHeight: size.height * 0.055,
              columnSpacing: size.width * 0.040,
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
                DataColumn(label: Text('Approver', style: headerTextStyle)),
                DataColumn(label: Text('Status', style: headerTextStyle)),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text('Casual', style: rowTextStyle)),
                  DataCell(Text('10/06/2024', style: rowTextStyle)),
                  DataCell(Text('12/06/2024', style: rowTextStyle)),
                  DataCell(Text('2', style: rowTextStyle)),
                  DataCell(Text('Traveling to Village', style: rowTextStyle)),
                  DataCell(Text('Hassan Ali', style: rowTextStyle)),
                  DataCell(Text('Pending', style: rowTextStyle)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Sick', style: rowTextStyle)),
                  DataCell(Text('09/06/2024', style: rowTextStyle)),
                  DataCell(Text('11/06/2024', style: rowTextStyle)),
                  DataCell(Text('3', style: rowTextStyle)),
                  DataCell(Text('Fever', style: rowTextStyle)),
                  DataCell(Text('Muneeb Khan', style: rowTextStyle)),
                  DataCell(Text('Approved', style: rowTextStyle)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Casual', style: rowTextStyle)),
                  DataCell(Text('08/06/2024', style: rowTextStyle)),
                  DataCell(Text('10/06/2024', style: rowTextStyle)),
                  DataCell(Text('2', style: rowTextStyle)),
                  DataCell(Text('Wedding', style: rowTextStyle)),
                  DataCell(Text('Ahmed Raza', style: rowTextStyle)),
                  DataCell(Text('Approved', style: rowTextStyle)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Sick', style: rowTextStyle)),
                  DataCell(Text('09/06/2024', style: rowTextStyle)),
                  DataCell(Text('11/06/2024', style: rowTextStyle)),
                  DataCell(Text('3', style: rowTextStyle)),
                  DataCell(Text('Fever', style: rowTextStyle)),
                  DataCell(Text('Muneeb Khan', style: rowTextStyle)),
                  DataCell(Text('Approved', style: rowTextStyle)),
                ]),
              ], // Scrollable data rows
            ),
          ),
        ],
      ),
    );
  }
}


 // Adjust this based on the AWS SDK you are using

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
//   // Future<void> fetchLeaveApplications() async {
//   //   try {
//   //     List<Leave> fetchedLeaves = await getLeavesFromAWS();
//   //     setState(() {
//   //       leaveList = fetchedLeaves; // Update the leaveList state
//   //     });
//   //   } catch (e) {
//   //     print("Error fetching leave applications: $e");
//   //   }
//   // }
//
//   // Future<List<Leave>> getLeavesFromAWS() async {
//   //   final client = AwsClient(
//   //     accessKey: '<YOUR_ACCESS_KEY>',
//   //     secretKey: '<YOUR_SECRET_KEY>',
//   //     region: '<YOUR_REGION>',
//   //   );
//   //
//   //   final response = await client.dynamoDb.scan(
//   //     table: 'LeaveApplications',
//   //   );
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
// class Leave {
//   final String leaveType;
//   final DateTime fromDate;
//   final DateTime toDate;
//   final int days;
//   final String reason;
//   final String approver;
//   final String status;
//
//   Leave({
//     required this.leaveType,
//     required this.fromDate,
//     required this.toDate,
//     required this.days,
//     required this.reason,
//     required this.approver,
//     required this.status,
//   });
//
//   factory Leave.fromMap(Map<String, dynamic> data) {
//     return Leave(
//       leaveType: data['leaveType'] as String,
//       fromDate: DateTime.parse(data['fromDate'] as String),
//       toDate: DateTime.parse(data['toDate'] as String),
//       days: data['days'] as int,
//       reason: data['reason'] as String,
//       approver: data['approver'] as String,
//       status: data['status'] as String,
//     );
//   }
// }
