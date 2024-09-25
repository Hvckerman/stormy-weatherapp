import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stormy/FrontPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.teal,
          secondary: Colors.teal,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Stormy',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<void> movetofront() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const FrontPage()));
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 1),
      movetofront,
    );
  }

  @override
  void dispose() {
    super.dispose();
    movetofront();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          'STORMY',
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
                color: Colors.teal,
                letterSpacing: .5,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none),
          ),
        ),
      ),
    );
  }
}
