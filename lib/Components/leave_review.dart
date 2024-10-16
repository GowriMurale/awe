
import 'package:awe_project/Screens/leave_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../globals/my_colors.dart';
class LeaveReview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          return DesktopReview();
        } else if (constraints.maxWidth > 800 && constraints.maxWidth < 1200) {
          return DesktopReview();
        } else {
          return MobileReview();
        }
      },
    );
  }
}
class DesktopReview extends StatelessWidget {
  const DesktopReview({super.key});

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
        SizedBox(height: 30,),
        Row(
          children: [
            SizedBox(width: 330,),
           myContainer('Apply Your Leave', darkGrey, Colors.white, 'assets/images/apply.png'),
            SizedBox(width: 120,),
            myContainer('Review Leave Balance', yellow, black, 'assets/images/black.png'),
            SizedBox(width: 120,),
            GestureDetector(
              onTap: (){
                Get.to(()=>HistoryScreen());
              },
                child: myContainer('Leave History', darkGrey, Colors.white, 'assets/images/review.png'))
          ],
        ),
        SizedBox(height: 40,),
      Row(
        children: [
          SizedBox(width: 320,),
          circleChart('Casual Leave'),
          SizedBox(width: 50,),
          circleChart('Sick Leave'),
          SizedBox(width: 50,),
          circleChart('Earned  Leave'),
        ],
      ),
        SizedBox(height: 35,),
        Row(
          children: [
            SizedBox(width: 320,),
            circleChart('Adjustment Leave'),
            SizedBox(width: 50,),
            circleChart('Unpaid Leave'),
            SizedBox(width: 50,),
            circleChart('Half Leave'),
          ],
        )
      ],
    );
  }
}

class MobileReview extends StatelessWidget {
  const MobileReview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


Container myContainer(String text,Color color,Color textcolor, String img){
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



Widget circleChart(String text,){
  return   Card(
    elevation: 2,
    child: Container(
      width: 255,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child:  CircularPercentIndicator(
              radius: 35.0, // Slightly bigger to match Figma
              lineWidth: 8.0, // Thinner line to be more subtle
              percent: 0.57, // This would still control the progress circle, example for 4/7
              center: Text(
                "04/07", // Displaying fraction directly
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Smaller font size to match Figma
                    color: Colors.black // Ensuring text color is black
                ),
              ),
              progressColor: Colors.yellow,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          Expanded(
              child: Column(
                children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8,right: 8),
                          child: Text(text,style: TextStyle(fontFamily: 'Inter',fontSize:14,fontWeight: FontWeight.bold,color: black),),
                        ),
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8,left: 5),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: darkGrey,
                        ),
                         SizedBox(width: 6,),
                         Text('Remaining - 4',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: grey),),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8,left: 5),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: yellow,
                        ),
                        SizedBox(width: 6,),
                        Text('Used - 3',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: grey),),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8,left: 5),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: black,
                        ),
                        SizedBox(width: 6,),
                        Text('Total - 7',style: TextStyle(fontFamily: 'Inter',fontSize: 12,color: grey),),

                      ],
                    ),
                  ),
                ],
              ))
        ],
      ),
    ),
  );
}
