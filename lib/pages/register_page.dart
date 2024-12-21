import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:journey2/pages/login_page.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //starting variables
  String? errorMessage = "";
  bool isOldEnough = false;
  bool isRegistered = true;

  //For text inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  //Functions and Widgets
  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (_passwordController.text != null) {
        if (_passwordController.text == _password2Controller.text) {
          await Auth().createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
        } else {
          setState(() {
            errorMessage = "Passwords Do Not Match";
          });
        }
      } else {
        setState(() {
          errorMessage = "All Fields Required";
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Text(
      "Create Account",
      style: GoogleFonts.playfairDisplaySc(
          fontSize: 30,
          color: kPrimaryAccentColor,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _DisplayLogo() {
    return const Center(
        child: CircleAvatar(
      backgroundColor: kNightShade,
      backgroundImage: AssetImage("assets/images/TempLogo.PNG"),
      radius: 50,
    ));
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: title,
            hintStyle: const TextStyle(color: Colors.white),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            )));
  }

  Widget _birthdayField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            icon: Icon(
              Icons.calendar_today,
              color: kPrimaryAccentColor,
            ), //icon of text field
            labelText: "Date of Birth. . .",
            labelStyle: TextStyle(color: Colors.white) //label text of field
            ),
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(
                  1930), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime.now(),
              builder: ((context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      surface: kPrimaryAccentColor,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: kBackgroundColor,
                  ),
                  child: child!,
                );
              }));

          if (pickedDate != null) {
            print(
                pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
            String formattedDate = DateFormat('yyyy-MM-dd').format(
                pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
            print(
                formattedDate); //formatted date output using intl package =>  2022-07-04
            //You can format date as per your need

            setState(() {
              _birthdayController.text =
                  formattedDate; //set foratted date to TextField value.
            });
          } else {
            print("Date is not selected");
          }
          //when click we have to show the datepicker
        });
  }

  Widget _passwordField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: title,
            hintStyle: const TextStyle(color: Colors.white),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            )));
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '$errorMessage',
      style: GoogleFonts.abhayaLibre(
          color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
          padding: const EdgeInsets.fromLTRB(110, 10, 110, 10),
          backgroundColor: kPrimaryAccentColor),
      onPressed: createUserWithEmailAndPassword,
      child: const Text(
        'Sign Up',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        side: const BorderSide(
          width: 3.0,
          color: kPrimaryColor,
        ),
        textStyle: const TextStyle(fontSize: 20),
        padding: const EdgeInsets.fromLTRB(115, 10, 115, 10),
        backgroundColor: Colors.transparent,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const LoginPage();
            },
          ),
        );
      },
      child: const Text(
        'Log In',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _GoogleButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 15),
          padding: const EdgeInsets.fromLTRB(80, 15, 80, 15),
          backgroundColor: kEmptyColor),
      onPressed: () {},
      child: const Text('Login with Google'),
    );
  }

  Widget _bottomRow() {
    return const Row(
      children: <Widget>[
        Spacer(),
        IconButton(
          onPressed: TheGoogleSign,
          icon: Image(image: AssetImage("assets/images/GLogo.png")),
        ),
        Spacer()
      ],
    );
  }

  Widget _TermsButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15),
        backgroundColor: Colors.transparent,
      ),
      onPressed: () {},
      child: const Text(
        'Terms and Conditions',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _returningAccountButton() {
    return TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const LoginPage();
              },
            ),
          );
        },
        child: const Text(
          "Returning Rider? Sign In",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          height: size.height,
          width: size.height * 0.5,
          padding: const EdgeInsets.all(20),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                height: size.height,
                width: size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/AzerPromo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    decoration:
                        BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 80,
                  ),
                  _title(),
                  _errorMessage(),
                  _entryField('Name. . .', _nameController),
                  const SizedBox(
                    height: 20,
                  ),
                  _entryField('Enter Email. . .', _emailController),
                  const SizedBox(
                    height: 20,
                  ),
                  _passwordField('Enter Password. . .', _passwordController),
                  const SizedBox(
                    height: 20,
                  ),
                  _passwordField('Confirm Password. . .', _password2Controller),
                  const SizedBox(
                    height: 5,
                  ),
                  _birthdayField('Date of Birth. . .', _birthdayController),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Must be 18 years or older",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  _submitButton(),
                  const SizedBox(height: 10),
                  _loginButton(),
                  const Spacer(),
                  _bottomRow(),
                  _TermsButton(),
                ],
              ),
            ],
          )),
    );
  }
}
