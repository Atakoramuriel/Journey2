import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journey2/auth.dart';
import 'package:journey2/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:journey2/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //Place Variables Here
  String? errorMessage = "";
  bool isLoggedIn = true;

  //For text inputs
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Functions
  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassWord(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  void redirectSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return Text(
      "Ride Along",
      style: GoogleFonts.playfairDisplaySc(
          fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold),
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
    if (_emailController.text == null) {
      return Text(
        errorMessage = "Email required...",
        style: GoogleFonts.abhayaLibre(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25),
      );
    } else {
      return Text(
        errorMessage == '' ? '' : '${errorMessage}',
        style: GoogleFonts.abhayaLibre(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25),
      );
    }
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
          padding: const EdgeInsets.fromLTRB(110, 10, 110, 10),
          backgroundColor: kPrimaryAccentColor),
      onPressed: signInWithEmailAndPassword,
      child: const Text('Log In'),
    );
  }

  Widget _RegisterButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        side: const BorderSide(
          width: 3.0,
          color: kPrimaryColor,
        ),
        textStyle: const TextStyle(fontSize: 20),
        padding: const EdgeInsets.fromLTRB(105, 10, 105, 10),
        backgroundColor: Colors.transparent,
      ),
      onPressed: redirectSignUpPage,
      child: const Text('Sign Up'),
    );
  }

  Widget _ForgotPasswordButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 15),
        backgroundColor: Colors.transparent,
      ),
      onPressed: () {},
      child: const Text(
        'Forgot Password',
        style: TextStyle(
          color: kPrimaryAccentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  Widget _GoogleButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 15),
          padding: const EdgeInsets.fromLTRB(80, 15, 80, 15),
          backgroundColor: kEmptyColor),
      onPressed: signInWithEmailAndPassword,
      child: const Text('Login with Google'),
    );
  }

  Widget _bottomRow() {
    return Row(
      children: const <Widget>[
        Spacer(),
        IconButton(
          onPressed: signInWithGoogle,
          icon: Image(image: AssetImage("assets/images/GLogo.png")),
        ),
        Spacer()
      ],
    );
  }

  Widget _newAccountButton() {
    return TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const RegisterPage();
              },
            ),
          );
        },
        child: const Text(
          "New Rider? Create New Account",
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
      width: size.width,
      child: Stack(
        children: [
          Container(
            child: Container(
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
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.0)),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: size.height * 0.35,
                        ),
                        _title(),
                        _errorMessage(),
                        const SizedBox(
                          height: 15,
                        ),
                        _entryField('Email. . .', _emailController),
                        const SizedBox(
                          height: 25,
                        ),
                        _passwordField('Password. . .', _passwordController),
                        Row(
                          children: <Widget>[
                            const Spacer(),
                            _ForgotPasswordButton(),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        _submitButton(),
                        const SizedBox(
                          height: 15,
                        ),
                        _RegisterButton(),
                        _bottomRow(),
                        Row(
                          children: <Widget>[
                            const Spacer(),
                            _TermsButton(),
                            const Spacer()
                          ],
                        ),
                      ],
                    ),
                  ],
                )),
          )
        ],
      ),
    ));
  }
}
