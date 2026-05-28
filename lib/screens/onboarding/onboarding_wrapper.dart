import 'package:flutter/material.dart';
import '../../widgets/doodle_background.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';

import 'gender_screen.dart';
import 'age_screen.dart';
import 'height_weight_screen.dart';
import 'workout_preference_screen.dart';
import 'activity_level_screen.dart';
import 'training_frequency_screen.dart';
import 'goal_screen.dart';
import 'setup_animation_screen.dart';

const Color cosarcPink = Color(0xFFE91E63);

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final _authService = AuthService();
  int step = 0;
  bool _isSaving = false;

  final List<GlobalKey> _screenKeys = List.generate(7, (_) => GlobalKey());

  final List<Widget> screens = [];

  // Store user data
  final Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    screens.addAll([
      GenderScreen(key: _screenKeys[0]),
      AgeScreen(key: _screenKeys[1]),
      HeightWeightScreen(key: _screenKeys[2]),
      WorkoutPreferenceScreen(key: _screenKeys[3]),
      ActivityLevelScreen(key: _screenKeys[4]),
      TrainingFrequencyScreen(key: _screenKeys[5]),
      GoalScreen(key: _screenKeys[6]),
    ]);
  }

  Future<void> next() async {
    // Get data from current screen
    final currentKey = _screenKeys[step];
    final currentState = currentKey.currentState;

    if (currentState != null) {
      switch (step) {
        case 0: // Gender
          final genderState = currentState as GenderScreenState;
          if (genderState.selected.isEmpty) {
            _showError('Please select a gender');
            return;
          }
          _userData['gender'] = genderState.selected;
          break;

        case 1: // Age
          final ageState = currentState as AgeScreenState;
          _userData['age'] = ageState.age.toInt();
          break;

        case 2: // Height/Weight
          final hwState = currentState as HeightWeightScreenState;
          final height = double.tryParse(hwState.heightController.text) ?? 0;
          final weight = double.tryParse(hwState.weightController.text) ?? 0;

          if (height == 0 || weight == 0) {
            _showError('Please enter valid height and weight');
            return;
          }

          // Convert to cm and kg if needed
          if (hwState.isFtKg) {
            _userData['height'] = (height * 30.48).round().toDouble();
            _userData['weight'] = weight;
          } else {
            _userData['height'] = height;
            _userData['weight'] = (weight / 2.20462).round().toDouble();
          }
          break;

        case 3: // Workout Preference
          final prefState = currentState as WorkoutPreferenceScreenState;
          if (prefState.selected.isEmpty) {
            _showError('Please select a workout preference');
            return;
          }
          _userData['workout_preference'] = prefState.selected;
          break;

        case 4: // Activity Level
          final activityState = currentState as ActivityLevelScreenState;
          if (activityState.selected.isEmpty) {
            _showError('Please select an activity level');
            return;
          }
          _userData['activity_level'] = activityState.selected;
          break;

        case 5: // Training Frequency
          final freqState = currentState as TrainingFrequencyScreenState;
          _userData['training_frequency'] = freqState.days.toInt();
          break;

        case 6: // Goal
          final goalState = currentState as GoalScreenState;
          if (goalState.selected.isEmpty) {
            _showError('Please select a goal');
            return;
          }
          _userData['fitness_goal'] = goalState.selected;
          break;
      }
    }

    print('🔵 Collected data: $_userData');

    if (step < screens.length - 1) {
      setState(() => step++);
    } else {
      await _completeOnboarding();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);

    try {
      print('🔵 Saving onboarding data...');
      print('Final data: $_userData');

      final memberId = await _authService.getMemberId();

      if (memberId == null) {
        throw Exception('No member ID found');
      }

      print('🔵 Member ID: $memberId');

      // Save to database
      await supabase
          .from('members')
          .update({
            'gender': _userData['gender'],
            'age': _userData['age'],
            'height': _userData['height'],
            'weight': _userData['weight'],
            'workout_preference': _userData['workout_preference'],
            'activity_level': _userData['activity_level'],
            'training_frequency': _userData['training_frequency'],
            'fitness_goal': _userData['fitness_goal'],
          })
          .eq('id', memberId)
          .timeout(const Duration(seconds: 10));

      print('✅ Data saved to database!');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SetupAnimationScreen()),
        );
      }
    } catch (e) {
      print('❌ Error: $e');

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoodleBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: LinearProgressIndicator(
                  value: (step + 1) / screens.length,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(cosarcPink),
                ),
              ),
              Expanded(
                child: _isSaving
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: cosarcPink),
                            const SizedBox(height: 24),
                            const Text(
                              'Saving your profile...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : screens[step],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cosarcPink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          step == screens.length - 1
                              ? "Complete Setup"
                              : "Continue",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
