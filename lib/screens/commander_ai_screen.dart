import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../models/mission.dart';
import '../services/ai_service.dart';
import '../services/database_helper.dart';
import '../services/token_manager.dart';
import '../providers/mission_provider.dart';
import '../theme/military_theme.dart';
import '../widgets/military_widgets.dart';

class CommanderAIScreen extends StatefulWidget {
  const CommanderAIScreen({super.key});

  @override
  State<CommanderAIScreen> createState() => _CommanderAIScreenState();
}

class _CommanderAIScreenState extends State<CommanderAIScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  late AIService _aiService;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await DatabaseHelper.instance.getChatMessages();
    setState(() {
      _messages = messages;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendCommand() async {
    final command = _inputController.text.trim();
    if (command.isEmpty || _isProcessing) return;

    final tokenManager = context.read<TokenManager>();
    _aiService = AIService(tokenManager: tokenManager);

    setState(() {
      _isProcessing = true;
      _messages.add(ChatMessage(
        role: ChatRole.commander,
        content: command,
      ));
    });

    _inputController.clear();
    _scrollToBottom();

    try {
      final response = await _aiService.processCommand(command);

      for (var action in response.actions) {
        if (action.type == AIActionType.createMission ||
            action.type == AIActionType.createReminder) {
          final mission = Mission(
            title: action.data['title'] as String,
            priority: action.data['priority'] as MissionPriority? ?? MissionPriority.medium,
            dueDate: action.data['dueDate'] as DateTime?,
          );
          await DatabaseHelper.instance.insertMission(mission);
          if (mounted) {
            context.read<MissionProvider>().addMission(mission);
          }
        }
      }

      setState(() {
        _messages.add(ChatMessage(
          role: ChatRole.soldier,
          content: response.message,
          tokensUsed: response.tokensUsed,
        ));
        _isProcessing = false;
      });
    } catch (e) {
      final l = AppLocalizations.of(context);
      setState(() {
        _messages.add(ChatMessage(
          role: ChatRole.soldier,
          content: l.get('somethingWrong'),
          tokensUsed: 0,
        ));
        _isProcessing = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final tokenManager = context.watch<TokenManager>();

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(tokenManager),
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : _buildMessageList(),
          ),
          _buildQuickCommands(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTopBar(TokenManager tokenManager) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MilitaryTheme.accentGreen.withOpacity(0.2),
                  MilitaryTheme.militaryGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: MilitaryTheme.accentGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.get('aiTitle'),
                  style: const TextStyle(
                    color: MilitaryTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: MilitaryTheme.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      l.get('onlineReady'),
                      style: const TextStyle(
                        color: MilitaryTheme.accentGreen,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TokenCounter(
            tokensRemaining: tokenManager.tokensRemaining,
            tokenLimit: tokenManager.tokenLimit,
            isPremium: tokenManager.isPremium,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    MilitaryTheme.accentGreen.withOpacity(0.15),
                    MilitaryTheme.militaryGreen.withOpacity(0.08),
                  ],
                ),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: MilitaryTheme.accentGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.get('yourAIAdvisor'),
              style: const TextStyle(
                color: MilitaryTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.get('aiSubtitle'),
              style: const TextStyle(
                color: MilitaryTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l.get('aiDescription'),
              style: const TextStyle(
                color: MilitaryTheme.textMuted,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('📋 ${l.get('suggestPlanDay')}'),
                _buildSuggestionChip('🔥 ${l.get('suggestBreakDown')}'),
                _buildSuggestionChip('📊 ${l.get('suggestHowAmI')}'),
                _buildSuggestionChip('💡 ${l.get('suggestTips')}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return InkWell(
      onTap: () {
        _inputController.text = label.replaceAll(RegExp(r'[^\w\s]'), '').trim();
        _sendCommand();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: MilitaryTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MilitaryTheme.surfaceLight),
        ),
        child: Text(
          label,
          style: const TextStyle(color: MilitaryTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length + (_isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isProcessing) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isCommander = message.role == ChatRole.commander;
    final l = AppLocalizations.of(context);

    return Align(
      alignment: isCommander ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCommander
              ? MilitaryTheme.accentGreen.withOpacity(0.15)
              : MilitaryTheme.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isCommander
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: isCommander
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCommander ? Icons.person_rounded : Icons.smart_toy_rounded,
                  size: 14,
                  color: isCommander
                      ? MilitaryTheme.accentGreen
                      : MilitaryTheme.goldAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  isCommander ? l.get('you') : l.get('aiTitle'),
                  style: TextStyle(
                    color: isCommander
                        ? MilitaryTheme.accentGreen
                        : MilitaryTheme.goldAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.content,
              style: const TextStyle(
                color: MilitaryTheme.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (message.tokensUsed > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '⚡ ${message.tokensUsed} ${l.get('tokens')}',
                  style: const TextStyle(
                    color: MilitaryTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final l = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: MilitaryTheme.cardBackground,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, size: 14, color: MilitaryTheme.goldAccent),
            const SizedBox(width: 10),
            SizedBox(
              width: 40,
              child: _TypingDots(),
            ),
            const SizedBox(width: 4),
            Text(
              l.get('thinking'),
              style: const TextStyle(color: MilitaryTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCommands() {
    final l = AppLocalizations.of(context);
    final commands = [
      ('📊 ${l.get('status')}', l.get('statusReport')),
      ('📋 ${l.get('planDay')}', l.get('planMyDay')),
      ('🔥 ${l.get('prioritize')}', l.get('prioritizeMyTasks')),
      ('🧩 ${l.get('breakDownBtn')}', l.get('breakDownMyTasks')),
      ('💡 ${l.get('tips')}', l.get('giveTips')),
      ('📝 ${l.get('templates')}', l.get('showTemplates')),
      ('💪 ${l.get('motivate')}', l.get('motivateMe')),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: commands.map((cmd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
            child: InkWell(
              onTap: () {
                _inputController.text = cmd.$2;
                _sendCommand();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: MilitaryTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MilitaryTheme.surfaceLight),
                ),
                child: Text(
                  cmd.$1,
                  style: const TextStyle(
                    color: MilitaryTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: l.get('askAnything'),
                  hintStyle: TextStyle(
                    color: MilitaryTheme.textMuted.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: MilitaryTheme.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendCommand(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MilitaryTheme.accentGreen,
                    MilitaryTheme.militaryGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: MilitaryTheme.accentGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isProcessing ? Icons.hourglass_top_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _isProcessing ? null : _sendCommand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final value = (_controller.value + delay) % 1.0;
            final opacity = (value < 0.5) ? value * 2 : 2 - value * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: MilitaryTheme.accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
