import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/cosarc_colors.dart';

class NutriwaveScreen extends StatefulWidget {
  const NutriwaveScreen({super.key});

  @override
  State<NutriwaveScreen> createState() => _NutriwaveScreenState();
}

class _NutriwaveScreenState extends State<NutriwaveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.black,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: _buildIllustration(),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'NUTRIWAVE',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: CosarcColors.gold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'IS EVOLVING',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: CosarcColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Personalized meal intelligence,\n'
                      'adaptive nutrition planning,\n'
                      'and AI-powered guidance\n'
                      'are arriving soon.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.7,
                        color: CosarcColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Something extraordinary is cooking.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: CosarcColors.goldMuted,
                      ),
                    ),
                    const Spacer(flex: 2),
                    _buildWaitlistBadge(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            CosarcColors.gold.withOpacity(0.2),
            CosarcColors.gold.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: CosarcColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: 64,
            color: CosarcColors.gold.withOpacity(0.9),
          ),
          Positioned(
            bottom: 28,
            right: 28,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CosarcColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: CosarcColors.gold.withOpacity(0.5)),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: CosarcColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitlistBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: CosarcColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CosarcColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: CosarcColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'You\'re on the list — we\'ll notify you first',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: CosarcColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
