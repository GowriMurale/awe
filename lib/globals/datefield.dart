import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;
  final Function(BuildContext context) onTap;

  const DateField({
    Key? key,
    required this.controller,
    this.errorMessage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error message
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4), // Adjust padding below error message
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12), // Error text styling
            ),
          ),
        Container(
          width: size.width * 0.125, // Adjust width for better layout
          height: size.height * 0.038,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1),
            borderRadius: BorderRadius.circular(1),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text.isEmpty ? 'dd/mm/yyyy' : controller.text, // Display placeholder or entered date
                  style: TextStyle(
                    color: controller.text.isEmpty ? Colors.grey.shade500 : Colors.black,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () => onTap(context), // Trigger the date picker on tap
                  child: Padding(
                    padding:  EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade700,
                      size: 16,
                    ),
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



class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorMessage;
  final Function(BuildContext context) onTap;

  const PhoneField({
    Key? key,
    required this.controller,
    this.errorMessage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error message
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4), // Adjust padding below error message
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12), // Error text styling
            ),
          ),
        Container(
          width: size.width * 0.210, // Adjust width for better layout
          height: size.height * 0.030,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400, width: 1),
            borderRadius: BorderRadius.circular(1),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text.isEmpty ? 'dd/mm/yyyy' : controller.text, // Display placeholder or entered date
                  style: TextStyle(
                    color: controller.text.isEmpty ? Colors.grey.shade500 : Colors.black,
                    fontFamily: 'Inter',
                    fontSize: 10,
                  ),
                ),
                GestureDetector(
                  onTap: () => onTap(context), // Trigger the date picker on tap
                  child: Padding(
                    padding:  EdgeInsets.only(right: 3),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade700,
                      size: 12,
                    ),
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


// Future<void> applyForLeave() async {
//   if (_selectedLeaveType == null || from.text.isEmpty || to.text.isEmpty || days.text.isEmpty || reason.text.isEmpty) {
//     // Handle validation errors
//     return;
//   }
//
//   // Determine the 'applyTo' value based on isManager
//   final applyTo = isManager ? 'Manager' : 'Superior';
//
//   final leaveApplication = LeaveApplication(
//     leaveType: _selectedLeaveType!,
//     fromDate: DateTime.parse(from.text),
//     toDate: DateTime.parse(to.text),
//     numberOfDays: int.parse(days.text),
//     applyTo: applyTo, // Add the applyTo value
//     reason: reason.text,
//   );
//
//   try {
//     // Save the leave application to AWS
//     await saveToAWS(leaveApplication);
//     // Navigate or show success message
//   } catch (e) {
//     // Handle errors
//     print('Error applying for leave: $e');
//   }
// }
//
// Future<void> saveToAWS(LeaveApplication leaveApplication) async {
//   try {
//     // Pass the leaveApplication instance directly
//     // await Amplify.DataStore.save(leaveApplication);
//   } catch (e) {
//     // Handle save error
//     print('Error saving to AWS: $e');
//   }
// }

