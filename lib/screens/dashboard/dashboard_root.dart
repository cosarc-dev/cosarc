import 'package:flutter/material.dart';
import 'cosmos_screen.dart';
import 'my_gym_screen.dart';
import 'nutriwave_screen.dart';
import 'cosarc_ai_screen.dart';

const Color cosarcPink = Color(0xFFE91E63);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
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
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.all(isSelected ? 8 : 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? cosarcPink.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? cosarcPink : Colors.white.withOpacity(0.5),
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? cosarcPink : Colors.white.withOpacity(0.5),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
