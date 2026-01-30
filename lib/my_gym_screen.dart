import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class MyGymScreen extends StatefulWidget {
  const MyGymScreen({super.key});

  @override
  State<MyGymScreen> createState() => _MyGymScreenState();
}

class _MyGymScreenState extends State<MyGymScreen> {
  UnityWidgetController? _unityWidgetController;
  bool _isUnityLoaded = false;

  final Set<String> _selectedMuscles = {};
  final List<String> _muscleGroups = [
    "Abs",
    "Arms",
    "Back",
    "Chest",
    "Legs",
    "Shoulders",
    "Traps"
  ];

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }

  // 1. Called when Unity is ready
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
    setState(() {
      _isUnityLoaded = true;
    });

    // Sometimes Unity needs a manual "Resume" signal when embedded
    _unityWidgetController?.resume();
  }

  // 2. Handle messages FROM Unity (Optional: for debugging)
  void onUnityMessage(message) {
    print('Received message from Unity: ${message.toString()}');
  }

  // 3. Handle Unity Scene Loaded
  void onUnitySceneLoaded(SceneLoaded? scene) {
    print('Received scene loaded from Unity: ${scene?.name}');
    print('Scene index: ${scene?.buildIndex}');
  }

  void _toggleMuscle(String muscle) {
    setState(() {
      if (_selectedMuscles.contains(muscle)) {
        _selectedMuscles.remove(muscle);
      } else {
        _selectedMuscles.add(muscle);
      }
    });

    String data = _selectedMuscles.join(",");

    // Logic check: Ensure controller exists before sending
    if (_unityWidgetController != null) {
      _unityWidgetController!.postMessage(
        'FlutterCommunication',
        'SelectMuscles',
        data,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Anatomy Model"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // THE UNITY VIEW
                UnityWidget(
                  onUnityCreated: onUnityCreated,
                  onUnityMessage: onUnityMessage,
                  onUnitySceneLoaded: onUnitySceneLoaded,
                  useAndroidViewSurface:
                      true, // Try setting to 'false' if still black
                  fullscreen: false,
                ),

                // Loading Overlay (Shows until Unity is ready)
                if (!_isUnityLoaded)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.orange),
                        SizedBox(height: 20),
                        Text("Loading 3D Model...",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // SELECTION BUTTONS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _muscleGroups.map((muscle) {
                bool isSelected = _selectedMuscles.contains(muscle);
                return FilterChip(
                  label: Text(muscle),
                  selected: isSelected,
                  onSelected: (_) => _toggleMuscle(muscle),
                  selectedColor: Colors.orange,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
