import 'package:flutter/material.dart';

class GalaxyPage extends StatelessWidget {
  final Map<String, dynamic> galaxyData;

  GalaxyPage({required this.galaxyData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Galaxy Page")),
      body: Center(
        child: Text(
          "Galaxy Name: ${galaxyData['name']}\nStars: ${galaxyData['stars']}\nDescription: ${galaxyData['description']}",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
