import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class AgeScreen extends StatefulWidget {
  final void Function(int age)? onChanged;
  const AgeScreen({super.key, this.onChanged});

  @override
  State<AgeScreen> createState() => AgeScreenState();
}

class AgeScreenState extends State<AgeScreen> {
  double age = 18;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "How old are you?",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          age.toInt().toString(),
          style: const TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Slider(
          value: age,
          min: 5,
          max: 100,
          divisions: 95,
          activeColor: cosarcPink,
          onChanged: (v) {
            setState(() => age = v);
            widget.onChanged?.call(v.toInt());
          },
        ),
      ],
    );
  }
}
