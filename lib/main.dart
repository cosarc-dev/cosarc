import 'package:flutter/material.dart';
import 'my_gym_screen.dart';

void main() {
  // Removed the 'const' keyword that was causing the error
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyGymScreen(),
  ));
}
