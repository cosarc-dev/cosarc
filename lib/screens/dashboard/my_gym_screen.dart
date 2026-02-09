import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

const Color cosarcPink = Color(0xFFE91E63);

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'MY GYM',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cosarcPink.withOpacity(0.15),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Check In/Out Card
                  _buildCheckInCard(),
                  
                  const SizedBox(height: 20),
                  
                  // Today's Session Stats
                  if (_checkInTime != null) ...[
                    _buildSessionStats(),
                    const SizedBox(height: 20),
                  ],
                  
                  // Quick Stats Row
                  _buildQuickStats(),
                  
                  const SizedBox(height: 28),
                  
                  // Membership Card
                  _buildMembershipCard(),
                  
                  const SizedBox(height: 28),
                  
                  // Gym Alerts
                  Text(
                    'Gym Alerts',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildAlertCard(
                    icon: Icons.celebration_rounded,
                    title: 'Special Class Tomorrow',
                    message: 'Yoga session at 7 AM with celebrity trainer',
                    color: Color(0xFF4CAF50),
                    time: '2h ago',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildAlertCard(
                    icon: Icons.build_rounded,
                    title: 'Maintenance Notice',
                    message: 'Treadmills will be serviced this Sunday',
                    color: Color(0xFFFF9800),
                    time: '1d ago',
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Features Section
                  Text(
                    'Features',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Attendance History',
                    subtitle: 'View your gym attendance records',
                    gradient: LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                    ),
                    onTap: () => _showAttendanceHistory(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildFeatureCard(
                    icon: Icons.schedule_rounded,
                    title: 'Class Schedule',
                    subtitle: 'Book your spot in group classes',
                    gradient: LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                    ),
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildFeatureCard(
                    icon: Icons.person_add_rounded,
                    title: 'Personal Trainer',
                    subtitle: 'Book sessions with certified trainers',
                    gradient: LinearGradient(
                      colors: [cosarcPink, cosarcPink.withOpacity(0.7)],
                    ),
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildFeatureCard(
                    icon: Icons.leaderboard_rounded,
                    title: 'Gym Leaderboard',
                    subtitle: 'Compete with other members',
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                    ),
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isCheckedIn
              ? [Color(0xFF4CAF50).withOpacity(0.2), Color(0xFF4CAF50).withOpacity(0.05)]
              : [cosarcPink.withOpacity(0.15), cosarcPink.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isCheckedIn 
              ? Color(0xFF4CAF50).withOpacity(0.3)
              : cosarcPink.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_isCheckedIn ? Color(0xFF4CAF50) : cosarcPink).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _isCheckedIn ? Icons.fitness_center_rounded : Icons.qr_code_scanner_rounded,
                  color: _isCheckedIn ? Color(0xFF4CAF50) : cosarcPink,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCheckedIn ? 'ACTIVE SESSION' : 'READY TO TRAIN',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: _isCheckedIn ? Color(0xFF4CAF50) : cosarcPink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isCheckedIn 
                          ? _formatDuration(_sessionDuration)
                          : 'Tap to check in',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isCheckedIn ? _endSession : _startSession,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isCheckedIn 
                        ? [Colors.red, Colors.red.withOpacity(0.8)]
                        : [cosarcPink, cosarcPink.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_isCheckedIn ? Colors.red : cosarcPink).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Text(
                    _isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Checked in at ${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          if (_checkOutTime != null)
            Text(
              'Out at ${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
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
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Streak',
            value: '5',
            icon: Icons.local_fire_department_rounded,
            color: Color(0xFFFF5722),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Total',
            value: '127',
            icon: Icons.emoji_events_rounded,
            color: Color(0xFFFFD700),
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
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    final daysLeft = 37;
    final progress = 1 - (daysLeft / 365);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD700).withOpacity(0.15),
            Color(0xFFFFD700).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Color(0xFFFFD700).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  color: Color(0xFFFFD700),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREMIUM MEMBER',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Annual Plan',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$daysLeft',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    'days left',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Renews on March 15, 2026',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              Text(
                'Auto-renew ON',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 18,
              ),
            ],
          ),
        ),
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
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Attendance History',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: 15,
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(Duration(days: index));
                  final checkIn = '${7 + index % 3}:${(index * 15) % 60}'.padLeft(2, '0');
                  final checkOut = '${8 + index % 2}:${(index * 20) % 60}'.padLeft(2, '0');
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
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
                            color: Color(0xFF4CAF50).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$checkIn - $checkOut',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${1 + index % 2}h ${(index * 15) % 60}m',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cosarcPink,
                          ),
                        ),
                      ],
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
