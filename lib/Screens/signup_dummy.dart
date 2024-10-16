import 'package:amplify_core/amplify_core.dart';
import 'package:awe_project/Components/helper_class.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../globals/my_colors.dart';
import 'login_screen.dart';
class SignupDummy extends StatefulWidget {
  const SignupDummy({super.key});

  @override
  State<SignupDummy> createState() => _SignupDummyState();
}

class _SignupDummyState extends State<SignupDummy> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp(BuildContext context) async {
    _isLoading = true;

    final username = userIdController.text.trim();
    print(username);
    final email = emailController.text.trim();
    print(email);
    final password = passwordController.text.trim();
    print(password);

    try {
      // Sign up the user
      SignUpResult res = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(userAttributes: {
          CognitoUserAttributeKey.email: email,
        }),
      );

      if (res.isSignUpComplete) {
        // Inform the user that they need to verify their email
        print("Sign up complete! Please check your email for verification.");

        Get.off(() => LoginScreen());
      } else {
        // Handle further confirmation if needed
        print("Sign up not complete: ${res.nextStep.signUpStep}");
      }
    } on AuthException catch (e) {
      // Handle errors if needed
      print('Sign up failed: ${e.message}');
    } finally {
      _isLoading = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return HelperClass(
        desktop: Scaffold(
          body: Center(
            child: Column(
              children: [
                Padding(
                  padding:  EdgeInsets.only(top: size.height * 0.12,),
                  child: Text("Sign up",style: TextStyle(fontSize: 32,fontFamily: 'Inter',decoration: TextDecoration.none,color: black),),
                ),
                Padding(
                  padding:  EdgeInsets.only(right:size.width * 0.190,top: size.height * 0.02,bottom: size.height * 0.002),
                  child: Text('User Id',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ),
                MyTextField(controller: userIdController, text: 'User ID', icon: Icons.person_outline, obscureText: false,),
                SizedBox(height: size.height * 0.02,),
                Padding(
                  padding:  EdgeInsets.only(right: size.width * 0.180,top: size.height * 0.01,bottom: size.height * 0.005),
                  child: Text('Email',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ),
                MyTextField(controller: emailController, text: 'email', icon: Icons.person_outline, obscureText: false,),
                Padding(
                  padding:  EdgeInsets.only(right: size.width * 0.180,top: size.height * 0.01,bottom: size.height * 0.005),
                  child: Text('passord',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                ),
                MyTextField(controller: passwordController, text: 'User ID', icon: Icons.person_outline, obscureText: false,),
                SizedBox(height: size.height * 0.02,),
                ElevatedButton(
                  onPressed: () => _signUp(context),
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
        tablet: Scaffold(

        ),
        mobile: Scaffold(

        ),
        paddingWidth: size.width * 0.1,
        bgColor: Colors.white);
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final IconData icon;
  final bool obscureText;
  const MyTextField({super.key, required this.controller, required this.text, required this.icon, required this.obscureText});

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
            obscureText: obscureText,
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