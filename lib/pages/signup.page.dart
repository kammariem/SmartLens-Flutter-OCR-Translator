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
            AppTextField(controller: username, label: 'Email'),
            AppTextField(controller: password, label: 'Password', isPassword: true,),
            AppTextField(controller: confirmPassword, label: 'Confirm your password', isPassword: true,),
            PrimaryButton(
              label: 'Submit',
              onPressed: (){
                _OnSignup(context);
              },
            ),
            TxtButton(label: "You already have an account.", onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },)

          ],
        ),
      ),
    );
  }

  
Future<void> _OnSignup(BuildContext context) async {
  final email = username.text.trim();
  final pwd = password.text;
  final confirmPwd = confirmPassword.text;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  if (email.isEmpty || pwd.isEmpty || confirmPwd.isEmpty) {
    showMessage('Please fill in all fields.');
    return;
  }

  if (pwd != confirmPwd) {
    showMessage('Passwords do not match.');
    return;
  }

  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: pwd,
    );

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;

    switch (e.code) {
      case 'weak-password':
        showMessage('The password is too weak.');
        break;
      case 'email-already-in-use':
        showMessage('This email is already registered.');
        break;
      case 'invalid-email':
        showMessage('Please enter a valid email address.');
        break;
      default:
        showMessage('Registration failed. Please try again.');
    }
  } catch (e) {
    if (!context.mounted) return;
    showMessage('An unexpected error occurred.');
  }
}

}
