import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/token_manager.dart';
import '../services/database_helper.dart';
import '../theme/military_theme.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenManager = context.watch<TokenManager>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section
          _buildSectionTitle('Language', Icons.language_rounded),
          const SizedBox(height: 10),
          _buildLanguageSelector(context, localeProvider),

          const SizedBox(height: 24),

          // Profile section
          _buildSectionTitle('Profile', Icons.person_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildInfoTile(
              'Plan',
              tokenManager.isPremium ? 'Premium' : 'Free',
              tokenManager.isPremium ? Icons.star_rounded : Icons.shield_rounded,
              tokenManager.isPremium
                  ? MilitaryTheme.goldAccent
                  : MilitaryTheme.textSecondary,
            ),
            _buildDivider(),
            _buildInfoTile(
              'Daily Tokens',
              '${tokenManager.tokenLimit}',
              Icons.bolt_rounded,
              MilitaryTheme.accentGreen,
            ),
          ]),

          const SizedBox(height: 20),

          // Premium section
          if (!tokenManager.isPremium)
            _buildPremiumCard(context, tokenManager),
          if (tokenManager.isPremium)
            _buildPremiumActiveCard(context, tokenManager),

          const SizedBox(height: 24),

          // Data section
          _buildSectionTitle('Data', Icons.storage_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildActionTile(
              'Clear Chat History',
              'Remove all AI conversations',
              Icons.chat_bubble_outline_rounded,
              MilitaryTheme.textSecondary,
              () => _clearChatHistory(context),
            ),
            _buildDivider(),
            _buildActionTile(
              'Clear All Data',
              'Reset all missions and data',
              Icons.delete_forever_rounded,
              MilitaryTheme.commandRed,
              () => _clearAllData(context),
            ),
          ]),

          const SizedBox(height: 24),

          // About section
          _buildSectionTitle('About', Icons.info_outline_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildInfoTile('App', 'Yes Sir', Icons.shield_rounded, MilitaryTheme.goldAccent),
            _buildDivider(),
            _buildInfoTile('Version', '1.0.0', Icons.code_rounded, MilitaryTheme.textMuted),
            _buildDivider(),
            _buildInfoTile('AI Engine', 'LongCat AI', Icons.smart_toy_rounded, MilitaryTheme.accentGreen),
            _buildDivider(),
            _buildInfoTile('Storage', '100% Local', Icons.lock_rounded, MilitaryTheme.infoBlue),
          ]),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Column(
              children: [
                const Text(
                  'Yes Sir',
                  style: TextStyle(
                    color: MilitaryTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your personal mission commander',
                  style: TextStyle(
                    color: MilitaryTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️',
                  style: TextStyle(
                    color: MilitaryTheme.textMuted.withOpacity(0.6),
                    fontSize: 11,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: MilitaryTheme.accentGreen, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: MilitaryTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16, color: MilitaryTheme.surfaceLight);
  }

  Widget _buildLanguageSelector(BuildContext context, LocaleProvider localeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: MilitaryTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: AppLocalizations.supportedLocales.map((locale) {
          final isSelected = localeProvider.locale.languageCode == locale.code;
          return InkWell(
            onTap: () => localeProvider.setLocale(locale.code),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? MilitaryTheme.accentGreen.withOpacity(0.08) : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    locale.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      locale.name,
                      style: TextStyle(
                        color: isSelected ? MilitaryTheme.accentGreen : MilitaryTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: MilitaryTheme.accentGreen, size: 22),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: color, fontSize: 14)),
                  Text(
                    subtitle,
                    style: const TextStyle(color: MilitaryTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 22),
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
            MilitaryTheme.goldAccent.withOpacity(0.08),
            MilitaryTheme.goldAccent.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MilitaryTheme.goldAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.star_rounded, color: MilitaryTheme.goldAccent, size: 36),
          const SizedBox(height: 12),
          const Text(
            'Upgrade to Premium',
            style: TextStyle(
              color: MilitaryTheme.goldAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '10,000 AI tokens daily\nPriority responses • Premium features',
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                tokenManager.upgradeToPremium();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Welcome to Premium! 🫡'),
                    backgroundColor: MilitaryTheme.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.rocket_launch_rounded, size: 20),
              label: const Text('Upgrade Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MilitaryTheme.goldAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
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
            children: const [
              Icon(Icons.star_rounded, color: MilitaryTheme.goldAccent, size: 24),
              SizedBox(width: 8),
              Text(
                'Premium Active',
                style: TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '10,000 AI tokens daily • All features unlocked',
            style: TextStyle(color: MilitaryTheme.textSecondary, fontSize: 12),
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
              style: TextStyle(color: MilitaryTheme.textMuted, fontSize: 12),
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
        title: const Text('Clear Chat History?', style: TextStyle(color: MilitaryTheme.textPrimary, fontSize: 18)),
        content: const Text('This will delete all AI conversations.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Chat history cleared ✓'),
                    backgroundColor: MilitaryTheme.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: MilitaryTheme.commandRed)),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?', style: TextStyle(color: MilitaryTheme.commandRed, fontSize: 18)),
        content: const Text(
          'This will permanently delete ALL missions, chat history, and data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data cleared'),
                    backgroundColor: MilitaryTheme.commandRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: const Text('Delete All', style: TextStyle(color: MilitaryTheme.commandRed)),
          ),
        ],
      ),
    );
  }
}
