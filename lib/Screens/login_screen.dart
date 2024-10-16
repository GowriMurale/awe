

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:awe_project/Components/helper_class.dart';
import 'package:awe_project/Screens/dashboard_screen.dart';
import 'package:awe_project/Screens/change_password_screen.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/CandidateApplicationForm.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final box = GetStorage();

  void storeUserData(String userId) {
    final box = GetStorage();
    box.write('userId', userId);
  }

  String? getUserData() {
    final box = GetStorage();
    return box.read('userId');
  }

  Future<void> _signIn(BuildContext context) async {
    try {
      var session = await Amplify.Auth.fetchAuthSession();

      // Check if user is already signed in
      if (session.isSignedIn) {
        String userId = await Amplify.Auth.getCurrentUser().then((user) => user.userId);
        print(userId);
        storeUserData(userId); // Store user ID locally

        // Fetch candidate application data immediately upon signing in
        // await fetchCandidateApplicationData();

        Get.off(() => DashBoardScreeen()); // Navigate to dashboard
        return;
      }

      // Sign in the user
      SignInResult res = await Amplify.Auth.signIn(
        username: userIdController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.isSignedIn) {
        String userId = await Amplify.Auth.getCurrentUser().then((user) => user.userId);
        print(userId);
        storeUserData(userId); // Store user ID locally

        // Fetch candidate application data after successful sign in
        // await fetchCandidateApplicationData();

        Get.off(() => DashBoardScreeen()); // Navigate to dashboard
      }
    } on AuthException catch (e) {
      _showErrorDialog(context, e.message);
    }
  }

  Future<void> fetchCandidateApplicationData() async {
    try {
      // Get the stored user ID
      String userId = getUserData() ?? '';

      // Create a new GetStorage instance inside the method
      final box = GetStorage();

      // Query the API to get candidate application details
      final request = ModelQueries.list(
        CandidateApplicationForm.classType,
        where: CandidateApplicationForm.ID.eq(userId), // Assuming ID is the user ID field
      );

      final response = await Amplify.API.query(request: request).response;
      print(response);

      if (response.errors.isNotEmpty) {
        print('Errors: ${response.errors}');
        _showErrorDialog(context, 'Failed to fetch application data.');
        return;
      }

      List<CandidateApplicationForm?> candidateApplications = response.data?.items ?? [];
      print(candidateApplications);

      if (candidateApplications.isNotEmpty && candidateApplications.first != null) {
        var candidate = candidateApplications.first;
        print(candidate);

        // Store candidate data locally for later use
        box.write('name', candidate?.name ?? 'N/A');
        print(candidate?.name);
        box.write('email', candidate?.email ?? 'N/A');
        print(candidate?.email);
        box.write('contactNo', candidate?.contactNo ?? 'N/A');
      } else {
        _showErrorDialog(context, 'No data found for the user.');
      }
    } catch (e) {
      print('Failed to fetch candidate data: $e');
      _showErrorDialog(context, 'An unexpected error occurred.');
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
              child: Text('ok'),
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
      //DESKTOP VIEW
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
                SizedBox(height: size.height * 0.20,),
                SizedBox(
                  width: size.width * 0.240,
                  height: size.height * 0.090,
                  child: Image.asset('assets/images/awe logo.png'),
                ),
                SizedBox(height: size.height * 0.040,),
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
                height:size.height *  0.670,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(top: size.height * 0.12,),
                      child: Text("Login",style: TextStyle(fontSize: 32,fontFamily: 'Inter',decoration: TextDecoration.none,color: black),),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right:size.width * 0.190,top: size.height * 0.02,bottom: size.height * 0.002),
                      child: Text('User Id',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ),
                    MyTextField(controller: userIdController, text: 'User ID', icon: Icons.person_outline, obscureText: false,),
                    SizedBox(height: size.height * 0.02,),
                    Padding(
                      padding:  EdgeInsets.only(right: size.width * 0.180,top: size.height * 0.01,bottom: size.height * 0.005),
                      child: Text('Password',style: TextStyle(fontFamily: 'Inter',fontSize: 16,color: black),),
                    ),
                    PasswordTextField(controller: passwordController, width:size.width *  0.235,height:  size.height * 0.050,),
                    SizedBox(height: size.height * 0.075,),
                    MaterialButton(
                      onPressed: _isLoading
                          ? null // Disable the button while loading
                          : () async {
                        setState(() {
                          _isLoading = true; // Start loading
                        });
                        await _signIn(context);
                        setState(() {
                          _isLoading = false; // Stop loading
                        });
                      },
                      minWidth: size.width * 0.228,
                      height: size.height * 0.060,
                      color: yellow,
                      splashColor: yellow,
                      child: _isLoading
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(yellow), // Set spinner color to yellow
                      )
                          : Text(
                        "Login",
                        style: TextStyle(
                          color: black,
                          fontFamily: 'Open Sans',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),


        //TAB VIEW
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
                    child: Image.asset('assets/images/awe logo.png'),
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
                elevation: 2,
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
                        padding:  EdgeInsets.only(top: size.height * 0.080),
                        child: Text("Login",style: TextStyle(fontSize: 22,fontFamily: 'Inter',decoration: TextDecoration.none,color: black),),
                      ),
                      Padding(
                        padding:  EdgeInsets.only(right: size.width * 0.190,top: size.height * 0.020,bottom: size.height * 0.004),
                        child: Text('User Id',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                      ),
                      TabTextField(controller2: userIdController, text2: 'User ID', icon2: Icons.person_outline),
                      SizedBox(height: size.height * 0.02,),
                      Padding(
                        padding:  EdgeInsets.only(right: size.width * 0.170,top: size.height * 0.017,bottom: size.height * 0.002),
                        child: Text('Password',style: TextStyle(fontFamily: 'Inter',fontSize: 15,color: black),),
                      ),
                      PasswordTextField(controller: passwordController, width:size.width * 0.26,
                          height: size.height * 0.04,),
                      SizedBox(height: size.height * 0.05,),
                      MaterialButton(
                        onPressed: _isLoading
                            ? null // Disable the button while loading
                            : () async {
                          setState(() {
                            _isLoading = true; // Start loading
                          });
                          await _signIn(context);
                          setState(() {
                            _isLoading = false; // Stop loading
                          });
                        },
                        minWidth: size.width * 0.26,
                        height: size.height * 0.055,
                        color: yellow,
                        splashColor: yellow,
                        child: _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(yellow), // Set spinner color to yellow
                        )
                            : Text(
                          "Login",
                          style: TextStyle(
                            color: black,
                            fontFamily: 'Open Sans',
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),

        //MOBILE VIEW
        mobile: Scaffold(
          appBar: AppBar(
            backgroundColor: bgColor,
            title:SizedBox(
              width:size.width * 0.40,
              height:size.height * 0.2,
              child: Image.asset('assets/images/awe logo.png'),
            ),
            toolbarHeight: MediaQuery.of(context).size.height * 0.1,
          ),
         body: Container(
           width: size.width * 0.99,
          color: bgColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Container(
                width:size.width * 0.430,
                height: size.height * 0.33,
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
                  width: size.width * 0.68,
                  height: size.height * 0.38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(top: size.height * 0.040),
                        child: Text("Login",style: TextStyle(fontSize: 16,fontFamily: 'Inter',decoration: TextDecoration.none,color: black),),
                      ),
                      Padding(
                        padding:  EdgeInsets.only(right: size.width * 0.350,top: 8,bottom:size.height * 0.002),
                        child: Text('User Id',style: TextStyle(fontFamily: 'Inter',fontSize: 13,color: black),),
                      ),
                      MobileTextField(controller3: userIdController, text3: 'User ID', icon3: Icons.person_outline),
                      SizedBox(height: size.height * 0.02,),
                      Padding(
                        padding:  EdgeInsets.only(right:size.width * 0.330,top:size.height * 0.008,bottom: size.height * 0.002),
                        child: Text('Password',style: TextStyle(fontFamily: 'Inter',fontSize: 13,color: black),),
                      ),
                      PasswordTextField(controller: passwordController, width:size.width * 0.50,
                          height: size.height * 0.045,),
                      SizedBox(height: size.height * 0.04,),
                      MaterialButton(
                        onPressed: _isLoading
                            ? null // Disable the button while loading
                            : () async {
                          setState(() {
                            _isLoading = true; // Start loading
                          });
                          await _signIn(context);
                          setState(() {
                            _isLoading = false; // Stop loading
                          });
                        },
                        minWidth: size.width * 0.38,
                        height: size.height * 0.045,
                        color: yellow,
                        splashColor: yellow,
                        child: _isLoading
                            ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(yellow), // Set spinner color to yellow
                        )
                            : Text(
                          "Login",
                          style: TextStyle(
                            color: black,
                            fontFamily: 'Open Sans',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
       ),),
        paddingWidth: size.width * 0.1,
        bgColor: bgColor
    );
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
        width: size.width * 0.50,
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


class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final double width;
  final double height;

  PasswordTextField({
    required this.controller,
    this.hintText = 'Password',
    required this.width,
    required this.height,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.white,
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Material(
          color: Colors.white,
          child: TextField(
            controller: widget.controller,
            obscureText: !_isPasswordVisible, // Hide or show the password
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),  // Align the text vertically with the icon
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.grey,
                size: 21,  // Adjust icon size if needed
              ),
              hintText: widget.hintText,
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
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined // Show this icon when password is visible
                      : Icons.visibility_off_outlined, // Show this icon when password is hidden
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
