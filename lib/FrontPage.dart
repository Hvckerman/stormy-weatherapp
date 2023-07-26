import 'package:flutter/material.dart';

// ignore: camel_case_types
class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State createState() => FrontPageState();
}

class FrontPageState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Stormy'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width * 1,
            color: Colors.grey,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 1,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
