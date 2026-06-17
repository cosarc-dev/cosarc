import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';
import '../../theme/cosarc_colors.dart';
import '../../widgets/cosarc_skeleton.dart';
import '../auth/login_screen.dart';

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
  bool _isLoggingOut = false;

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
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
    if (value == null || value.toString().isEmpty) return defaultValue;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.black,
      body: _isLoading ? _buildSkeleton() : _buildContent(),
    );
  }

  Widget _buildSkeleton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CosarcSkeleton(width: 96, height: 96, borderRadius: 48),
            const SizedBox(height: 16),
            const CosarcSkeleton(width: 160, height: 20),
            const SizedBox(height: 8),
            const CosarcSkeleton(width: 200, height: 14),
            const SizedBox(height: 32),
            Row(
              children: List.generate(
                3,
                (_) => const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: CosarcSkeleton(width: double.infinity, height: 90),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final name = _getDisplayValue(_memberData?['name'], 'Member');
    final email = _getDisplayValue(_memberData?['email'], '');
    final currentStreak = _streakData?['current_streak'] ?? 0;
    final longestStreak = _streakData?['longest_streak'] ?? 0;
    final thisMonthWorkouts = _streakData?['this_month_workouts'] ?? 0;
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

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: CosarcColors.black,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: CosarcColors.textPrimary),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CosarcColors.gold.withOpacity(0.12),
                    CosarcColors.black,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [CosarcColors.gold, CosarcColors.goldDark],
                        ),
                        border: Border.all(
                          color: CosarcColors.gold.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          name[0].toUpperCase(),
                          style: GoogleFonts.inter(
                            color: CosarcColors.black,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: CosarcColors.textPrimary,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: CosarcColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
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
                _sectionTitle('Membership Insights'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        label: 'Current Streak',
                        value: '$currentStreak',
                        unit: 'days',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        label: 'This Month',
                        value: '$thisMonthWorkouts',
                        unit: 'workouts',
                        icon: Icons.fitness_center_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        label: 'Best Streak',
                        value: '$longestStreak',
                        unit: 'days',
                        icon: Icons.emoji_events_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _sectionTitle('Personal Information'),
                const SizedBox(height: 12),
                _infoRow(Icons.person_outline, 'Gender', gender),
                _infoRow(Icons.cake_rounded, 'Age',
                    age > 0 ? '$age years' : 'Not set'),
                _infoRow(Icons.height_rounded, 'Height',
                    height > 0 ? '${height.toStringAsFixed(1)} cm' : 'Not set'),
                _infoRow(Icons.monitor_weight_rounded, 'Weight',
                    weight > 0 ? '${weight.toStringAsFixed(1)} kg' : 'Not set'),
                const SizedBox(height: 32),
                _sectionTitle('Fitness Profile'),
                const SizedBox(height: 12),
                _infoRow(Icons.flag_rounded, 'Goal', fitnessGoal),
                _infoRow(Icons.fitness_center, 'Preference', workoutPreference),
                _infoRow(Icons.speed_rounded, 'Activity', activityLevel),
                _infoRow(
                  Icons.calendar_month,
                  'Frequency',
                  trainingFrequency > 0
                      ? '$trainingFrequency days/week'
                      : 'Not set',
                ),
                const SizedBox(height: 32),
                _sectionTitle('Account'),
                const SizedBox(height: 12),
                _settingsTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isDestructive: true,
                  isLoading: _isLoggingOut,
                  onTap: _isLoggingOut ? null : _logout,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Cosarc v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: CosarcColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: CosarcColors.gold,
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CosarcColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CosarcColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: CosarcColors.gold, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: CosarcColors.textPrimary,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: CosarcColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: CosarcColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CosarcColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CosarcColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: CosarcColors.gold, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: CosarcColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CosarcColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    final color = isDestructive ? CosarcColors.error : CosarcColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDestructive
                ? CosarcColors.error.withOpacity(0.08)
                : CosarcColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDestructive
                  ? CosarcColors.error.withOpacity(0.25)
                  : CosarcColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else ...[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
