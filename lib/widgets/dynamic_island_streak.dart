import 'package:flutter/material.dart';

const Color cosarcPink = Color(0xFFE91E63);

class DynamicIslandStreak extends StatefulWidget {
  final int streak;
  
  const DynamicIslandStreak({
    super.key,
    required this.streak,
  });

  @override
  State<DynamicIslandStreak> createState() => _DynamicIslandStreakState();
}

class _DynamicIslandStreakState extends State<DynamicIslandStreak> 
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500), // Smoother - Apple uses 400-500ms
      vsync: this,
    );
    
    // Apple-style spring curve
    final springCurve = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic, // Apple's signature curve
    );
    
    // FIXED: Responsive sizing - never overflow
    _widthAnimation = Tween<double>(begin: 140, end: 320).animate(springCurve);
    _heightAnimation = Tween<double>(begin: 38, end: 140).animate(springCurve);
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(springCurve);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get safe screen width
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: _toggleExpand,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          // CRITICAL: Constrain width to never overflow
          final safeMaxWidth = screenWidth - 48; // 24px padding each side
          final constrainedWidth = _widthAnimation.value > safeMaxWidth 
              ? safeMaxWidth 
              : _widthAnimation.value;
          
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: constrainedWidth,
              height: _heightAnimation.value,
              decoration: BoxDecoration(
                // Apple-style blur background
                color: Colors.black.withOpacity(0.95),
                borderRadius: BorderRadius.circular(
                  _isExpanded ? 36 : 19,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                  // Inner glow
                  BoxShadow(
                    color: _isExpanded 
                        ? cosarcPink.withOpacity(0.1)
                        : Colors.transparent,
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  _isExpanded ? 36 : 19,
                ),
                child: _isExpanded 
                    ? _buildExpandedContent() 
                    : _buildCompactContent(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated fire icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.95, end: 1.05),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFF6B35),
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.streak}',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'days',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fire icon with gradient
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF6B35),
                      Color(0xFFFF8C42),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF6B35).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Streak info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _opacityAnimation,
                      child: Text(
                        'STREAK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.streak} Days',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats row
          FadeTransition(
            opacity: _opacityAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniStat('Longest', '12', Icons.emoji_events_rounded),
                Container(
                  width: 0.5,
                  height: 30,
                  color: Colors.white.withOpacity(0.15),
                ),
                _buildMiniStat('Week', '5', Icons.calendar_today_rounded),
                Container(
                  width: 0.5,
                  height: 30,
                  color: Colors.white.withOpacity(0.15),
                ),
                _buildMiniStat('Month', '23', Icons.insert_chart_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: cosarcPink.withOpacity(0.8),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}