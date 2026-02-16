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

  final List<Widget> screens = const [
    GenderScreen(),
    AgeScreen(),
    HeightWeightScreen(),
    WorkoutPreferenceScreen(),
    ActivityLevelScreen(),
    TrainingFrequencyScreen(),
    GoalScreen(),
  ];

  // Store user answers - these will be filled by your screens
  final Map<String, dynamic> _userData = {};

  Future<void> next() async {
    if (step < screens.length - 1) {
      setState(() => step++);
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);

    try {
      print('🔵 Saving onboarding data...');
      print('Data: $_userData');

      final memberId = await _authService.getMemberId();

      if (memberId == null) {
        throw Exception('No member ID found. Please try logging in again.');
      }

      print('🔵 Member ID: $memberId');

      // Update member with collected data
      await supabase.from('members').update({
        'gender': _userData['gender'] ?? 'Not specified',
        'age': _userData['age'] ?? 25,
        'height': _userData['height'] ?? 170.0,
        'weight': _userData['weight'] ?? 70.0,
        'workout_preference': _userData['workout_preference'] ?? 'Gym',
        'activity_level': _userData['activity_level'] ?? 'Moderate',
        'training_frequency': _userData['training_frequency'] ?? 3,
        'fitness_goal': _userData['fitness_goal'] ?? 'General Fitness',
      }).eq('id', memberId);

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
            content: Text('Error saving: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
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
                            CircularProgressIndicator(color: cosarcPink),
                            const SizedBox(height: 24),
                            Text(
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
                      ? SizedBox(
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
                          style: TextStyle(
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
