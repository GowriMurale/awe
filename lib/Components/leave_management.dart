import 'package:awe_project/Components/dashboard.dart';
import 'package:flutter/material.dart';

import '../globals/my_colors.dart';
class ManagementView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopManagement();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return DesktopManagement();
        } else {
          return MobileManagement();
        }
      },
    );
  }
}

class DesktopManagement extends StatelessWidget {
  const DesktopManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 180,),
                IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_outlined,size: 25,color: black,)),
                SizedBox(width: 350,),
                Text('Leave  Management',style: TextStyle(color: black,fontSize:32,fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
              ],
            ),
          ),
          SizedBox(height: 25,),
          Row(
            children: [
              SizedBox(width: 330,),
                container2(Icons.eighteen_mp_sharp, 'Apply for Leave'),
              SizedBox(width: 120,),
              container2(Icons.eighteen_mp_sharp, 'Review Leave Balance'),
              SizedBox(width: 120,),
              container2(Icons.eighteen_mp_sharp, 'Leave History'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 330,top: 40),
            child: Row(
              children: [
                Text('My Recent Leave',style: TextStyle(color: black,fontFamily: 'Inter',fontSize: 20),),
              ],
            ),
          ),
          Row(
            children: [
                Padding(
                  padding: const EdgeInsets.only(left: 310,top: 18),
                  child: EmployeeTable(),
                ),
            ],
          )

        ],
    );
  }
}
class MobileManagement extends StatelessWidget {
  const MobileManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


Container container2(IconData icon,String no,  ){
  return Container(
    width: 190,
    height: 80,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: darkGrey,
        border: Border.all(
            color: Colors.grey.shade400,
            width: 1
        )
    ),
    child: Column(
      children: [
        SizedBox(height: 15,),
        Icon(icon,size: 22,color: Colors.white,),
        SizedBox(height: 10),
        Text(no,style: TextStyle(color:Colors.white,fontFamily: 'Inter',fontSize: 14,),),
      ],
    ),
  );
}

class EmployeeTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define the text style for the header row
    TextStyle headerTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold, // Bold font for header
      fontSize: 14,
      color: black,
    );

    // Define the text style for the balance rows
    TextStyle rowTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      color: black,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: 868,
        height: 245,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade500,
            width: 1,
          ),
        ),
        child: DataTable(
          // Define the columns with the header text style
          columns: [
            DataColumn(
              label: Text('Leave Type', style: headerTextStyle),
            ),
            DataColumn(
              label: Text('From', style: headerTextStyle),
            ),
            DataColumn(
              label: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text('To', style: headerTextStyle),
              ),
            ),
            DataColumn(
              label: Text('Days', style: headerTextStyle),
            ),
            DataColumn(
              label: Text('Reason', style: headerTextStyle),
            ),
            DataColumn(
              label: Text('Approved', style: headerTextStyle),
            ),
            DataColumn(
              label: Text('Status', style: headerTextStyle),
            ),
          ],
          // Define the rows with the balance row text style
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
          ],
        ),
      ),
    );
  }
}

