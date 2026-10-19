import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lens/theme/widgets/txt_button.dart';

import '../theme/widgets/app_text_field.dart';
import '../theme/widgets/primary_button.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  late SharedPreferences prefs;

  TextEditingController username = new TextEditingController();
  TextEditingController password = new TextEditingController();

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
            Text('Capture. Translate.', style: Theme.of(context).textTheme.titleMedium),
            AppTextField(controller: username, label: 'Email'),
            AppTextField(controller: password, label: 'Password', isPassword: true,),
            PrimaryButton(
              label: 'Submit',
              onPressed: (){
                _OnLogin(context);
              },
            ),
            TxtButton(label: "New User", onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/signup');
                },)

          ],
        ),
      ),
    );
  }

  Future <void> _OnLogin(BuildContext context) async {
    /*if(username.text.isNotEmpty && password.text.isNotEmpty){
      prefs = await SharedPreferences.getInstance();
      if(username == prefs.get("login") && password == prefs.get("password"))
        prefs.setBool("isLoggedIn", true);
      Navigator.pop(context);
      Navigator.pushNamed(context, "/home");
    } else{
      const snackBar = SnackBar(
        content: Text('Wrong login credentials.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }*/

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username.text,
          password: password.text
      );
      final User? user = credential.user;

      Navigator.pop(context);
      Navigator.pushNamed(context, "/home");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        const snackBar = SnackBar(
          content: Text('No user found for that email.'),
        );
      } else if (e.code == 'wrong-password') {
        const snackBar = SnackBar(
          content: Text('Wrong password provided for that user.'),
        );
      }
    }

  }
}
