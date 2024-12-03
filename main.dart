import 'package:flutter/material.dart';
import 'trivia_selector.dart'; // Import the TriviaSelector widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivia App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trivia Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the TriviaSelector screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TriviaSelector()),
            );
          },
          child: Text('Start Trivia'),
        ),
      ),
    );
  }
}