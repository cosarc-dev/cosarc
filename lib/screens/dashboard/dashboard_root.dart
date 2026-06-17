import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/cosarc_colors.dart';
import 'cosmos_screen.dart';
import 'my_gym_screen.dart';
import 'nutriwave_screen.dart';
import 'cosarc_ai_screen.dart';

class DashboardRoot extends StatefulWidget {
  const DashboardRoot({super.key});

  @override
  State<DashboardRoot> createState() => _DashboardRootState();
}

class _DashboardRootState extends State<DashboardRoot> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CosmosScreen(),
    MyGymScreen(),
    NutriwaveScreen(),
    CosarcAIScreen(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CosarcColors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: CosarcColors.black,
          border: Border(
            top: BorderSide(color: CosarcColors.border, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Cosmos',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.fitness_center_rounded,
                  label: 'My Gym',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutriwave',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.search_rounded,
                  label: 'AI',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(isSelected ? 8 : 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CosarcColors.gold.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: CosarcColors.gold.withOpacity(0.35),
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? CosarcColors.gold
                      : CosarcColors.textMuted,
                  size: isSelected ? 24 : 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? CosarcColors.gold
                      : CosarcColors.textMuted,
                  letterSpacing: 0.3,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
