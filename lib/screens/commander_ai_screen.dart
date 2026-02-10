import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

      // Handle AI actions (like creating missions)
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
      setState(() {
        _messages.add(ChatMessage(
          role: ChatRole.soldier,
          content: "Sir, encountered an error during execution. Please retry your order.",
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
          // Top bar with token counter
          _buildTopBar(tokenManager),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcomeScreen()
                : _buildMessageList(),
          ),

          // Quick commands
          _buildQuickCommands(),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTopBar(TokenManager tokenManager) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: MilitaryTheme.cardBackground,
        border: Border(
          bottom: BorderSide(color: MilitaryTheme.surfaceLight, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MilitaryTheme.militaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.military_tech, color: MilitaryTheme.goldAccent, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PVT. LONGCAT',
                style: TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'READY FOR ORDERS',
                style: TextStyle(
                  color: MilitaryTheme.accentGreen,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
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
                    MilitaryTheme.militaryGreen.withOpacity(0.3),
                    MilitaryTheme.darkGreen.withOpacity(0.3),
                  ],
                ),
                border: Border.all(
                  color: MilitaryTheme.goldAccent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.military_tech,
                color: MilitaryTheme.goldAccent,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'YES SIR',
              style: TextStyle(
                color: MilitaryTheme.goldAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'YOUR ORDER. EXECUTED.',
              style: TextStyle(
                color: MilitaryTheme.textSecondary,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Private LongCat reporting for duty.\nGive your first order, Commander.',
              style: TextStyle(
                color: MilitaryTheme.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

    return Align(
      alignment: isCommander ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCommander
              ? MilitaryTheme.militaryGreen.withOpacity(0.3)
              : MilitaryTheme.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCommander
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isCommander
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: Border.all(
            color: isCommander
                ? MilitaryTheme.accentGreen.withOpacity(0.2)
                : MilitaryTheme.surfaceLight,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCommander ? Icons.person : Icons.military_tech,
                  size: 14,
                  color: isCommander
                      ? MilitaryTheme.accentGreen
                      : MilitaryTheme.goldAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  isCommander ? 'COMMANDER' : 'PVT. LONGCAT',
                  style: TextStyle(
                    color: isCommander
                        ? MilitaryTheme.accentGreen
                        : MilitaryTheme.goldAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
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
                height: 1.4,
              ),
            ),
            if (message.tokensUsed > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '⚡ ${message.tokensUsed} tokens',
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: MilitaryTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MilitaryTheme.surfaceLight, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.military_tech, size: 14, color: MilitaryTheme.goldAccent),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              child: _TypingDots(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCommands() {
    final commands = [
      ('📊 Status', 'Status report'),
      ('📋 Plan', 'Plan my day'),
      ('⚡ Priority', 'Prioritize my tasks'),
      ('💪 Motivate', 'Motivate me'),
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: commands.map((cmd) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: InkWell(
              onTap: () {
                _inputController.text = cmd.$2;
                _sendCommand();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: MilitaryTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MilitaryTheme.surfaceLight,
                  ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: MilitaryTheme.cardBackground,
        border: Border(
          top: BorderSide(color: MilitaryTheme.surfaceLight, width: 0.5),
        ),
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
                  hintText: 'Give your order, Commander...',
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
                gradient: const LinearGradient(
                  colors: [MilitaryTheme.darkGreen, MilitaryTheme.militaryGreen],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                icon: Icon(
                  _isProcessing ? Icons.hourglass_top : Icons.send_rounded,
                  color: MilitaryTheme.goldAccent,
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
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: MilitaryTheme.goldAccent,
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
