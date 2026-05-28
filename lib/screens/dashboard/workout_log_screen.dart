import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';

const Color cosarcPink = Color(0xFFE91E63);

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  UnityWidgetController? _unityController;
  final _authService = AuthService();
  String? _memberId;

  Set<String> selectedMuscles = {};
  final TextEditingController _notesController = TextEditingController();
  double _duration = 30;
  double _intensity = 50;

  final List<String> muscleGroups = [
    'Abs',
    'Arms',
    'Back',
    'Chest',
    'Legs',
    'Shoulders',
    'Traps'
  ];

  @override
  void initState() {
    super.initState();
    _loadMemberId();
  }

  Future<void> _loadMemberId() async {
    _memberId = await _authService.getMemberId();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onUnityCreated(UnityWidgetController controller) {
    _unityController = controller;
  }

  void _toggleMuscle(String muscle) {
    setState(() {
      if (selectedMuscles.contains(muscle)) {
        selectedMuscles.remove(muscle);
      } else {
        selectedMuscles.add(muscle);
      }
    });

    if (_unityController != null) {
      _unityController!.postMessage(
        'FlutterCommunication',
        'SelectMuscles',
        selectedMuscles.join(','),
      );
    }
  }

  String _getIntensityLabel() {
    if (_intensity < 33) return '🧘 Light';
    if (_intensity < 67) return '🔥 Moderate';
    return '💀 Brutal';
  }

  bool get _canSubmit {
    return selectedMuscles.isNotEmpty &&
        _notesController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: UnityWidget(
              onUnityCreated: _onUnityCreated,
              fullscreen: false,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildBottomSheet(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Log Workout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.35, // 55% of screen
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSectionTitle('Target Muscles'),
                  const SizedBox(height: 12),
                  _buildMuscleSelector(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('What did you do?'),
                  const SizedBox(height: 12),
                  _buildNotesField(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Duration'),
                  const SizedBox(height: 12),
                  _buildDurationSlider(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Intensity'),
                  const SizedBox(height: 12),
                  _buildIntensitySlider(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildMuscleSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: muscleGroups.map((muscle) {
        final isSelected = selectedMuscles.contains(muscle);
        return GestureDetector(
          onTap: () => _toggleMuscle(muscle),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? cosarcPink.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? cosarcPink : Colors.white.withOpacity(0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              muscle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? cosarcPink : Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'e.g., Bench press 3x10, Squats 4x8...',
          hintStyle: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.4),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildDurationSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duration',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                '${_duration.toInt()} min',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: cosarcPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: cosarcPink,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: cosarcPink,
              overlayColor: cosarcPink.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _duration,
              min: 5,
              max: 120,
              divisions: 23,
              onChanged: (value) => setState(() => _duration = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensity',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                _getIntensityLabel(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: cosarcPink,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: cosarcPink,
              overlayColor: cosarcPink.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _intensity,
              min: 0,
              max: 100,
              onChanged: (value) => setState(() => _intensity = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _canSubmit
            ? () async {
                if (_memberId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please login first')),
                  );
                  return;
                }

                try {
                  await supabase.from('workout_logs').insert({
                    'member_id': _memberId,
                    'workout_date':
                        DateTime.now().toIso8601String().split('T')[0],
                    'target_muscles': selectedMuscles.toList(),
                    'exercises': _notesController.text,
                    'duration_minutes': _duration.toInt(),
                    'intensity': _intensity.toInt(),
                  }).timeout(const Duration(seconds: 10));

                  final today = DateTime.now().toIso8601String().split('T')[0];
                  await supabase
                      .from('daily_contracts')
                      .update({'workout_completed': true})
                      .eq('member_id', _memberId!)
                      .eq('contract_date', today)
                      .timeout(const Duration(seconds: 10));

                  await supabase.rpc('calculate_streak',
                      params: {'p_member_id': _memberId}).timeout(
                    const Duration(seconds: 10),
                  );

                  if (mounted) Navigator.pop(context, true);
                } catch (e) {
                  print('Error logging workout: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _canSubmit
                ? LinearGradient(
                    colors: [cosarcPink, cosarcPink.withOpacity(0.8)],
                  )
                : null,
            color: _canSubmit ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _canSubmit
                ? [
                    BoxShadow(
                      color: cosarcPink.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              'Confirm Workout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color:
                    _canSubmit ? Colors.white : Colors.white.withOpacity(0.3),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
