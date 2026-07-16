import 'package:flutter/material.dart';
import 'package:restora_mobile/screens/check_in_screen.dart';
import 'package:restora_mobile/screens/home_screen.dart';
import 'package:restora_mobile/screens/login_screen.dart';

void main() {
  runApp(const Restora());
}

class Restora extends StatelessWidget {
  const Restora({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/checkin': (context) => CheckInScreen(),
      },
    );
  }
}
