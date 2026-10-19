import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lens/theme/widgets/txt_button.dart';

import '../theme/widgets/app_text_field.dart';
import '../theme/widgets/primary_button.dart';


class SignupPage extends StatelessWidget {
  late SharedPreferences prefs;

  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController confirmPassword = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            InkWell(
              child: Ink.image(
                  height: 100,
                  width: 100,
                  image: AssetImage("assets/smartlens_logo.png")
              ),
            ),
            Text('SmartLens', style: Theme.of(context).textTheme.titleLarge),
            AppTextField(controller: username, label: 'Username'),
            AppTextField(controller: password, label: 'Password', isPassword: true,),
            AppTextField(controller: confirmPassword, label: 'Confirm your password', isPassword: true,),
            PrimaryButton(
              label: 'Submit',
              onPressed: (){
                _OnSignup(context);
              },
            ),
            TxtButton(label: "You already have an account.", onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },)

          ],
        ),
      ),
    );
  }

  Future <void> _OnSignup(BuildContext context) async {
    /*if(username.text.isNotEmpty && password.text.isNotEmpty){
      prefs = await SharedPreferences.getInstance();
      prefs.setString("login", username.text);
      prefs.setString("password", password.text);
      prefs.setBool("loggedIn", true);
      Navigator.pop(context);
      Navigator.pushNamed(context, "/home");
    } else{
      const snackBar = SnackBar(
        content: Text('Id ou mot de passe vide.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }*/

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: username.text,
        password: password.text,
      );
      Navigator.pushNamed(context, "/home");

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        const snackBar = SnackBar(
          content: Text('The password provided is too weak.'),
        );
      } else if (e.code == 'email-already-in-use') {
        const snackBar = SnackBar(
          content: Text('The account already exists for that email.'),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
