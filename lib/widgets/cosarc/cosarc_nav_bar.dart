import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';

class CosarcNavDestination {
  const CosarcNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Arc-inspired floating dock — icon-first, label on selection.
class CosarcNavBar extends StatelessWidget {
  const CosarcNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  final List<CosarcNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        CosarcSpacing.xl,
        0,
        CosarcSpacing.xl,
        bottom > 0 ? bottom : CosarcSpacing.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CosarcSpacing.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: CosarcColors.glassFill(0.1),
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusXl),
              border: Border.all(color: CosarcColors.glassBorder(0.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: List.generate(destinations.length, (index) {
                final dest = destinations[index];
                final selected = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: CosarcMotion.medium,
                      curve: CosarcMotion.easeOut,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected ? CosarcColors.brandSweep : null,
                        color: selected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(CosarcSpacing.radiusLg),
                        boxShadow: selected
                            ? CosarcColors.glow(CosarcColors.primary, 0.15)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected ? dest.selectedIcon : dest.icon,
                            size: 22,
                            color: selected
                                ? CosarcColors.ink
                                : CosarcColors.textTertiary,
                          ),
                          if (selected) ...[
                            const SizedBox(height: 1),
                            Text(
                              dest.label,
                              style: CosarcTypography.caption(context).copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: CosarcColors.ink,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
