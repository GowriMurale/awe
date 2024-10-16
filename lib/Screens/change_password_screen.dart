
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:awe_project/Components/helper_class.dart';
import 'package:awe_project/Screens/login_screen.dart';
import 'package:awe_project/globals/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard_screen.dart';
class changePasswordScreen extends StatefulWidget {
  final String username;
  const changePasswordScreen({super.key, required this.username});

  @override
  State<changePasswordScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<changePasswordScreen> {
  TextEditingController userIdController=TextEditingController();
  TextEditingController  pasword=TextEditingController();
  TextEditingController  newPassword=TextEditingController();
  TextEditingController  confirmPassword=TextEditingController();

  bool _isLoading=false;

  // Toggle the visibility of the password
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  //
  Future<void> _changePassword(BuildContext context) async {
    if (newPassword.text.trim() == confirmPassword.text.trim()) {
      try {
        // Confirm the sign-in with the new password
        SignInResult result = await Amplify.Auth.confirmSignIn(
          confirmationValue: newPassword.text.trim(),
        );

        if (result.isSignedIn) {
          Get.off(() => LoginScreen());
        } else {
          _showErrorDialog('Password change failed.');
        }
      } on AuthException catch (e) {
        _showErrorDialog(e.message);
      }
    } else {
      _showErrorDialog('Passwords do not match.');
    }
  }


  // Function to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Signup Failed"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("Okay"),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  bool _obscureText = true;
  bool _obscure = true;
  bool isloading = false;
  Future<void> _handleUpdateButton() async {
    setState(() {
      isloading = true; // Show the spinner
    });
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isloading = false; // Hide the spinner
    });
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return HelperClass(
        desktop: Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Image.asset(
                  'assets/images/lock.png', // Replace with your image URL or asset path
                  width:size.width * 0.400,
                  height: size.height * 0.500,
                ),
              ),
              SizedBox(height:size.height * 0.030), // Space between image and form
              Expanded(
                flex: 1,
                child: Padding(
                  padding:  EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.transparent,
                        padding:  EdgeInsets.all(1),
                        height: size.height * 0.105,
                        width:size.width * 0.300,
                        child: Image(image: AssetImage(
                            'assets/images/awe logo.png'),
                          fit: BoxFit.contain,
                        ),),
                      Center(
                        child: Container(
                          height:size.height * 0.050,
                          child:  Text(
                            'Change Password',
                            style: TextStyle(fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontStyle: FontStyle.normal,
                            ),
                            textAlign: TextAlign.right,
                          ),),),
                       SizedBox(height:size.height * 0.010),
                      SizedBox(
                        width:size.width * 0.230,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('User ID', style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontStyle: FontStyle.normal),),
                            Container(
                              height: size.height * 0.048,
                              width:size.width * 0.210,
                              child: TextField(
                                  controller: userIdController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400),
                                    // Border when enabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when focused
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when there is an error
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when disabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),)
                          ],
                        ),
                      ),
                       SizedBox(height:size.height * 0.012),
                      SizedBox(
                        width:size.width * 0.230,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Password', style: TextStyle(
                                fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w600,
                                color: Colors.black, fontStyle: FontStyle.normal),
                            ),
                            Container(
                              height: size.height * 0.048,
                              width:size.width * 0.210,
                              child: TextField(
                                  controller: pasword,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400),
                                    // Border when enabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when focused
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when there is an error
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when disabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),)
                          ],
                        ),
                      ),
                       SizedBox(height:size.height * 0.012),
                      SizedBox(
                        width:size.width * 0.230,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('New Password', style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontStyle: FontStyle.normal)),
                            Container(
                              height: size.height * 0.048,
                              width:size.width * 0.210,
                              child: TextField(
                                controller: newPassword,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400),
                                    // Border when enabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when focused
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when there is an error
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when disabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      // Choose icon based on the obscureText boolean
                                      _obscureText
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText =
                                        !_obscureText; // Toggle the obscureText boolean
                                      });
                                    },
                                  ),
                                ),
                              ),)
                          ],
                        ),
                      ),
                       SizedBox(height:size.height * 0.013),
                      SizedBox(
                        width:size.width * 0.230,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Confirm Password', style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontStyle: FontStyle.normal),),
                            Container(
                              height: size.height * 0.048,
                              width:size.width * 0.210,
                              child: TextField(
                                controller: confirmPassword,
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: Colors.black12, width: 1.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400),
                                    // Border when enabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when focused
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when there is an error
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade500),
                                    // Border when disabled
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      // Choose icon based on the obscureText boolean
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscure =
                                        !_obscure; // Toggle the obscureText boolean
                                      });
                                    },
                                  ),
                                ),
                              ),)
                          ],
                        ),
                      ),
                       SizedBox(height:size.height * 0.030),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: size.width * 0.145,),
                          OutlinedButton(
                            onPressed: () {
                              Get.off(DashBoardScreeen());
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(size.width * 0.075, size.height * 0.055), // Similar to minWidth and height in MaterialButton
                              side: BorderSide(color: grey), // Define the border color for the outlined button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0), // Adjust the border radius as needed
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: black,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02,),
                          MaterialButton(
                            onPressed: _isLoading
                                ? null // Disable the button while loading
                                : () async {
                              setState(() {
                                _isLoading = true; // Start loading
                              });
                              await _changePassword(context);
                              setState(() {
                                _isLoading = false; // Stop loading
                              });
                            },
                            minWidth: size.width * 0.078,
                            height: size.height * 0.055,
                            color: yellow,
                            splashColor: yellow,
                            child: _isLoading
                                ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(yellow), // Set spinner color to yellow
                            )
                                : Text(
                              "Update",
                              style: TextStyle(
                                color: black,
                                fontFamily: 'Open Sans',
                                fontSize: 16,fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.050, width:size.width * 0.280,
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                        ),)
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
        tablet: Scaffold(
          backgroundColor: Colors.white,
            body:  Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Image.asset(
                    'assets/images/lock.png', // Replace with your image URL or asset path
                    width:size.width * 0.350,
                    height: size.height * 0.450,
                  ),
                ),
                SizedBox(height: size.height *0.030), // Space between image and form
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:  EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding:  EdgeInsets.all(1),
                          height:size.height * 0.090,
                          width:size.width * 0.2700,
                          child: Image(image: AssetImage(
                              'assets/images/awe logo.png'),
                            fit: BoxFit.contain,
                          ),),
                        Center(
                          child: Container(
                            height:size.height * 0.050,
                            child: const Text(
                              'Change Password',
                              style: TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                                color: Colors.black,
                                fontStyle: FontStyle.normal,
                              ),
                              textAlign: TextAlign.right,
                            ),),),
                         SizedBox(height:size.height * 0.015),
                        SizedBox(
                          width:size.width * 0.350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('User ID', style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal),),
                              Container(
                                height:size.height * 0.050,
                                width:size.width * 0.315,
                                child: TextField(
                                  controller: userIdController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                         SizedBox(height:size.height * 0.010),
                        SizedBox(
                          width:size.width * 0.350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Password', style: TextStyle(
                                  fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w600,
                                  color: Colors.black, fontStyle: FontStyle.normal),
                              ),
                              Container(
                                height:size.height * 0.050,
                                width:size.width * 0.315,
                                child: TextField(
                                  controller: pasword,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                         SizedBox(height:size.height * 0.010),
                        SizedBox(
                          width:size.width * 0.350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('New Password', style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal)),
                              Container(
                                height:size.height * 0.050,
                                width:size.width * 0.315,
                                child: TextField(
                                  controller: newPassword,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Choose icon based on the obscureText boolean
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText =
                                          !_obscureText; // Toggle the obscureText boolean
                                        });
                                      },
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                         SizedBox(height:size.height *0.010),
                        SizedBox(
                          width:size.width * 0.350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Confirm Password', style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal),),
                              Container(
                                height:size.height * 0.050,
                                width:size.width * 0.315,
                                padding: const EdgeInsets.only(),
                                child: TextField(
                                  controller: confirmPassword,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Choose icon based on the obscureText boolean
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscure =
                                          !_obscure; // Toggle the obscureText boolean
                                        });
                                      },
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                         SizedBox(height:size.height * 0.035),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.120,),
                            OutlinedButton(
                              onPressed: () {
                                Get.off(DashBoardScreeen());
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(size.width * 0.075, size.height * 0.055), // Similar to minWidth and height in MaterialButton
                                side: BorderSide(color: grey), // Define the border color for the outlined button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // Adjust the border radius as needed
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: black,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02,),
                            MaterialButton(
                              onPressed: _isLoading
                                  ? null // Disable the button while loading
                                  : () async {
                                setState(() {
                                  _isLoading = true; // Start loading
                                });
                                await _changePassword(context);
                                setState(() {
                                  _isLoading = false; // Stop loading
                                });
                              },
                              minWidth: size.width * 0.105,
                              height: size.height * 0.055,
                              color: yellow,
                              splashColor: yellow,
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(yellow), // Set spinner color to yellow
                              )
                                  : Text(
                                "Update",
                                style: TextStyle(
                                    color: black,
                                    fontFamily: 'Open Sans',
                                    fontSize: 16,fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height:size.height * 0.055, width:size.width * 0.300,
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          ),)
                      ],
                    ),
                  ),
                ),

              ],
            ),
        ),
        mobile: Scaffold(
          backgroundColor:Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
             title:  Image.asset(
                'assets/images/awe logo.png',
                // Placeholder image, replace with your image
                fit: BoxFit.contain,
                height:size.height * 0.4,
                width:size.width * 0.490,
              ),
              toolbarHeight: MediaQuery.of(context).size.height * 0.1,
            ),
            body: Column(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Image(image: AssetImage(
                            'assets/images/lock.png'),
                          height:size.height * 0.200,
                          width:size.width * 0.400,
                          fit: BoxFit.contain,
                        ),Center(
                          child: Text(
                            'Change Password',
                            style: TextStyle(fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontStyle: FontStyle.normal,
                            ),
                            textAlign: TextAlign.right,
                          ),),
                        SizedBox(height:size.height * 0.012),
                        SizedBox(
                          width: size.width * 0.600,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('User ID', style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal),),
                              Container(
                                height:size.height * 0.042,
                                width:size.width * 0.78,
                                child: TextField(
                                  controller: userIdController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                         SizedBox(height:size.height * 0.005),
                        SizedBox(
                          width: size.width * 0.600,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Password', style: TextStyle(
                                  fontSize: 15,   fontFamily: 'Inter', fontWeight: FontWeight.w600,
                                  color: Colors.black, fontStyle: FontStyle.normal),
                              ),
                              Container(
                                height:size.height * 0.042,
                                width:size.width * 0.788,
                                child: TextField(
                                  controller: pasword,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                         SizedBox(height:size.height * 0.005),
                        SizedBox(
                          width: size.width * 0.600,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('New Password', style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal)),
                              Container(
                                height:size.height * 0.042,
                                width:size.width * 0.788,
                                child: TextField(
                                  controller: newPassword,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Choose icon based on the obscureText boolean
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText =
                                          !_obscureText; // Toggle the obscureText boolean
                                        });
                                      },
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                         SizedBox(height:size.height * 0.005),
                        SizedBox(
                          width: size.width * 0.600,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Confirm Password', style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal),),
                              Container(
                                height:size.height * 0.042,
                                width:size.width * 0.788,
                                child: TextField(
                                  controller: confirmPassword,
                                  obscureText: _obscure,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400),
                                      // Border when enabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when focused
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when there is an error
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade500),
                                      // Border when disabled
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Choose icon based on the obscureText boolean
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscure =
                                          !_obscure; // Toggle the obscureText boolean
                                        });
                                      },
                                    ),
                                  ),
                                ),)
                            ],
                          ),
                        ),
                        SizedBox(height:size.height * 0.033),
                        Row(
                          children: [
                            SizedBox(width: size.width * 0.273,),
                            OutlinedButton(
                              onPressed: () {
                                Get.off(DashBoardScreeen());
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(size.width * 0.070, size.height * 0.050), // Similar to minWidth and height in MaterialButton
                                side: BorderSide(color: grey), // Define the border color for the outlined button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0), // Adjust the border radius as needed
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: black,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.06,),
                            MaterialButton(
                              onPressed: _isLoading
                                  ? null // Disable the button while loading
                                  : () async {
                                setState(() {
                                  _isLoading = true; // Start loading
                                });
                                await _changePassword(context);
                                setState(() {
                                  _isLoading = false; // Stop loading
                                });
                              },
                              minWidth: size.width * 0.2,
                              height: size.height * 0.050,
                              color: yellow,
                              splashColor: yellow,
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(yellow), // Set spinner color to yellow
                              )
                                  : Text(
                                "Update",
                                style: TextStyle(
                                    color: black,
                                    fontFamily: 'Open Sans',
                                    fontSize: 16,fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height:size.height * 0.050, width:size.width * 0.600,
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          ),)
                      ])
                ]),
        ),
        paddingWidth: size.width * 0.1,

        bgColor: bgColor);
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


Widget customTextFieldContainer(
    BuildContext context,
    TextEditingController controller, {
      double widthFactor = 0.3,
      double heightFactor = 0.05,
      String hintText = '',
    }) {
  final Size size = MediaQuery.of(context).size;

  return Container(
    width: size.width * widthFactor,
    height: size.height * heightFactor,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade400, width: 1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    ),
  );
}
