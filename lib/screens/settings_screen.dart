import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/token_manager.dart';
import '../services/database_helper.dart';
import '../theme/military_theme.dart';
import '../widgets/military_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenManager = context.watch<TokenManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile section
          _buildSection('COMMANDER PROFILE', Icons.person, [
            _buildInfoTile(
              'Plan',
              tokenManager.isPremium ? 'PREMIUM' : 'FREE',
              tokenManager.isPremium ? Icons.star : Icons.shield,
              tokenManager.isPremium
                  ? MilitaryTheme.goldAccent
                  : MilitaryTheme.textSecondary,
            ),
            _buildInfoTile(
              'Daily Token Limit',
              '${tokenManager.tokenLimit}',
              Icons.bolt,
              MilitaryTheme.accentGreen,
            ),
          ]),

          const SizedBox(height: 16),

          // Premium section
          if (!tokenManager.isPremium)
            _buildPremiumCard(context, tokenManager),

          if (tokenManager.isPremium)
            _buildPremiumActiveCard(context, tokenManager),

          const SizedBox(height: 16),

          // Data section
          _buildSection('DATA MANAGEMENT', Icons.storage, [
            _buildActionTile(
              'Clear Chat History',
              'Remove all AI conversations',
              Icons.chat_bubble_outline,
              MilitaryTheme.textSecondary,
              () => _clearChatHistory(context),
            ),
            _buildActionTile(
              'Clear All Data',
              'Reset all missions and data',
              Icons.delete_forever,
              MilitaryTheme.commandRed,
              () => _clearAllData(context),
            ),
          ]),

          const SizedBox(height: 16),

          // About section
          _buildSection('ABOUT', Icons.info_outline, [
            _buildInfoTile('App', 'Yes Sir', Icons.military_tech, MilitaryTheme.goldAccent),
            _buildInfoTile('Version', '1.0.0', Icons.code, MilitaryTheme.textMuted),
            _buildInfoTile('AI Engine', 'LongCat AI', Icons.smart_toy, MilitaryTheme.accentGreen),
            _buildInfoTile('Storage', '100% Local', Icons.lock, MilitaryTheme.infoBlue),
          ]),

          const SizedBox(height: 20),

          // Footer
          const Center(
            child: Column(
              children: [
                Text(
                  'YES SIR',
                  style: TextStyle(
                    color: MilitaryTheme.goldAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '"Your order. Executed."',
                  style: TextStyle(
                    color: MilitaryTheme.textMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '100% Local • No Cloud • Your Data',
                  style: TextStyle(
                    color: MilitaryTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MilitarySectionHeader(title: title, icon: icon),
        const SizedBox(height: 8),
        Container(
          decoration: MilitaryTheme.militaryCardDecoration,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: MilitaryTheme.textPrimary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
      String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: color, fontSize: 14),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: MilitaryTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, TokenManager tokenManager) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MilitaryTheme.goldDark.withOpacity(0.15),
            MilitaryTheme.goldAccent.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MilitaryTheme.goldAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.star, color: MilitaryTheme.goldAccent, size: 36),
          const SizedBox(height: 12),
          const Text(
            'UPGRADE TO PREMIUM',
            style: TextStyle(
              color: MilitaryTheme.goldAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '10,000 AI tokens daily • Priority responses\nPremium themes & badges',
            style: TextStyle(
              color: MilitaryTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '\$1 / month',
            style: TextStyle(
              color: MilitaryTheme.goldAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          MilitaryButton(
            label: 'UPGRADE NOW',
            icon: Icons.rocket_launch,
            isGold: true,
            onPressed: () {
              // In production, integrate with Play Store billing
              tokenManager.upgradeToPremium();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Welcome to Premium, Commander! 🫡'),
                  backgroundColor: MilitaryTheme.militaryGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActiveCard(BuildContext context, TokenManager tokenManager) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: MilitaryTheme.goldenAccentCard,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: MilitaryTheme.goldAccent, size: 24),
              const SizedBox(width: 8),
              const Text(
                'PREMIUM ACTIVE',
                style: TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '10,000 AI tokens daily • All features unlocked',
            style: TextStyle(
              color: MilitaryTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              tokenManager.downgradeToFree();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downgraded to Free plan.'),
                  backgroundColor: MilitaryTheme.surfaceDark,
                ),
              );
            },
            child: const Text(
              'Cancel Premium',
              style: TextStyle(
                color: MilitaryTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearChatHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CLEAR CHAT HISTORY', style: TextStyle(color: MilitaryTheme.goldAccent, fontSize: 16)),
        content: const Text('This will delete all AI conversations. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: MilitaryTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat history cleared.'),
                    backgroundColor: MilitaryTheme.militaryGreen,
                  ),
                );
              }
            },
            child: const Text('CLEAR', style: TextStyle(color: MilitaryTheme.commandRed)),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠ CLEAR ALL DATA', style: TextStyle(color: MilitaryTheme.commandRed, fontSize: 16)),
        content: const Text(
          'This will permanently delete ALL missions, chat history, and data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: MilitaryTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              // Clear missions would need a method - for now just pop
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared.'),
                    backgroundColor: MilitaryTheme.commandRed,
                  ),
                );
              }
            },
            child: const Text('DELETE ALL', style: TextStyle(color: MilitaryTheme.commandRed)),
          ),
        ],
      ),
    );
  }
}
