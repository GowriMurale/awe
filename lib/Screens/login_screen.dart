
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:awe_project/Components/helper_class.dart';
import 'package:awe_project/Screens/dashboard_screen.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  Future<void> _signIn(BuildContext context) async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: userIdController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (res.isSignedIn) {
        Get.to(() => DashBoardScreeen());
      } else {
        _showErrorDialog(context, 'Sign-in failed.');
      }
    } on AuthException catch (e) {
      _showErrorDialog(context, e.message);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return HelperClass(
      desktop: Scaffold(
        backgroundColor: bgColor,
        body:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
               Align(
                 alignment: Alignment.topLeft,
                 child: SizedBox(
                   width: 250,
                     height: 260,
                     child: Image.asset('assets/images/curve.png')),
               )
              ],
            ),
            SizedBox(width: size.width * 0.01,),
            Column(
              children: [
                SizedBox(height: size.height * 0.19,),
                SizedBox(
                  width: size.width * 0.245,
                  height: size.height * 0.100,
                  child: Image.asset('assets/images/awe logo.png'),
                ),
                SizedBox(height: size.height * 0.038,),
                Container(
                  height: size.height * 0.490,
                  width: size.width * 0.270,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login.png'),
                    )
                  ),
                )
              ],
            ),
            SizedBox(width: size.width * 0.13,),
            Card(
              elevation: 2,
              shadowColor: Colors.white,
              child: Container(
                width: size.width * 0.280,
                height:size.height *  0.610,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.10,),
                      child: Text("Login",style: TextStyle(fontSize: 32,fontFamily: 'Inter',decoration: TextDecoration.none,color: black),),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.190,top: MediaQuery.of(context).size.height * 0.01,bottom: 2),
                      child: Text('User Id',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ),
                    MyTextField(controller: userIdController, text: 'User ID', icon: Icons.person_outline),
                    SizedBox(height: size.height * 0.01,),
                    Padding(
                      padding:  EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.180,top: 10,bottom: 2),
                      child: Text('Password',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ),
                    MyTextField(controller: passwordController, text: 'Password', icon: Icons.lock_outline),
                    SizedBox(height: size.height * 0.06,),
                    MaterialButton(
                      onPressed: (){
                       Get.off(DashBoardScreeen());
                      },
                      minWidth: size.width * 0.225,
                      height:size.height * 0.055,
                      color: yellow,
                      splashColor: yellow,
                      child: Text("Login",style: TextStyle(color: black,fontFamily: 'Open Sans',fontSize: 16),),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),



        tablet: Scaffold(
          backgroundColor: bgColor,
          body:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                        width: 145,
                        height: 150,
                        child: Image.asset('assets/images/curve.png')),
                  )
                ],
              ),
              Column(
                children: [
                  SizedBox(height: size.height * 0.21,),
                  SizedBox(
                    width: size.width * 0.2,
                    height: size.height * 0.14,
                    child: Image.asset('assets/images/logo (2).png'),
                  ),
                  SizedBox(height: size.height * 0.03,),
                  Container(
                    height: size.height * 0.38,
                    width: size.width * 0.32,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/login.png'),
                        )
                    ),
                  )
                ],
              ),
              SizedBox(width: size.width * 0.08,),
              Card(
                elevation: 3,
                shadowColor: Colors.white,
                child: Container(
                  width: size.width * 0.34,
                  height: size.height * 0.55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 85),
                        child: Text("Login",style: TextStyle(fontSize: 22,fontFamily: 'Inter',decoration: TextDecoration.none,color: black),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 190,top: 12,bottom: 2),
                        child: Text('User Id',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                      ),
                      TabTextField(controller2: userIdController, text2: 'User ID', icon2: Icons.person_outline),
                      SizedBox(height: size.height * 0.02,),
                      Padding(
                        padding: const EdgeInsets.only(right: 170,top: 10,bottom: 2),
                        child: Text('Password',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                      ),
                      TabTextField(controller2: passwordController, text2: 'Password', icon2: Icons.lock_outline),
                      SizedBox(height: size.height * 0.05,),
                      MaterialButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoardScreeen()));
                        },
                        minWidth: size.width * 0.26,
                        height: size.height * 0.05,
                        color: yellow,
                        splashColor: yellow,
                        child: Text("Login",style: TextStyle(color: black,fontFamily: 'Open Sans',fontSize: 16),),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        mobile: Column(
          children: [
         SizedBox(
           width: 150,
           height: 70,
           child: Image.asset('assets/images/logo (2).png'),
         ),
            Container(
              width: 200,
              height: 230,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login.png',)
                )
              ),
            ),
            Card(
              elevation: 3,
              shadowColor: Colors.white,
              child: Container(
                width: size.width * 0.55,
                height: size.height * 0.45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 35),
                      child: Text("Login",style: TextStyle(fontSize: 16,fontFamily: 'Inter',decoration: TextDecoration.none,color: black),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 130,top: 8,bottom: 2),
                      child: Text('User Id',style: TextStyle(fontFamily: 'Inter',fontSize: 13,color: black),),
                    ),
                    MobileTextField(controller3: userIdController, text3: 'User ID', icon3: Icons.person_outline),
                    SizedBox(height: size.height * 0.02,),
                    Padding(
                      padding: const EdgeInsets.only(right: 130,top: 8,bottom: 2),
                      child: Text('Password',style: TextStyle(fontFamily: 'Inter',fontSize: 13,color: black),),
                    ),
                    MobileTextField(controller3: passwordController, text3: 'Password', icon3: Icons.lock_outline),
                    SizedBox(height: size.height * 0.04,),
                    MaterialButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoardScreeen()));
                      },
                      minWidth: size.width * 0.37,
                      height: size.height * 0.05,
                      color: yellow,
                      splashColor: yellow,
                      child: Text("Login",style: TextStyle(color: black,fontFamily: 'Open Sans',fontSize: 16),),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        paddingWidth: size.width * 0.1,
        bgColor: bgColor);
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final IconData icon;
  const MyTextField({super.key, required this.controller, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return   Card(
      elevation: 2,
      shadowColor: Colors.white,
      child: Container(
        width: size.width *  0.235,
        height: size.height * 0.050,
        child: Material(
          color: Colors.white,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),  // Align the text vertically with the icon
              prefixIcon: Icon(
                icon,
                color: Colors.grey,
                size: 21,  // Adjust icon size if needed
              ),
              hintText: text,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TabTextField extends StatelessWidget {
  final TextEditingController controller2;
  final String text2;
  final IconData icon2;
  const TabTextField({super.key, required this.controller2, required this.text2, required this.icon2});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Card(
      elevation: 2,
      shadowColor: Colors.white,
      child: Container(
        width: size.width * 0.26,
        height: size.height * 0.04,
        child: Material(
          color: Colors.white,
          child: TextField(
            controller: controller2,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),  // Align the text vertically with the icon
              prefixIcon: Icon(
                icon2,
                color: Colors.grey,
                size: 19,  // Adjust icon size if needed
              ),
              hintText: text2,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MobileTextField extends StatelessWidget {
  final TextEditingController controller3;
  final String text3;
  final IconData icon3;
  const MobileTextField({super.key, required this.controller3, required this.text3, required this.icon3});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Card(
      elevation: 2,
      shadowColor: Colors.white,
      child: Container(
        width: size.width * 0.40,
        height: size.height * 0.045,
        child: Material(
          color: Colors.white,
          child: TextField(
            controller: controller3,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),  // Align the text vertically with the icon
              prefixIcon: Icon(
                icon3,
                color: Colors.grey,
                size: 16,  // Adjust icon size if needed
              ),
              hintText: text3,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}