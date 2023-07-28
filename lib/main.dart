import 'package:flutter/material.dart';
import 'package:stormy/FrontPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
      child: const Center(
        child: Text(
          'Stormy',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
