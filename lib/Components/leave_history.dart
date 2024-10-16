import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../globals/my_colors.dart';
class LeaveHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopHistory();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return DesktopHistory();
        } else {
          return MobileHistory();
        }
      },
    );
  }
}
class DesktopHistory extends StatelessWidget {
  const DesktopHistory({super.key});

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
              IconButton(onPressed: (){
                Get.back();
              }, icon: Icon(Icons.arrow_back_outlined,size: 25,color: black,)),
              SizedBox(width: 350,),
              Text('Leave  Management',style: TextStyle(color: black,fontSize:32,fontWeight: FontWeight.bold,fontFamily: 'Inter'),),
            ],
          ),
        ),
        SizedBox(height: 30,),
        Row(
          children: [
            SizedBox(width: 330,),
            myContainers('Apply Your Leave', darkGrey, Colors.white, 'assets/images/apply.png'),
            SizedBox(width: 120,),
            myContainers('Review Leave Balance', darkGrey, Colors.white, 'assets/images/review.png'),
            SizedBox(width: 120,),
            myContainers('Leave History', yellow, black, 'assets/images/black.png')
          ],
        ),
        SizedBox(height: 40,),
        Row(
          children: [
            SizedBox(width: 300,),
            EmployeeTable(),
          ],
        ),
        SizedBox(height: 18,),
        Row(
          children: [
            SizedBox(width: 1000,),
            Container(
              width: 80,
              height: 20,
              color: Colors.grey.shade200,
              child: Align(
                  alignment:Alignment.center,
              child: Text('Previous',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),)),
            ),
            Container(
              width: 35,
                height: 20,
                color: Colors.white,
                child: Align(
                  alignment: Alignment.center,
                    child: Text('1',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),)),
            ),
            Container(
              width: 35,
              height: 20,
              color:yellow,
              child: Align(
                  alignment: Alignment.center,
                  child: Text('2',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),)),
            ),
            Container(
              width: 50,
              height: 20,
              color: Colors.grey.shade200,
              child: Align(
                  alignment: Alignment.center,
                  child: Text('Next',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: black),)),
            ),
          ],
        )


      ],
    );
  }
}
Container myContainers(String text,Color color,Color textcolor, String img){
  return Container(
    width: 210,
    height: 90,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
        border: Border.all(
            color: Colors.grey.shade400,
            width: 1
        )
    ),
    child: Column(
      children: [
        SizedBox(height: 15,),
        SizedBox(
            height: 30,
            width: 35,
            child: Image.asset(img)),
        SizedBox(height: 5),
        Text(text,style: TextStyle(color:textcolor,fontFamily: 'Inter',fontSize: 18,),),
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
      fontSize: 13,
      color: black,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: 900,
        height: 300,
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
              DataCell(Text('Monthly Leave', style: rowTextStyle)),
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
            DataRow(cells: [
              DataCell(Text('Medical Leave', style: rowTextStyle)),
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

class MobileHistory extends StatelessWidget {
  const MobileHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

      ],
    );
  }
}
