import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_section.dart';
import '../../widgets/cosarc/cosarc_button.dart';

class MyGymScreen extends StatefulWidget {
  const MyGymScreen({super.key});

  @override
  State<MyGymScreen> createState() => _MyGymScreenState();
}

class _MyGymScreenState extends State<MyGymScreen> {
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  Timer? _sessionTimer;
  Duration _sessionDuration = Duration.zero;

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isCheckedIn = true;
      _checkInTime = DateTime.now();
      _checkOutTime = null;
    });

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isCheckedIn) {
        setState(() {
          _sessionDuration = DateTime.now().difference(_checkInTime!);
        });
      }
    });
  }

  void _endSession() {
    setState(() {
      _isCheckedIn = false;
      _checkOutTime = DateTime.now();
    });
    _sessionTimer?.cancel();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  CosarcSpacing.screenHorizontal,
                  topInset + CosarcSpacing.lg,
                  CosarcSpacing.screenHorizontal,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GYM COMMAND',
                      style: CosarcTypography.overline('GYM COMMAND',
                          color: CosarcColors.primary.withOpacity(0.85)),
                    ),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(
                      'My Gym',
                      style: CosarcTypography.display(context)
                          .copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(
                      'Check in, track sessions, stay ahead',
                      style: CosarcTypography.caption(context),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
                child: SizedBox(height: CosarcSpacing.xxl)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              sliver: SliverToBoxAdapter(child: _buildCheckInCard()),
            ),
            if (_checkInTime != null) ...[
              const SliverToBoxAdapter(
                  child: SizedBox(height: CosarcSpacing.md)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.screenHorizontal,
                ),
                sliver: SliverToBoxAdapter(child: _buildSessionStats()),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: CosarcSpacing.xl)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              sliver: SliverToBoxAdapter(child: _buildQuickStats()),
            ),
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                overline: 'Membership',
                title: 'Premium access',
                subtitle: 'Annual plan · auto-renew on',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              sliver: SliverToBoxAdapter(child: _buildMembershipCard()),
            ),
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                title: 'Gym Alerts',
                subtitle: 'Updates from your facility',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAlertCard(
                    icon: Icons.celebration_rounded,
                    title: 'Special Class Tomorrow',
                    message: 'Yoga session at 7 AM with celebrity trainer',
                    color: CosarcColors.success,
                    time: '2h ago',
                  ),
                  const SizedBox(height: CosarcSpacing.sm),
                  _buildAlertCard(
                    icon: Icons.build_rounded,
                    title: 'Maintenance Notice',
                    message: 'Treadmills will be serviced this Sunday',
                    color: CosarcColors.warning,
                    time: '1d ago',
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(
              child: CosarcSectionHeader(
                title: 'Features',
                subtitle: 'Tools to level up your training',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: CosarcSpacing.sm,
                  crossAxisSpacing: CosarcSpacing.sm,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildListDelegate([
                  _buildFeatureCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Attendance History',
                    subtitle: 'View your gym attendance records',
                    gradient: const LinearGradient(
                      colors: [CosarcColors.info, Color(0xFF1976D2)],
                    ),
                    onTap: () => _showAttendanceHistory(),
                  ),
                  _buildFeatureCard(
                    icon: Icons.schedule_rounded,
                    title: 'Class Schedule',
                    subtitle: 'Book your spot in group classes',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                    ),
                    onTap: () => _showComingSoonDialog('Class Schedule'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.person_add_rounded,
                    title: 'Personal Trainer',
                    subtitle: 'Book sessions with certified trainers',
                    gradient: CosarcColors.brandSweep,
                    onTap: () => _showComingSoonDialog('Personal Trainer'),
                  ),
                  _buildFeatureCard(
                    icon: Icons.leaderboard_rounded,
                    title: 'Gym Leaderboard',
                    subtitle: 'Compete with other members',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                    ),
                    onTap: () => _showComingSoonDialog('Gym Leaderboard'),
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: CosarcGlass(
          padding: const EdgeInsets.all(CosarcSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_circle_rounded,
                  size: 48, color: CosarcColors.primary),
              const SizedBox(height: CosarcSpacing.md),
              Text(
                'Coming Soon',
                style: CosarcTypography.headline(context),
              ),
              const SizedBox(height: CosarcSpacing.sm),
              Text(
                '$featureName is currently under development and will be available in a future update.',
                style: CosarcTypography.body(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: CosarcSpacing.lg),
              CosarcButton(
                label: 'Got it',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInCard() {
    final activeColor =
        _isCheckedIn ? CosarcColors.success : CosarcColors.primary;

    return CosarcGlass(
      highlight: _isCheckedIn,
      expand: true,
      padding: const EdgeInsets.all(CosarcSpacing.xl),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                  boxShadow: CosarcColors.glow(activeColor, 0.5),
                ),
              ),
              const SizedBox(width: CosarcSpacing.xs),
              Text(
                _isCheckedIn ? 'ACTIVE SESSION' : 'READY TO TRAIN',
                style: CosarcTypography.overline(
                  _isCheckedIn ? 'ACTIVE SESSION' : 'READY TO TRAIN',
                  color: activeColor,
                ),
              ),
              const Spacer(),
              Icon(
                _isCheckedIn
                    ? Icons.fitness_center_rounded
                    : Icons.qr_code_scanner_rounded,
                color: activeColor.withOpacity(0.7),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: CosarcSpacing.xl),
          Text(
            _isCheckedIn ? _formatDuration(_sessionDuration) : '00:00:00',
            style: CosarcTypography.metric(
              _isCheckedIn ? _formatDuration(_sessionDuration) : '00:00:00',
              color: CosarcColors.textPrimary,
            ).copyWith(
              fontSize: 48,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: CosarcSpacing.xs),
          Text(
            _isCheckedIn ? 'Session elapsed' : 'Tap to check in',
            style: CosarcTypography.caption(context),
          ),
          const SizedBox(height: CosarcSpacing.xl),
          CosarcButton(
            label: _isCheckedIn ? 'Check Out' : 'Check In',
            icon: _isCheckedIn
                ? Icons.logout_rounded
                : Icons.qr_code_scanner_rounded,
            variant: _isCheckedIn
                ? CosarcButtonVariant.secondary
                : CosarcButtonVariant.primary,
            onPressed: _isCheckedIn ? _endSession : _startSession,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats() {
    return CosarcGlass(
      expand: true,
      padding: const EdgeInsets.symmetric(
        horizontal: CosarcSpacing.lg,
        vertical: CosarcSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(CosarcSpacing.xs),
            decoration: BoxDecoration(
              color: CosarcColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: CosarcColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: CosarcSpacing.sm),
          Expanded(
            child: Text(
              'Checked in at ${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}',
              style: CosarcTypography.caption(context),
            ),
          ),
          if (_checkOutTime != null)
            Text(
              'Out at ${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}',
              style: CosarcTypography.caption(context),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'This Month',
            value: '18',
            icon: Icons.check_circle_outline_rounded,
            color: CosarcColors.success,
          ),
        ),
        const SizedBox(width: CosarcSpacing.sm),
        Expanded(
          child: _buildStatCard(
            label: 'Streak',
            value: '5',
            icon: Icons.local_fire_department_rounded,
            color: CosarcColors.warning,
          ),
        ),
        const SizedBox(width: CosarcSpacing.sm),
        Expanded(
          child: _buildStatCard(
            label: 'Total',
            value: '127',
            icon: Icons.emoji_events_rounded,
            color: CosarcColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CosarcGlass(
      padding: const EdgeInsets.all(CosarcSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: CosarcSpacing.sm),
          Text(
            value,
            style:
                CosarcTypography.metric(value, color: CosarcColors.textPrimary)
                    .copyWith(fontSize: 28),
          ),
          const SizedBox(height: CosarcSpacing.xxs),
          Text(
            label,
            style: CosarcTypography.overline(label),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    const daysLeft = 37;
    const progress = 1 - (daysLeft / 365);

    return CosarcGlass(
      highlight: true,
      expand: true,
      padding: const EdgeInsets.all(CosarcSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(CosarcSpacing.sm),
                decoration: BoxDecoration(
                  color: CosarcColors.primaryMuted,
                  borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: CosarcColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: CosarcSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREMIUM MEMBER',
                      style: CosarcTypography.overline('PREMIUM MEMBER',
                          color: CosarcColors.primary),
                    ),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(
                      'Annual Plan',
                      style: CosarcTypography.title(context)
                          .copyWith(fontSize: 17),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$daysLeft',
                    style: CosarcTypography.metric('$daysLeft'),
                  ),
                  Text(
                    'days left',
                    style: CosarcTypography.caption(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: CosarcSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: CosarcColors.glassFill(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(CosarcColors.primary),
            ),
          ),
          const SizedBox(height: CosarcSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 14,
                color: CosarcColors.textTertiary,
              ),
              const SizedBox(width: CosarcSpacing.xs),
              Expanded(
                child: Text(
                  'Renews on March 15, 2026',
                  style: CosarcTypography.caption(context),
                ),
              ),
              Text(
                'Auto-renew ON',
                style: CosarcTypography.caption(context).copyWith(
                  color: CosarcColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    required String time,
  }) {
    return CosarcGlass(
      expand: true,
      padding: const EdgeInsets.all(CosarcSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(CosarcSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: CosarcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CosarcTypography.title(context).copyWith(fontSize: 15),
                ),
                const SizedBox(height: CosarcSpacing.xxs),
                Text(
                  message,
                  style: CosarcTypography.body(context).copyWith(fontSize: 13),
                ),
                const SizedBox(height: CosarcSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CosarcSpacing.sm,
                    vertical: CosarcSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(CosarcSpacing.radiusPill),
                  ),
                  child: Text(
                    time,
                    style: CosarcTypography.overline(time, color: color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final accent = (gradient as LinearGradient).colors.first;

    return CosarcGlass(
      onTap: onTap,
      padding: const EdgeInsets.all(CosarcSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(CosarcSpacing.sm),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
              boxShadow: CosarcColors.glow(accent, 0.2),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CosarcTypography.title(context).copyWith(fontSize: 15),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: CosarcSpacing.xxs),
              Text(
                subtitle,
                style: CosarcTypography.caption(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttendanceHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: CosarcColors.backgroundElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CosarcSpacing.radiusXl),
          ),
          border: Border.all(color: CosarcColors.borderStrong),
        ),
        child: Column(
          children: [
            const SizedBox(height: CosarcSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CosarcColors.textTertiary,
                borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
              ),
            ),
            const SizedBox(height: CosarcSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.screenHorizontal,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance History',
                    style:
                        CosarcTypography.title(context).copyWith(fontSize: 22),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: CosarcColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(CosarcSpacing.screenHorizontal),
                itemCount: 15,
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(Duration(days: index));
                  final checkIn =
                      '${7 + index % 3}:${(index * 15) % 60}'.padLeft(2, '0');
                  final checkOut =
                      '${8 + index % 2}:${(index * 20) % 60}'.padLeft(2, '0');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
                    child: CosarcGlass(
                      padding: const EdgeInsets.all(CosarcSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(CosarcSpacing.sm),
                            decoration: BoxDecoration(
                              color: CosarcColors.success.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(CosarcSpacing.radiusSm),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: CosarcColors.success,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: CosarcSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: CosarcTypography.title(context)
                                      .copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$checkIn - $checkOut',
                                  style: CosarcTypography.caption(context),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${1 + index % 2}h ${(index * 15) % 60}m',
                            style: CosarcTypography.caption(context).copyWith(
                              color: CosarcColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
