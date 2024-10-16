// class LeaveApplication {
//   String leaveType;
//   DateTime fromDate;
//   DateTime toDate;
//   int numberOfDays;
//   String applyTo; // This should be included
//   String reason;
//
//   LeaveApplication({
//     required this.leaveType,
//     required this.fromDate,
//     required this.toDate,
//     required this.numberOfDays,
//     required this.applyTo, // Include applyTo in the constructor
//     required this.reason,
//   });
//
//   // Add a method to convert to a map if needed for AWS
//   Map<String, dynamic> toMap() {
//     return {
//       'leaveType': leaveType,
//       'fromDate': fromDate.toIso8601String(),
//       'toDate': toDate.toIso8601String(),
//       'numberOfDays': numberOfDays,
//       'applyTo': applyTo,
//       'reason': reason,
//     };
//   }
// }


// Future<void> createLeaveRequest(
//     String empID,
//     TextEditingController fromController,
//     TextEditingController toController,
//     TextEditingController reasonController,
//     TextEditingController daysController,
//     bool isManager,
//     bool isSuperior,
//     ) async {
//   // Reset all error messages
//   setState(() {
//     leaveTypeError = null;
//     fromDateError = null;
//     toDateError = null;
//     applyToError = null;
//     ticketError = null;
//     reasonError = null;
//   });
//
//   // Validate fields
//   bool isValid = true;
//
//   if (_selectedLeaveType == null || _selectedLeaveType!.isEmpty) {
//     leaveTypeError = '* This field is required';
//     isValid = false;
//   }
//
//   if (fromController.text.isEmpty) {
//     fromDateError = '* This field is required';
//     isValid = false;
//   }
//
//   if (toController.text.isEmpty) {
//     toDateError = '* This field is required';
//     isValid = false;
//   }
//
//   if (!isManager && !isSuperior) {
//     applyToError = '* Please select either Manager or Superior.';
//     isValid = false;
//   }
//
//   if (reasonController.text.isEmpty) {
//     reasonError = '* This field is required';
//     isValid = false;
//   }
//
//   if (!isValid) {
//     setState(() {});
//     return;
//   }
//
//   DateTime? _fromDate = DateFormat('MM/dd/yyyy').parse(fromController.text);
//   DateTime? _toDate = DateFormat('MM/dd/yyyy').parse(toController.text);
//
//   if (_fromDate == null || _toDate == null) {
//     fromDateError = '* Invalid date format';
//     toDateError = '* Invalid date format';
//     setState(() {});
//     return;
//   }
//
//   double dayDifference = double.parse(daysController.text);
//
//   try {
//     final leaveStatus = LeaveStatus(
//       empID: empID,
//       leaveType: _selectedLeaveType!,
//       fromDate: TemporalDate(_fromDate),
//       toDate: TemporalDate(_toDate),
//       days: isHalfDay ? 0 : dayDifference.round(),
//       applyTo: isManager ? 'Manager' : 'Superior',
//       reason: reasonController.text,
//     );
//
//     // Save the leave request to Amplify DataStore
//     await Amplify.DataStore.save(leaveStatus);
//     print('Leave request created successfully: ${leaveStatus.toJson()}');
//   } catch (e) {
//     print('Failed to create leave request: $e');
//   }
// }


// Row(
// children: [
// SizedBox(width: size.width * 0.215,),
// Container(
// width: size.width * 0.45,
// height: size.height * 0.115,
// color:pink,
// child: Column(
// children: [
// SizedBox(height: size.height * 0.015,),
// Row(
// children: [
// SizedBox(width: size.width * 0.024,),
// Text('Employee Type',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
// SizedBox(width: size.width * 0.024,),
// Text('Date of joining',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
// SizedBox(width: size.width * 0.024,),
// Text('Contract Type',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
// SizedBox(width: size.width * 0.024,),
// Text('Department',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
// SizedBox(width: size.width * 0.024,),
// Text('Location',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black,fontWeight: FontWeight.bold),),
// ],
// ),
// SizedBox(height: size.height * 0.010,),
// Row(
// children: [
// SizedBox(width: size.width * 0.026,),
// Text('Trainer',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,),),
// SizedBox(width: size.width * 0.056,),
// Text('12/10/2024',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,),),
// SizedBox(width: size.width * 0.034,),
// Text('Permanent',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,),),
// SizedBox(width: size.width * 0.034,),
// Text('Engineer',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,),),
// SizedBox(width: size.width * 0.032,),
// Text('Offshore',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black,),),
// ],
// ),
//
// ],
// ),
// )
//
// ],
// ),
// SizedBox(height: size.height * 0.015,),
// // Row(
// //   children: [
// //     SizedBox(width: size.width * 0.175,),
// //     container2('Annual Leave', '9', purple, context),
// //     SizedBox(width: size.width * 0.04,),
// //     container2('Sick Leave', '8', purple, context),
// //     SizedBox(width: size.width * 0.04,),
// //     container2('Unpaid Authorize', '0.5', purple, context),
// //   ],
// // ),