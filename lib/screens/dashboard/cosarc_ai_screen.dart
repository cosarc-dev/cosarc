import 'package:flutter/material.dart';
import '../../core/theme/cosarc_colors.dart';
import '../../core/theme/cosarc_motion.dart';
import '../../core/theme/cosarc_spacing.dart';
import '../../core/theme/cosarc_typography.dart';
import '../../features/cosarc_ai/models/chat_message.dart';
import '../../features/cosarc_ai/providers/cosarc_ai_provider.dart';
import '../../widgets/cosarc/cosarc_glass.dart';
import '../../widgets/cosarc/cosarc_loader.dart';
import '../../widgets/cosarc/cosarc_section.dart';

class CosarcAIScreen extends StatefulWidget {
  const CosarcAIScreen({super.key});

  @override
  State<CosarcAIScreen> createState() => _CosarcAIScreenState();
}

class _CosarcAIScreenState extends State<CosarcAIScreen> {
  final _provider = CosarcAiProvider();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  static const _suggestedQuestions = [
    'Best exercises for muscle gain?',
    'How much protein should I eat?',
    'Tips for better sleep recovery?',
  ];

  static const double _floatingNavClearance = 88;

  @override
  void initState() {
    super.initState();
    _provider.initialize();
    _provider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    if (_provider.streamingBuffer != null || !_provider.isSending) {
      _scrollToBottom();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(CosarcMotion.fast, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: CosarcMotion.medium,
          curve: CosarcMotion.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = preset ?? _messageController.text.trim();
    if (text.isEmpty || _provider.isSending) return;
    _messageController.clear();
    await _provider.send(text);
  }

  double _bottomPadding(BuildContext context) =>
      MediaQuery.of(context).padding.bottom + _floatingNavClearance;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final messages = _provider.messages;
    final streaming = _provider.streamingBuffer;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          SizedBox(height: topInset),
          _buildHeader(context),
          Expanded(
            child: messages.isEmpty && streaming == null
                ? _buildEmptyState(context)
                : _buildMessageList(context, messages, streaming),
          ),
          _buildInputField(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.md,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.sm,
      ),
      child: Row(
        children: [
          CosarcGlass(
            radius: CosarcSpacing.radiusMd,
            blur: 16,
            padding: const EdgeInsets.all(CosarcSpacing.sm),
            highlight: true,
            child: ShaderMask(
              shaderCallback: (b) => CosarcColors.brandSweep.createShader(b),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: CosarcSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COSARC AI', style: CosarcTypography.overline('COSARC AI')),
                Text('Fitness intelligence', style: CosarcTypography.caption(context)),
              ],
            ),
          ),
          if (_provider.messages.isNotEmpty)
            CosarcGlass(
              radius: CosarcSpacing.radiusPill,
              blur: 12,
              onTap: _provider.clearChat,
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.sm,
                vertical: CosarcSpacing.xs,
              ),
              child: Text(
                'Clear',
                style: CosarcTypography.caption(context).copyWith(
                  color: CosarcColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.xxxl,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.xl,
      ),
      child: Column(
        children: [
          _buildHeroOrb(),
          const SizedBox(height: CosarcSpacing.xxl),
          Text('Ask me anything', style: CosarcTypography.headline(context), textAlign: TextAlign.center),
          const SizedBox(height: CosarcSpacing.sm),
          Text(
            'Personalized fitness advice, workout tips, and nutrition guidance',
            textAlign: TextAlign.center,
            style: CosarcTypography.body(context),
          ),
          const SizedBox(height: CosarcSpacing.xxxl),
          const CosarcSectionHeader(overline: 'Suggestions', title: 'Try asking'),
          ..._suggestedQuestions.map(
            (q) => Padding(
              padding: const EdgeInsets.fromLTRB(
                CosarcSpacing.screenHorizontal,
                0,
                CosarcSpacing.screenHorizontal,
                CosarcSpacing.sm,
              ),
              child: CosarcGlass(
                expand: true,
                onTap: () => _sendMessage(q),
                padding: const EdgeInsets.all(CosarcSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        q,
                        style: CosarcTypography.body(context).copyWith(
                          color: CosarcColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_outward_rounded, color: CosarcColors.primary, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroOrb() {
    return CosarcGlass(
      radius: CosarcSpacing.radiusPill,
      blur: 24,
      highlight: true,
      padding: const EdgeInsets.all(CosarcSpacing.xxxl),
      child: ShaderMask(
        shaderCallback: (b) => CosarcColors.brandSweep.createShader(b),
        child: const Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white),
      ),
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    List<ChatMessage> messages,
    String? streaming,
  ) {
    final showStreaming = streaming != null && streaming.isNotEmpty;
    final itemCount = messages.length + (showStreaming ? 1 : 0) + (_provider.isSending && !showStreaming ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.md,
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.md,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < messages.length) {
          final msg = messages[index];
          return _buildMessageBubble(msg.text, msg.isUser);
        }
        if (showStreaming && index == messages.length) {
          return _buildMessageBubble(streaming, false, isStreaming: true);
        }
        return const Padding(
          padding: EdgeInsets.all(CosarcSpacing.lg),
          child: CosarcLoader(message: 'Thinking…'),
        );
      },
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, {bool isStreaming = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CosarcSpacing.md),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CosarcGlass(
              radius: CosarcSpacing.radiusSm,
              blur: 12,
              padding: const EdgeInsets.all(CosarcSpacing.xs),
              highlight: true,
              child: const Icon(Icons.auto_awesome_rounded, color: CosarcColors.primary, size: 16),
            ),
            const SizedBox(width: CosarcSpacing.sm),
          ],
          Flexible(
            child: CosarcGlass(
              radius: CosarcSpacing.radiusLg,
              highlight: isUser,
              padding: const EdgeInsets.symmetric(
                horizontal: CosarcSpacing.md,
                vertical: CosarcSpacing.sm + 2,
              ),
              child: Text(
                text,
                style: CosarcTypography.body(context).copyWith(
                  color: CosarcColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final hasText = _messageController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        CosarcSpacing.screenHorizontal,
        CosarcSpacing.sm,
        CosarcSpacing.screenHorizontal,
        _bottomPadding(context),
      ),
      child: CosarcGlass(
        expand: true,
        radius: CosarcSpacing.radiusPill,
        blur: 24,
        opacity: 0.06,
        padding: const EdgeInsets.fromLTRB(
          CosarcSpacing.lg,
          CosarcSpacing.xxs,
          CosarcSpacing.xxs,
          CosarcSpacing.xxs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: (_) => setState(() {}),
                enabled: !_provider.isSending,
                style: CosarcTypography.body(context).copyWith(
                  color: CosarcColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask Cosarc AI…',
                  hintStyle: CosarcTypography.body(context).copyWith(
                    color: CosarcColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: CosarcSpacing.sm),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            GestureDetector(
              onTap: _provider.isSending ? null : () => _sendMessage(),
              child: AnimatedContainer(
                duration: CosarcMotion.fast,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: hasText && !_provider.isSending
                      ? CosarcColors.brandSweep
                      : null,
                  color: hasText ? null : CosarcColors.glassFill(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: CosarcColors.border),
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: hasText ? CosarcColors.ink : CosarcColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
