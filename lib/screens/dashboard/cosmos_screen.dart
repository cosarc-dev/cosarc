import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/dynamic_island_streak.dart';
import 'workout_log_screen.dart';

const Color cosarcPink = Color(0xFFE91E63);

class CosmosScreen extends StatefulWidget {
  const CosmosScreen({super.key});

  @override
  State<CosmosScreen> createState() => _CosmosScreenState();
}

class _CosmosScreenState extends State<CosmosScreen> {
  late VideoPlayerController _controller;

  bool workoutDone = false;
  bool eatCleanDone = false;
  int waterMl = 0;
  int steps = 3200;
  bool moodSubmitted = false;

  static const int waterTarget = 3000;
  static const int stepTarget = 10000;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/backgrounds/cosarc_intro.mp4',
    )
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get contractComplete =>
      workoutDone &&
      eatCleanDone &&
      waterMl >= waterTarget &&
      steps >= stepTarget;

  String timeState() {
    final h = DateTime.now().hour;
    if (h < 11) return "The system is stable — for now.";
    if (h < 17) return "Input pending.";
    if (h < 21) return "Stability is deteriorating.";
    return "Final correction window.";
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ================= HERO =================
            SliverToBoxAdapter(
              child: SizedBox(
                height: height * 0.70,
                width: double.infinity,
                child: Stack(
                  children: [
                    // 🎬 VIDEO
                    if (_controller.value.isInitialized)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(36),
                          bottomRight: Radius.circular(36),
                        ),
                        child: SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                        ),
                      ),

                    // 🌑 GRADIENT
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                              Colors.black,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),

                    // 🔠 HEADER
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "cosarc",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🧠 QUOTE (INSIDE HERO — SAFE)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 36,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "“",
                            style: TextStyle(
                              fontSize: 44,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "the quiet space\nbetween who you are\nand who you are meant to be.",
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.35,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "— cosarc",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ SAFE GAP — THIS FIXES EVERYTHING
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),

            // ================= CONTRACT =================
            _section("today’s contract"),
            _headline("Order does not sustain itself."),
            _hint(timeState()),

            _ruleWorkout(context),
            _ruleEatClean(),
            _ruleWater(),
            _ruleSteps(),

            _section("reflection"),
            _reflection(),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        // 🔥 DYNAMIC ISLAND
        Positioned(
          top: topInset + 8,
          left: 0,
          right: 0,
          child: const Center(
            child: DynamicIslandStreak(streak: 7),
          ),
        ),
      ],
    );
  }

  // ================= UI HELPERS =================

  static SliverPadding _section(String text) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static SliverToBoxAdapter _headline(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  static SliverToBoxAdapter _hint(String text) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  // ================= RULES =================

  SliverToBoxAdapter _ruleWorkout(BuildContext context) {
    return _ruleCard(
      title: "Workout",
      main: "The body degrades without resistance.",
      sub: workoutDone ? "Logged. Signal accepted." : "Tap to log workout.",
      completed: workoutDone,
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

  SliverToBoxAdapter _ruleEatClean() {
    return _ruleCard(
      title: "Eat clean",
      main: "Fuel determines trajectory.",
      sub: eatCleanDone
          ? "Verified automatically."
          : "Awaiting verification.",
      completed: eatCleanDone,
    );
  }

  SliverToBoxAdapter _ruleWater() {
    final progress = (waterMl / waterTarget).clamp(0.0, 1.0);
    return _ruleMeter(
      title: "Water · 3L",
      main: "Hydration sustains cognition.",
      sub: "$waterMl ml logged",
      progress: progress,
      action: () => setState(() => waterMl += 300),
    );
  }

  SliverToBoxAdapter _ruleSteps() {
    final progress = (steps / stepTarget).clamp(0.0, 1.0);
    return _ruleMeter(
      title: "Steps · 10,000",
      main: "Motion prevents decay.",
      sub: "$steps / $stepTarget",
      progress: progress,
    );
  }

  // ================= REFLECTION =================

  SliverToBoxAdapter _reflection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(24),
        ),
        child: contractComplete
            ? const Text("Reflection unlocked.")
            : const Text(
                "Reflection permitted once order is restored.",
                style: TextStyle(color: Colors.white54),
              ),
      ),
    );
  }

  // ================= COMPONENTS =================

  SliverToBoxAdapter _ruleCard({
    required String title,
    required String main,
    required String sub,
    required bool completed,
    VoidCallback? onTap,
  }) {
    return SliverToBoxAdapter(
      child: _shell(
        title: title,
        main: main,
        sub: sub,
        completed: completed,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  SliverToBoxAdapter _ruleMeter({
    required String title,
    required String main,
    required String sub,
    required double progress,
    VoidCallback? action,
  }) {
    return SliverToBoxAdapter(
      child: _shell(
        title: title,
        main: main,
        sub: sub,
        completed: progress >= 1,
        trailing: action == null
            ? null
            : GestureDetector(
                onTap: action,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("+300 ml"),
                ),
              ),
        progress: progress,
      ),
    );
  }

  Widget _shell({
    required String title,
    required String main,
    required String sub,
    required bool completed,
    Widget? trailing,
    double? progress,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: completed
                ? cosarcPink.withOpacity(0.6)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 10),
            Text(main, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(color: Colors.white70)),
            if (progress != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(cosarcPink),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
