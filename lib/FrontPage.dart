import 'package:flutter/material.dart';

// ignore: camel_case_types
class FrontPage extends StatefulWidget {
  const FrontPage({super.key});

  @override
  State createState() => FrontPageState();
}

class FrontPageState extends State {
  bool _isSearchMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const Drawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearchMode
            ? TextField(
                // Implement your search bar here...
                // You can use the 'onChanged' property to handle search input changes.
                )
            : const Text('Stormy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearchMode = !_isSearchMode;
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearchMode) {
            setState(() {
              _isSearchMode = false;
            });
          }
        },
        child: Column(
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
      ),
    );
  }
}
