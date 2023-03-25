import 'package:flutter/material.dart';
import 'package:viva_2/screens/login_page.dart';
import 'package:viva_2/screens/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        'HomePage': (context) => const Homepage(),
      },
    ),
  );
}
