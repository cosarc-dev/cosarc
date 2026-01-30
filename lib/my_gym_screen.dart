import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class MyGymScreen extends StatefulWidget {
  const MyGymScreen({super.key});

  @override
  State<MyGymScreen> createState() => _MyGymScreenState();
}

class _MyGymScreenState extends State<MyGymScreen> {
  UnityWidgetController? _unityWidgetController;
  final Set<String> _selectedMuscles = {};
  final TextEditingController _textController = TextEditingController();

  final List<String> _muscleGroups = [
    "Abs",
    "Arms",
    "Back",
    "Chest",
    "Legs",
    "Shoulders",
    "Traps"
  ];

  final Color darkPink = const Color(0xFFD81B60);

  void onUnityCreated(controller) {
    _unityWidgetController = controller;
    _unityWidgetController?.resume();
  }

  void _toggleMuscle(String muscle) {
    setState(() {
      if (_selectedMuscles.contains(muscle)) {
        _selectedMuscles.remove(muscle);
      } else {
        _selectedMuscles.add(muscle);
      }
    });
    _sendToUnity();
  }

  void _sendToUnity() {
    _unityWidgetController?.postMessage(
      'FlutterCommunication',
      'SelectMuscles',
      _selectedMuscles.join(","),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. LAYER ONE: THE BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              'assets/gym_bg.jpg', // <--- YOUR IMAGE PATH
              fit: BoxFit.cover,
            ),
          ),

          // 2. LAYER TWO: DARKENING OVERLAY (Makes the model pop)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // 3. LAYER THREE: FULL SCREEN UNITY MODEL
          // Since the Unity Camera alpha is 0, the image will show through!
          Positioned.fill(
            child: UnityWidget(
              onUnityCreated: onUnityCreated,
              useAndroidViewSurface: true,
            ),
          ),

          // 4. LAYER FOUR: BOTTOM UI OVERLAY
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BUTTONS
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: _muscleGroups.map((muscle) {
                      bool isSelected = _selectedMuscles.contains(muscle);
                      return GestureDetector(
                        onTap: () => _toggleMuscle(muscle),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? darkPink
                                : Colors.grey[900]?.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected ? darkPink : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            muscle.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // TEXT BAR
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: darkPink,
                      decoration: InputDecoration(
                        hintText: "Enter exercise notes...",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.fitness_center, color: darkPink),
                        suffixIcon:
                            const Icon(Icons.send, color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
