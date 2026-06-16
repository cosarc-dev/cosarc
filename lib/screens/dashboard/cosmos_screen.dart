import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/dynamic_island_streak.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_section.dart';
import '../../services/auth_service.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_transitions.dart';
import '../../core/theme/cosarc_typography.dart';
import 'workout_log_screen.dart';
import 'enhanced_nutrition_screen.dart';
import 'profile_screen.dart';
import '../../models/food_log.dart';

class CosmosScreen extends StatefulWidget {
  const CosmosScreen({super.key});

  @override
  State<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends State<CosmosScreen> {
  final _authService = AuthService();
  String? _memberId;
  Map<String, dynamic>? _todayContract;
  Map<String, dynamic>? _streakData;
  bool _isLoading = true;

  static const int waterTarget = 3000;
  static const int stepTarget = 10000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _memberId = await _authService.getMemberId();
      if (_memberId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final today = DateTime.now().toIso8601String().split('T')[0];
      var contract = await supabase
          .from('daily_contracts')
          .select()
          .eq('member_id', _memberId!)
          .eq('contract_date', today)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (contract == null) {
        await supabase.from('daily_contracts').insert({
          'member_id': _memberId,
          'contract_date': today,
        }).timeout(const Duration(seconds: 10));
        contract = await supabase
            .from('daily_contracts')
            .select()
            .eq('member_id', _memberId!)
            .eq('contract_date', today)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
      }

      var streak = await supabase
          .from('streaks')
          .select()
          .eq('member_id', _memberId!)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (streak == null) {
        await supabase.from('streaks').insert({'member_id': _memberId}).timeout(
            const Duration(seconds: 10));
        streak = await supabase
            .from('streaks')
            .select()
            .eq('member_id', _memberId!)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
      }

      if (mounted) {
        setState(() {
          _todayContract = contract;
          _streakData = streak;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isFoodLoggedToday(Box<FoodLog> box) {
    if (_todayContract?['nutrition_logged'] == true) return true;
    final today = DateTime.now();
    return box.values.any(
      (log) =>
          log.dateTime.year == today.year &&
          log.dateTime.month == today.month &&
          log.dateTime.day == today.day,
    );
  }

  bool get _contractComplete {
    final box = Hive.box<FoodLog>('daily_logs');
    return (_todayContract?['workout_completed'] ?? false) &&
        _isFoodLoggedToday(box) &&
        ((_todayContract?['water_intake_ml'] ?? 0) >= waterTarget) &&
        ((_todayContract?['steps_count'] ?? 0) >= stepTarget);
  }

  bool get workoutDone => _todayContract?['workout_completed'] ?? false;
  int get waterMl => _todayContract?['water_intake_ml'] ?? 0;
  int get steps => _todayContract?['steps_count'] ?? 0;
  int get currentStreak => _streakData?['current_streak'] ?? 0;
  int get longestStreak => _streakData?['longest_streak'] ?? 0;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int _completedCount(bool eatCleanDone) {
    var count = 0;
    if (workoutDone) count++;
    if (eatCleanDone) count++;
    if (waterMl >= waterTarget) count++;
    if (steps >= stepTarget) count++;
    return count;
  }

  Future<void> _addWater(int ml) async {
    if (_isLoading || _todayContract == null) return;
    try {
      await supabase
          .from('daily_contracts')
          .update({'water_intake_ml': waterMl + ml})
          .eq('id', _todayContract!['id'])
          .timeout(const Duration(seconds: 10));
      await _loadData();
    } catch (e) {
      debugPrint('Error updating water: $e');
    }
  }

  Future<void> _logSteps(int count) async {
    if (_isLoading || _todayContract == null) return;
    try {
      await supabase
          .from('daily_contracts')
          .update({'steps_count': count})
          .eq('id', _todayContract!['id'])
          .timeout(const Duration(seconds: 10));
      await _loadData();
    } catch (e) {
      debugPrint('Error updating steps: $e');
    }
  }

  void _showStepsSheet() {
    final controller = TextEditingController(text: steps > 0 ? '$steps' : '');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CosarcGlass(
          expand: true,
          radius: CosarcSpacing.radiusXl,
          margin: const EdgeInsets.all(CosarcSpacing.md),
          padding: const EdgeInsets.all(CosarcSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log steps', style: CosarcTypography.title(context)),
              const SizedBox(height: CosarcSpacing.sm),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: CosarcTypography.metric(''),
                decoration: InputDecoration(
                  hintText: '10000',
                  suffixText: 'steps',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(CosarcSpacing.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: CosarcSpacing.md),
              Wrap(
                spacing: CosarcSpacing.sm,
                children: [
                  _QuickStepChip(label: '+1k', onTap: () => controller.text = '${(int.tryParse(controller.text) ?? steps) + 1000}'),
                  _QuickStepChip(label: '+2.5k', onTap: () => controller.text = '${(int.tryParse(controller.text) ?? steps) + 2500}'),
                  _QuickStepChip(label: 'Goal', onTap: () => controller.text = '$stepTarget'),
                ],
              ),
              const SizedBox(height: CosarcSpacing.lg),
              FilledButton(
                onPressed: () async {
                  final value = int.tryParse(controller.text.trim()) ?? 0;
                  Navigator.pop(ctx);
                  await _logSteps(value);
                },
                child: const Text('Save steps'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        final eatCleanDone = _isFoodLoggedToday(box);
        final completed = _completedCount(eatCleanDone);
        final progress = completed / 4;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        CosarcSpacing.screenHorizontal,
                        topInset + 64,
                        CosarcSpacing.screenHorizontal,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_greeting, style: CosarcTypography.overline('')),
                                    Text(
                                      'Your\nContract',
                                      style: CosarcTypography.display(context),
                                    ),
                                  ],
                                ),
                              ),
                              CosarcGlass(
                                onTap: () => Navigator.of(context).pushFadeThrough(
                                  const ProfileScreen(),
                                ),
                                radius: CosarcSpacing.radiusPill,
                                blur: 12,
                                padding: const EdgeInsets.all(12),
                                child: const Icon(Icons.person_outline_rounded, size: 22),
                              ),
                            ],
                          ),
                          const SizedBox(height: CosarcSpacing.xxl),
                          _SignatureHeroRing(
                            progress: progress,
                            completed: completed,
                            isComplete: _contractComplete,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: CosarcSectionHeader(
                      overline: 'Today',
                      title: 'Four pillars',
                      subtitle: '$completed of 4 complete',
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CosarcSpacing.screenHorizontal,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _PillarRow(
                          index: 1,
                          title: 'Workout',
                          subtitle: workoutDone ? 'Session logged' : 'Log your training',
                          icon: Icons.fitness_center_rounded,
                          completed: workoutDone,
                          progress: workoutDone ? 1.0 : 0.0,
                          onTap: () async {
                            final result = await Navigator.of(context).pushFadeThrough(
                              const WorkoutLogScreen(),
                            );
                            if (result == true) await _loadData();
                          },
                        ),
                        _PillarRow(
                          index: 2,
                          title: 'Fuel',
                          subtitle: eatCleanDone ? 'Nutrition logged' : 'Track your meals',
                          icon: Icons.restaurant_rounded,
                          completed: eatCleanDone,
                          progress: eatCleanDone ? 1.0 : 0.0,
                          onTap: () => Navigator.of(context).pushFadeThrough(
                            const EnhancedNutritionScreen(),
                          ),
                        ),
                        _PillarRow(
                          index: 3,
                          title: 'Hydrate',
                          subtitle: '$waterMl ml · ${waterTarget ~/ 1000}L goal',
                          icon: Icons.water_drop_outlined,
                          completed: waterMl >= waterTarget,
                          progress: (waterMl / waterTarget).clamp(0.0, 1.0),
                          actionLabel: waterMl >= waterTarget ? null : '+300ml',
                          onAction: waterMl >= waterTarget ? null : () => _addWater(300),
                          onTap: waterMl >= waterTarget ? null : () => _addWater(300),
                        ),
                        _PillarRow(
                          index: 4,
                          title: 'Move',
                          subtitle: '$steps · $stepTarget goal',
                          icon: Icons.directions_walk_rounded,
                          completed: steps >= stepTarget,
                          progress: (steps / stepTarget).clamp(0.0, 1.0),
                          actionLabel: 'Log',
                          onAction: _showStepsSheet,
                          onTap: _showStepsSheet,
                        ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
                      child: CosarcGlass(
                        highlight: _contractComplete,
                        expand: true,
                        child: Column(
                          children: [
                            Icon(
                              _contractComplete
                                  ? Icons.auto_awesome_rounded
                                  : Icons.lock_outline_rounded,
                              color: _contractComplete
                                  ? CosarcColors.primary
                                  : CosarcColors.textTertiary,
                              size: 28,
                            ),
                            const SizedBox(height: CosarcSpacing.md),
                            Text(
                              _contractComplete
                                  ? 'Reflection unlocked'
                                  : 'Complete all four to unlock reflection',
                              textAlign: TextAlign.center,
                              style: CosarcTypography.title(context).copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: CosarcSpacing.xxs),
                            Text(
                              _contractComplete
                                  ? 'You showed up today. That is the work.'
                                  : '${4 - completed} remaining',
                              textAlign: TextAlign.center,
                              style: CosarcTypography.caption(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              Positioned(
                top: topInset + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: DynamicIslandStreak(
                    streak: currentStreak,
                    longestStreak: longestStreak,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SignatureHeroRing extends StatelessWidget {
  const _SignatureHeroRing({
    required this.progress,
    required this.completed,
    required this.isComplete,
  });

  final double progress;
  final int completed;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return CosarcGlass(
      expand: true,
      highlight: isComplete,
      padding: const EdgeInsets.all(CosarcSpacing.xxl),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: CosarcColors.glassFill(0.1),
                    valueColor: AlwaysStoppedAnimation(
                      isComplete ? CosarcColors.accent : CosarcColors.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: CosarcTypography.metric('').copyWith(fontSize: 24),
                    ),
                    Text(
                      '$completed/4',
                      style: CosarcTypography.caption(context).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: CosarcSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete ? 'Contract fulfilled' : 'In progress',
                  style: CosarcTypography.headline(context).copyWith(fontSize: 24),
                ),
                const SizedBox(height: CosarcSpacing.xs),
                Text(
                  'Complete every pillar before midnight to extend your streak.',
                  style: CosarcTypography.body(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarRow extends StatelessWidget {
  const _PillarRow({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.completed,
    required this.progress,
    this.onTap,
    this.onAction,
    this.actionLabel,
  });

  final int index;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool completed;
  final double progress;
  final VoidCallback? onTap;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
      child: CosarcGlass(
        onTap: onTap,
        highlight: completed,
        padding: const EdgeInsets.all(CosarcSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: completed
                    ? CosarcColors.primaryMuted
                    : CosarcColors.glassFill(0.06),
                borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
                border: Border.all(
                  color: completed
                      ? CosarcColors.primary.withOpacity(0.4)
                      : CosarcColors.border,
                ),
              ),
              child: Center(
                child: completed
                    ? const Icon(Icons.check_rounded, color: CosarcColors.primary, size: 20)
                    : Text(
                        '$index',
                        style: CosarcTypography.caption(context).copyWith(
                          color: CosarcColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: CosarcSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: CosarcColors.textTertiary),
                      const SizedBox(width: CosarcSpacing.xxs),
                      Text(title, style: CosarcTypography.title(context).copyWith(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: CosarcTypography.caption(context)),
                  const SizedBox(height: CosarcSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: CosarcColors.glassFill(0.1),
                      valueColor: AlwaysStoppedAnimation(
                        completed ? CosarcColors.accent : CosarcColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null && !completed) ...[
              const SizedBox(width: CosarcSpacing.sm),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: CosarcColors.brandSweep,
                    borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
                  ),
                  child: Text(
                    actionLabel!,
                    style: CosarcTypography.caption(context).copyWith(
                      color: CosarcColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ] else if (onTap != null && !completed) ...[
              const SizedBox(width: CosarcSpacing.sm),
              Icon(Icons.arrow_outward_rounded, color: CosarcColors.textTertiary, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickStepChip extends StatelessWidget {
  const _QuickStepChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: CosarcColors.surfaceHighlight,
      side: BorderSide(color: CosarcColors.border),
    );
  }
}
