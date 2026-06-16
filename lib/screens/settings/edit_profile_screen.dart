import 'package:flutter/material.dart';
import '../../core/supabase_config.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosarc/cosarc_button.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_input.dart';
import '../../widgets/cosarc/cosarc_loader.dart';
import '../../widgets/cosarc/cosarc_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _memberId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _memberId = await _authService.getMemberId();
      if (_memberId != null) {
        final member = await supabase
            .from('members')
            .select('name')
            .eq('id', _memberId!)
            .maybeSingle();
        _nameController.text = member?['name']?.toString() ?? '';
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _toast('Enter your display name', isError: true);
      return;
    }
    if (_memberId == null) return;

    setState(() => _isSaving = true);
    try {
      await supabase
          .from('members')
          .update({'name': name})
          .eq('id', _memberId!)
          .timeout(const Duration(seconds: 10));
      if (mounted) {
        _toast('Profile updated');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _toast('Could not save profile', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? CosarcColors.error : CosarcColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CosarcScaffold(
      body: SafeArea(
        child: _isLoading
            ? const CosarcLoader(message: 'Loading profile…')
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CosarcSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: CosarcSpacing.sm),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Text('Edit profile', style: CosarcTypography.headline(context)),
                      ],
                    ),
                    const SizedBox(height: CosarcSpacing.xxl),
                    CosarcGlass(
                      expand: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Display name', style: CosarcTypography.caption(context)),
                          const SizedBox(height: CosarcSpacing.md),
                          CosarcInput(
                            controller: _nameController,
                            label: 'Name',
                            hint: 'Your name',
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CosarcButton(
                      label: 'Save changes',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _save,
                    ),
                    const SizedBox(height: CosarcSpacing.huge),
                  ],
                ),
              ),
      ),
    );
  }
}
