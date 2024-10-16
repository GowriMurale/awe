import 'package:awe_project/Components/helper_class.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/material.dart';
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController login=TextEditingController();
    TextEditingController password=TextEditingController();
   final ScrollController scrollController=ScrollController();
    final Size size = MediaQuery.of(context).size;
    return HelperClass(
        desktop: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
                child: Container(
                  width: 400,
                  height: 340,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/start img.png')
                    )
                  ),
                )),
           // VerticalDivider(),
            Expanded(
              flex: 2,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,  // Places the image at the top center
                        child: Image.asset(
                          'assets/images/logo (2).png',
                          width: 400,  // You can adjust the width as per your need
                          height: 100, // You can adjust the height as per your need
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:25,left: 70),
                        child: Text("Welcome Back",style: TextStyle(fontSize: 22,color: black,decoration: TextDecoration.none,fontFamily: 'Inter'),),
                      ),
                      SizedBox(height: 5,),
                      Text("Hello again ! dive into your tasks and let's make today productive.",style: TextStyle(fontSize: 13,color: black,fontFamily: 'Inter',decoration: TextDecoration.none),),

                      Padding(
                        padding: const EdgeInsets.only(top: 30,right: 310),
                        child: Text("Login ID",style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,decoration: TextDecoration.none),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 390,
                          height: 35,
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              controller: login,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),  // Match the border radius
                                  borderSide: BorderSide(color: Colors.grey.shade300), // Outline border color
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey.shade300), // Outline border color
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2), // Thicker outline on focus
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5,right: 310),
                        child: Text("Password",style: TextStyle(fontFamily: 'Inter',fontSize: 18,color: black,decoration: TextDecoration.none),),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 390,
                          height: 35,
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              controller: login,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),  // Match the border radius
                                  borderSide: BorderSide(color: Colors.grey.shade300), // Outline border color
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey.shade300), // Outline border color
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 2), // Thicker outline on focus
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 280),
                        child: TextButton(
                            onPressed: (){},
                            child: Text('Forget Password ?',style: TextStyle(fontSize: 14,fontFamily: 'Open Sans',color: grey,decoration:TextDecoration.none),)),
                      ),
                      SizedBox(height: 15,),
                      MaterialButton(
                          onPressed: (){
                          },
                        minWidth: 220,
                        height: 40,
                        color: yellow,
                        child: Text("Login",style: TextStyle(color: black,fontFamily: 'Open Sans',fontSize: 16),),
                      ),
                      SizedBox(height: 20,),
                    Container(
                      width: 290,
                      child: Divider(
                        color: grey,
                      ),
                    ),
                      TextButton(onPressed: (){},
                          child: Text('change Password',style: TextStyle(fontFamily: 'Inter',fontSize: 16,decoration: TextDecoration.none),))
                    ],
                              ),
                ))
          ],
        ),
        tablet: Row(
          children: [
            Expanded(
                child: Container(
                  width: 470,
                  height: 424,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/lock.png')
                      )
                  ),
                )),
            Divider(),
            Expanded(
                child: Column(

                ))
          ],
        ),
        mobile: Column(
          children: [
            Image.asset('assets/images/lock.png',height: 420,width: 460,),
            SizedBox(height: 20,),
            Text('Welcome Back',style: TextStyle(fontFamily: 'Inter',fontSize: 24),)
          ],
        ),
        paddingWidth: size.width * 0.1,
        bgColor: Colors.white);
  }
}
