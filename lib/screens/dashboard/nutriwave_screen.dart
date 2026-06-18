import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_section.dart';

class NutriwaveScreen extends StatefulWidget {
  const NutriwaveScreen({super.key});

  @override
  State<NutriwaveScreen> createState() => _NutriwaveScreenState();
}

class _NutriwaveScreenState extends State<NutriwaveScreen> {
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All',
    'Protein Bowls',
    'Salads',
    'Smoothies',
    'Meal Prep',
  ];

  static const double _floatingNavClearance = 100;
  static const double _cartBarHeight = 64;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Editorial header
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
                        'NUTRIWAVE',
                        style: CosarcTypography.overline('NUTRIWAVE'),
                      ),
                      const SizedBox(height: CosarcSpacing.xs),
                      Text(
                        'Fresh\nFuel',
                        style: CosarcTypography.display(context).copyWith(
                          fontSize: 40,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: CosarcSpacing.xs),
                      Text(
                        'Healthy meals, delivered fresh',
                        style: CosarcTypography.body(context),
                      ),
                      const SizedBox(height: CosarcSpacing.xl),
                      // Glass search bar
                      CosarcGlass(
                        expand: true,
                        radius: CosarcSpacing.radiusPill,
                        blur: 20,
                        padding: const EdgeInsets.symmetric(
                          horizontal: CosarcSpacing.lg,
                          vertical: CosarcSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: CosarcColors.textTertiary,
                              size: 22,
                            ),
                            const SizedBox(width: CosarcSpacing.sm),
                            Expanded(
                              child: Text(
                                'Search healthy meals...',
                                style: CosarcTypography.caption(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Location & delivery
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CosarcSpacing.screenHorizontal,
                    CosarcSpacing.xl,
                    CosarcSpacing.screenHorizontal,
                    0,
                  ),
                  child: CosarcGlass(
                    expand: true,
                    radius: CosarcSpacing.radiusLg,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(CosarcSpacing.xs),
                          decoration: BoxDecoration(
                            color: CosarcColors.primaryMuted,
                            borderRadius:
                                BorderRadius.circular(CosarcSpacing.radiusSm),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: CosarcColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: CosarcSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivering to',
                                style: CosarcTypography.caption(context),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Home - Pune, Maharashtra',
                                style: CosarcTypography.title(context).copyWith(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: CosarcSpacing.sm,
                            vertical: CosarcSpacing.xxs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: CosarcColors.success.withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(CosarcSpacing.radiusSm),
                            border: Border.all(
                              color: CosarcColors.success.withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: CosarcColors.success,
                              ),
                              const SizedBox(width: CosarcSpacing.xxs),
                              Text(
                                '30 min',
                                style: CosarcTypography.caption(context).copyWith(
                                  color: CosarcColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Horizontal category pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      CosarcSpacing.screenHorizontal,
                      CosarcSpacing.lg,
                      CosarcSpacing.screenHorizontal,
                      0,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCategory == index;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < _categories.length - 1
                              ? CosarcSpacing.xs
                              : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = index),
                          child: CosarcGlass(
                            highlight: isSelected,
                            radius: CosarcSpacing.radiusPill,
                            blur: isSelected ? 16 : 12,
                            padding: const EdgeInsets.symmetric(
                              horizontal: CosarcSpacing.lg,
                              vertical: CosarcSpacing.sm,
                            ),
                            child: Text(
                              _categories[index],
                              style: CosarcTypography.caption(context).copyWith(
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? CosarcColors.primary
                                    : CosarcColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: CosarcSectionHeader(
                  overline: 'Menu',
                  title: 'Chef picks',
                  subtitle: 'Macro-balanced, gym-ready meals',
                ),
              ),

              // Premium meal cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.screenHorizontal,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMenuItem(
                      name: 'Grilled Chicken Power Bowl',
                      description:
                          'Grilled chicken, quinoa, roasted veggies, tahini',
                      price: '₹349',
                      calories: '520 kcal',
                      protein: '45g protein',
                      image: '🍗',
                      rating: 4.8,
                      isVeg: false,
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    _buildMenuItem(
                      name: 'Mediterranean Quinoa Salad',
                      description:
                          'Quinoa, cucumber, tomato, feta, olives, lemon dressing',
                      price: '₹289',
                      calories: '380 kcal',
                      protein: '12g protein',
                      image: '🥗',
                      rating: 4.9,
                      isVeg: true,
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    _buildMenuItem(
                      name: 'Peanut Butter Protein Smoothie',
                      description:
                          'Banana, peanut butter, protein powder, almond milk',
                      price: '₹199',
                      calories: '350 kcal',
                      protein: '25g protein',
                      image: '🥤',
                      rating: 4.7,
                      isVeg: true,
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    _buildMenuItem(
                      name: 'Paneer Tikka Wrap',
                      description:
                          'Tandoori paneer, whole wheat wrap, mint chutney',
                      price: '₹249',
                      calories: '420 kcal',
                      protein: '22g protein',
                      image: '🌯',
                      rating: 4.6,
                      isVeg: true,
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    _buildMenuItem(
                      name: 'Weekly Muscle Gain Pack',
                      description: '7 high-protein meals delivered daily',
                      price: '₹2,499',
                      calories: '2800 kcal/day',
                      protein: '180g/day',
                      image: '📦',
                      rating: 5.0,
                      isVeg: false,
                      isCombo: true,
                    ),
                    SizedBox(
                      height: _floatingNavClearance +
                          _cartBarHeight +
                          bottomInset +
                          CosarcSpacing.xl,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Floating cart bar above nav
          Positioned(
            left: CosarcSpacing.screenHorizontal,
            right: CosarcSpacing.screenHorizontal,
            bottom: _floatingNavClearance + bottomInset,
            child: _buildCartBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBar() {
    return CosarcGlass(
      expand: true,
      radius: CosarcSpacing.radiusPill,
      blur: 28,
      opacity: 0.1,
      onTap: () => _showComingSoonDialog('Cart View'),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: CosarcColors.brandSweep,
              borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
              boxShadow: CosarcColors.glow(CosarcColors.primary, 0.2),
            ),
            alignment: Alignment.center,
            child: Text(
              '3',
              style: CosarcTypography.caption(context).copyWith(
                color: CosarcColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: CosarcSpacing.sm),
          Expanded(
            child: Text(
              'View Cart',
              style: CosarcTypography.title(context).copyWith(fontSize: 16),
            ),
          ),
          Text(
            '₹837',
            style: CosarcTypography.title(context).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: CosarcSpacing.xs),
          const Icon(
            Icons.arrow_forward_rounded,
            color: CosarcColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String name,
    required String description,
    required String price,
    required String calories,
    required String protein,
    required String image,
    required double rating,
    required bool isVeg,
    bool isCombo = false,
  }) {
    return CosarcGlass(
      expand: true,
      radius: CosarcSpacing.radiusXl,
      onTap: () => _showFoodDetail(
        name,
        description,
        price,
        calories,
        protein,
        image,
        isVeg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CosarcColors.surfaceHighlight,
                      CosarcColors.surfaceElevated,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(CosarcSpacing.radiusLg),
                  border: Border.all(color: CosarcColors.borderStrong),
                ),
                alignment: Alignment.center,
                child: Text(image, style: const TextStyle(fontSize: 44)),
              ),
              const SizedBox(width: CosarcSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildVegIndicator(isVeg, size: 14),
                        if (isCombo) ...[
                          const SizedBox(width: CosarcSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: CosarcSpacing.xs,
                              vertical: CosarcSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: CosarcColors.primaryMuted,
                              borderRadius:
                                  BorderRadius.circular(CosarcSpacing.radiusSm),
                              border: Border.all(
                                color: CosarcColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'COMBO',
                              style: CosarcTypography.overline('COMBO').copyWith(
                                color: CosarcColors.primary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        _buildRatingChip(rating),
                      ],
                    ),
                    const SizedBox(height: CosarcSpacing.xs),
                    Text(
                      name,
                      style: CosarcTypography.title(context).copyWith(
                        fontSize: 17,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: CosarcSpacing.xxs),
                    Text(
                      description,
                      style: CosarcTypography.caption(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CosarcSpacing.md),
          Row(
            children: [
              _buildMacroChip(calories, CosarcColors.textTertiary),
              const SizedBox(width: CosarcSpacing.xs),
              _buildMacroChip(protein, CosarcColors.protein),
            ],
          ),
          const SizedBox(height: CosarcSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                price,
                style: CosarcTypography.metric(price, color: CosarcColors.textPrimary)
                    .copyWith(fontSize: 22),
              ),
              CosarcButton(
                label: 'ADD',
                expand: false,
                onPressed: () => _showComingSoonDialog('Add to Cart'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVegIndicator(bool isVeg, {double size = 16}) {
    final color = isVeg ? CosarcColors.success : CosarcColors.error;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: size * 0.38,
          height: size * 0.38,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CosarcSpacing.xs,
        vertical: CosarcSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: CosarcColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: CosarcColors.success),
          const SizedBox(width: 3),
          Text(
            rating.toString(),
            style: CosarcTypography.caption(context).copyWith(
              color: CosarcColors.success,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CosarcSpacing.xs,
        vertical: CosarcSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(CosarcSpacing.radiusSm),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: CosarcTypography.caption(context).copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showFoodDetail(
    String name,
    String description,
    String price,
    String calories,
    String protein,
    String image,
    bool isVeg,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: CosarcColors.backgroundElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CosarcSpacing.radiusXl + 6),
          ),
          border: Border.all(color: CosarcColors.borderStrong),
        ),
        child: Column(
          children: [
            const SizedBox(height: CosarcSpacing.sm),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: CosarcColors.textTertiary,
                borderRadius: BorderRadius.circular(CosarcSpacing.radiusPill),
              ),
            ),
            const SizedBox(height: CosarcSpacing.xl),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(CosarcSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CosarcGlass(
                        radius: CosarcSpacing.radiusXl,
                        padding: const EdgeInsets.all(CosarcSpacing.xxxl),
                        child: Text(image, style: const TextStyle(fontSize: 88)),
                      ),
                    ),
                    const SizedBox(height: CosarcSpacing.xl),
                    _buildVegIndicator(isVeg, size: 20),
                    const SizedBox(height: CosarcSpacing.sm),
                    Text(name, style: CosarcTypography.headline(context)),
                    const SizedBox(height: CosarcSpacing.xs),
                    Text(description, style: CosarcTypography.body(context)),
                    const SizedBox(height: CosarcSpacing.xl),
                    Text(
                      'Nutrition Info',
                      style: CosarcTypography.title(context),
                    ),
                    const SizedBox(height: CosarcSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNutritionCard(
                            'Calories',
                            calories,
                            CosarcColors.primary,
                          ),
                        ),
                        const SizedBox(width: CosarcSpacing.sm),
                        Expanded(
                          child: _buildNutritionCard(
                            'Protein',
                            protein,
                            CosarcColors.protein,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CosarcSpacing.xxl),
                    CosarcButton(
                      label: 'Add to Cart • $price',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String label, String value, Color color) {
    return CosarcGlass(
      expand: true,
      radius: CosarcSpacing.radiusLg,
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: CosarcTypography.overline(label),
          ),
          const SizedBox(height: CosarcSpacing.xxs),
          Text(
            value,
            style: CosarcTypography.title(context).copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CosarcColors.backgroundElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CosarcSpacing.radiusLg),
          side: BorderSide(color: CosarcColors.borderStrong),
        ),
        title: Text(
          'Coming Soon',
          style: CosarcTypography.headline(context),
        ),
        content: Text(
          '$feature is currently under development and will be available in a future update.',
          style: CosarcTypography.body(context),
        ),
        actions: [
          CosarcButton(
            label: 'OK',
            expand: false,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
