import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';
import '../auth/login_screen.dart';

const Color cosarcPink = Color(0xFFE91E63);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _memberData;
  Map<String, dynamic>? _streakData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final memberId = await _authService.getMemberId();
      if (memberId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final member =
          await supabase.from('members').select().eq('id', memberId).single();

      final streak = await supabase
          .from('streaks')
          .select()
          .eq('member_id', memberId)
          .single();

      if (mounted) {
        setState(() {
          _memberData = member;
          _streakData = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _getDisplayValue(dynamic value, String defaultValue) {
    if (value == null || value.toString().isEmpty) {
      return defaultValue;
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: cosarcPink),
        ),
      );
    }

    // Extract data with fallbacks
    final name = _getDisplayValue(_memberData?['name'], 'Fitness Warrior');
    final email = _getDisplayValue(_memberData?['email'], 'warrior@cosarc.app');
    final currentStreak = _streakData?['current_streak'] ?? 0;
    final longestStreak = _streakData?['longest_streak'] ?? 0;
    final thisMonthWorkouts = _streakData?['this_month_workouts'] ?? 0;

    // Onboarding data
    final age = _memberData?['age'] ?? 0;
    final height = _memberData?['height'] ?? 0.0;
    final weight = _memberData?['weight'] ?? 0.0;
    final gender = _getDisplayValue(_memberData?['gender'], 'Not set');
    final fitnessGoal =
        _getDisplayValue(_memberData?['fitness_goal'], 'Not set');
    final workoutPreference =
        _getDisplayValue(_memberData?['workout_preference'], 'Not set');
    final activityLevel =
        _getDisplayValue(_memberData?['activity_level'], 'Not set');
    final trainingFrequency = _memberData?['training_frequency'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cosarcPink.withOpacity(0.2),
                      Colors.black,
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 60,
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    cosarcPink,
                                    cosarcPink.withOpacity(0.7)
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          label: 'Streak',
                          value: currentStreak.toString(),
                          icon: Icons.local_fire_department_rounded,
                          color: Color(0xFFFF5722),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          label: 'Workouts',
                          value: thisMonthWorkouts.toString(),
                          icon: Icons.fitness_center_rounded,
                          color: cosarcPink,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          label: 'Best',
                          value: longestStreak.toString(),
                          icon: Icons.emoji_events_rounded,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Personal Information Section
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'Gender',
                    value: gender,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.cake_rounded,
                    label: 'Age',
                    value: age > 0 ? '$age years' : 'Not set',
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.height_rounded,
                    label: 'Height',
                    value: height > 0
                        ? '${height.toStringAsFixed(1)} cm'
                        : 'Not set',
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.monitor_weight_rounded,
                    label: 'Weight',
                    value: weight > 0
                        ? '${weight.toStringAsFixed(1)} kg'
                        : 'Not set',
                  ),

                  const SizedBox(height: 32),

                  // Fitness Profile Section
                  Text(
                    'Fitness Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoCard(
                    icon: Icons.flag_rounded,
                    label: 'Fitness Goal',
                    value: fitnessGoal,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.fitness_center,
                    label: 'Workout Preference',
                    value: workoutPreference,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.speed_rounded,
                    label: 'Activity Level',
                    value: activityLevel,
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.calendar_month,
                    label: 'Training Frequency',
                    value: trainingFrequency > 0
                        ? '$trainingFrequency days/week'
                        : 'Not set',
                  ),

                  const SizedBox(height: 32),

                  // Settings Section
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSettingsButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit Profile',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Edit profile feature coming soon!'),
                          backgroundColor: cosarcPink,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildSettingsButton(
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _buildSettingsButton(
                    icon: Icons.lock_rounded,
                    label: 'Privacy & Security',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _buildSettingsButton(
                    icon: Icons.help_rounded,
                    label: 'Help & Support',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _logout,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: Colors.red,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'Cosarc v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cosarcPink.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: cosarcPink,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
