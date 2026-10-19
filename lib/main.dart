import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lens/pages/camera.page.dart';
import 'package:smart_lens/pages/home.page.dart';
import 'package:smart_lens/pages/login.page.dart';
import 'package:smart_lens/pages/settings.page.dart';
import 'package:smart_lens/pages/signup.page.dart';
import 'package:smart_lens/theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SmartlensApp());
}

class SmartlensApp extends StatelessWidget {

  final routes = {
    '/login': (context) => LoginPage(),
    '/signup': (context) => SignupPage(),
    '/home': (context) => HomePage(),
    '/capture': (context) => CameraPage(),
    '/settings': (context) => SettingsPage(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      routes: routes,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.hasData)
            return HomePage();
          else
            return LoginPage();
        },
      )
    );
  }
}
