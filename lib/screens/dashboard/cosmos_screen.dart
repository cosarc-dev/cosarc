import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/dynamic_island_streak.dart';
import 'workout_log_screen.dart';
import 'enhanced_nutrition_screen.dart';
import 'profile_screen.dart';
import '../../models/food_log.dart';

const Color cosarcPink = Color(0xFFE91E63);

class CosmosScreen extends StatefulWidget {
  const CosmosScreen({super.key});

  @override
  State<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends State<CosmosScreen> {
  late VideoPlayerController _controller;
  bool workoutDone = false;
  int waterMl = 0;
  int steps = 3200;
  
  static const int waterTarget = 3000;
  static const int stepTarget = 10000;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _controller = VideoPlayerController.asset('assets/backgrounds/cosarc_intro.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) {
          _controller.play();
          setState(() {});
        }
      }).catchError((error) {
        debugPrint("Video Error: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isFoodLoggedToday() {
    final box = Hive.box<FoodLog>('daily_logs');
    final now = DateTime.now();
    return box.values.any((log) => 
      log.dateTime.day == now.day && 
      log.dateTime.month == now.month && 
      log.dateTime.year == now.year
    );
  }

  bool get _contractComplete {
    return workoutDone &&
           _isFoodLoggedToday() &&
           waterMl >= waterTarget &&
           steps >= stepTarget;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;

    return ValueListenableBuilder(
      valueListenable: Hive.box<FoodLog>('daily_logs').listenable(),
      builder: (context, Box<FoodLog> box, _) {
        bool eatCleanDone = _isFoodLoggedToday();

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
              child: Image.asset(
                  'assets/backgrounds/galaxy_bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero video section - NO DUPLICATE QUOTE
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: height * 0.65,
                      child: Stack(
                        children: [
                          // Video background
                          if (_controller.value.isInitialized)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _controller.value.size.width,
                                    height: _controller.value.size.height,
                                    child: VideoPlayer(_controller),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                ),
                              ),
                            ),
                          
                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black54,
                                    Colors.transparent,
                                    Colors.black87,
                                  ],
                                  stops: [0.0, 0.4, 1.0],
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                ),
                              ),
                            ),
                          ),
                          
                          // Top bar - using cosarc font style
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "cosarc",
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ProfileScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  
                  _buildSectionHeader("Today's Contract"),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  
                  _buildWorkoutCard(),
                  _buildFuelCard(eatCleanDone),
                  _buildWaterCard(),
                  _buildStepsCard(),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  
                  _buildSectionHeader("Reflection"),
                  _buildReflectionCard(),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
              
              // Dynamic Island - properly positioned
              Positioned(
                top: topInset + 12,
                left: 0,
                right: 0,
                child: const Center(
                  child: DynamicIslandStreak(streak: 7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard() {
    return _buildContractCard(
      title: "Workout Log",
      subtitle: workoutDone ? "Logged. Signal accepted." : "Tap to log workout.",
      completed: workoutDone,
      icon: Icons.fitness_center_rounded,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkoutLogScreen()),
        );
        if (result == true) {
          setState(() => workoutDone = true);
        }
      },
    );
  }

  Widget _buildFuelCard(bool completed) {
    return _buildContractCard(
      title: "Fuel Log",
      subtitle: completed ? "Fuel logged. Trajectory locked." : "Awaiting fuel input.",
      completed: completed,
      icon: Icons.restaurant_rounded,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EnhancedNutritionScreen()),
        );
      },
    );
  }

  Widget _buildWaterCard() {
    final progress = (waterMl / waterTarget).clamp(0.0, 1.0);
    return _buildProgressCard(
      title: "Water Intake Log • 3L",
      subtitle: "$waterMl ml logged",
      progress: progress,
      icon: Icons.water_drop_outlined,
      onAddPressed: () {
        setState(() {
          if (waterMl < waterTarget) {
            waterMl += 300;
          }
        });
      },
    );
  }

  Widget _buildStepsCard() {
    final progress = (steps / stepTarget).clamp(0.0, 1.0);
    return _buildProgressCard(
      title: "Steps • 10,000",
      subtitle: "$steps / $stepTarget steps",
      progress: progress,
      icon: Icons.directions_walk_rounded,
      showButton: false,
    );
  }

  Widget _buildContractCard({
    required String title,
    required String subtitle,
    required bool completed,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(completed ? 0.08 : 0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: completed 
                      ? cosarcPink.withOpacity(0.6)
                      : Colors.white.withOpacity(0.08),
                  width: completed ? 2 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (completed ? cosarcPink : Colors.white).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: completed ? cosarcPink : Colors.white.withOpacity(0.6),
                        size: 24,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      completed ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                      color: completed ? cosarcPink : Colors.white.withOpacity(0.3),
                      size: completed ? 28 : 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    VoidCallback? onAddPressed,
    bool showButton = true,
  }) {
    final completed = progress >= 1.0;
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(completed ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: completed 
                ? cosarcPink.withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: completed ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (completed ? cosarcPink : Colors.white).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: completed ? cosarcPink : Colors.white.withOpacity(0.6),
                    size: 24,
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
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showButton && onAddPressed != null)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: progress < 1.0 ? onAddPressed : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: progress < 1.0 
                              ? cosarcPink.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: progress < 1.0 
                                ? cosarcPink.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "+300ml",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: progress < 1.0 ? cosarcPink : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  completed ? cosarcPink : cosarcPink.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _contractComplete 
              ? cosarcPink.withOpacity(0.1)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _contractComplete 
                ? cosarcPink.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _contractComplete ? Icons.auto_awesome_rounded : Icons.lock_outline_rounded,
              color: _contractComplete ? cosarcPink : Colors.white.withOpacity(0.3),
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              _contractComplete 
                  ? "Reflection unlocked"
                  : "Complete today's contract to unlock",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: _contractComplete 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}