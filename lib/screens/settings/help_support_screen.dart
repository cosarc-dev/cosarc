import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _supportEmail = 'support@cosarc.app';

  static const _faqs = [
    (
      'What is the Daily Contract?',
      'Four pillars — workout, nutrition, water, and steps. Complete all four to fulfill your contract and grow your streak.',
    ),
    (
      'How does my streak work?',
      'Your streak increases when you fulfill your daily contract. Missing a day resets your current streak.',
    ),
    (
      'Can I log food offline?',
      'Yes. Food logs are stored locally and sync your nutrition pillar when you log meals.',
    ),
  ];

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $_supportEmail'),
        backgroundColor: CosarcColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: CosarcSpacing.screenHorizontal,
          ),
          children: [
            const SizedBox(height: CosarcSpacing.sm),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Text('Help & Support', style: CosarcTypography.headline(context)),
              ],
            ),
            const SizedBox(height: CosarcSpacing.xl),
            CosarcGlass(
              expand: true,
              onTap: () => _copyEmail(context),
              child: Row(
                children: [
                  const Icon(Icons.mail_outline_rounded, color: CosarcColors.primary),
                  const SizedBox(width: CosarcSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact support', style: CosarcTypography.title(context)),
                        Text(
                          _supportEmail,
                          style: CosarcTypography.caption(context),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.copy_rounded, color: CosarcColors.textTertiary, size: 18),
                ],
              ),
            ),
            const SizedBox(height: CosarcSpacing.xl),
            Text('FAQ', style: CosarcTypography.title(context)),
            const SizedBox(height: CosarcSpacing.md),
            ..._faqs.map(
              (faq) => Padding(
                padding: const EdgeInsets.only(bottom: CosarcSpacing.sm),
                child: CosarcGlass(
                  expand: true,
                  padding: const EdgeInsets.all(CosarcSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq.$1,
                        style: CosarcTypography.title(context).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: CosarcSpacing.xs),
                      Text(faq.$2, style: CosarcTypography.body(context)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: CosarcSpacing.huge),
          ],
        ),
      ),
    );
  }
}
