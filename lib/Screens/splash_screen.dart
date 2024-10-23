import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/Screens/todo_screen.dart';
import 'package:todo/Screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

const String KEYLOGIN = "Login";

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    whereToGo(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 100.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Stay Organized, Stay Focused',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'ToDo App',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void whereToGo(BuildContext context) async {
  var sharedPref = await SharedPreferences.getInstance();

  var isLoggedIn = sharedPref.getBool(KEYLOGIN);

  Timer(const Duration(seconds: 2), () {
    if (isLoggedIn != null) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TodoScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  });
}
