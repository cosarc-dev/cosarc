import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cosarc_colors.dart';

enum CosarcButtonVariant { primary, secondary, ghost, destructive }

class CosarcButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CosarcButtonVariant variant;
  final IconData? icon;
  final bool expand;

  const CosarcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = CosarcButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  @override
  State<CosarcButton> createState() => _CosarcButtonState();
}

class _CosarcButtonState extends State<CosarcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) => _scaleController.reverse();
  void _handleTapCancel() => _scaleController.reverse();

  void _handleTap() {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    BorderSide? border;

    switch (widget.variant) {
      case CosarcButtonVariant.primary:
        bg = enabled ? CosarcColors.gold : CosarcColors.gold.withOpacity(0.3);
        fg = CosarcColors.black;
        break;
      case CosarcButtonVariant.secondary:
        bg = CosarcColors.card;
        fg = CosarcColors.textPrimary;
        border = const BorderSide(color: CosarcColors.border);
        break;
      case CosarcButtonVariant.ghost:
        bg = Colors.transparent;
        fg = CosarcColors.textSecondary;
        border = const BorderSide(color: CosarcColors.border);
        break;
      case CosarcButtonVariant.destructive:
        bg = CosarcColors.error.withOpacity(0.12);
        fg = CosarcColors.error;
        border = BorderSide(color: CosarcColors.error.withOpacity(0.3));
        break;
    }

    final child = ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: border ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: enabled ? _handleTap : null,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: BorderRadius.circular(14),
          splashColor: CosarcColors.gold.withOpacity(0.12),
          child: Container(
            width: widget.expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.variant == CosarcButtonVariant.primary
                          ? CosarcColors.black
                          : CosarcColors.gold,
                    ),
                  )
                : Row(
                    mainAxisSize:
                        widget.expand ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 20),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.label,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: fg,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    return child;
  }
}
