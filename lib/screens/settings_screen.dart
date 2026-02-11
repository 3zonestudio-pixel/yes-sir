import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_manager.dart';
import '../services/database_helper.dart';
import '../services/purchase_service.dart';
import '../theme/military_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenManager = context.watch<TokenManager>();
    final localeProvider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.get('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section
          _buildSectionTitle(l.get('language'), Icons.language_rounded),
          const SizedBox(height: 10),
          _buildLanguageDropdown(context, localeProvider, l),

          const SizedBox(height: 24),

          // Appearance section
          _buildSectionTitle(l.get('appearance'), Icons.palette_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildThemeToggle(context, l),
          ]),

          const SizedBox(height: 24),

          // Profile section
          _buildSectionTitle(l.get('profile'), Icons.person_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildInfoTile(
              l.get('plan'),
              tokenManager.isPremium ? l.get('premium') : l.get('free'),
              tokenManager.isPremium ? Icons.star_rounded : Icons.shield_rounded,
              tokenManager.isPremium
                  ? MilitaryTheme.goldAccent
                  : MilitaryTheme.textSecondary,
            ),
            _buildDivider(),
            _buildInfoTile(
              l.get('dailyTokens'),
              '${tokenManager.tokenLimit}',
              Icons.bolt_rounded,
              MilitaryTheme.accentGreen,
            ),
          ]),

          const SizedBox(height: 20),

          // Premium section
          if (!tokenManager.isPremium)
            _buildPremiumCard(context, tokenManager, l),
          if (tokenManager.isPremium)
            _buildPremiumActiveCard(context, tokenManager, l),

          const SizedBox(height: 24),

          // Security section
          _buildSectionTitle(l.get('security'), Icons.lock_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildAppLockTile(context, l),
          ]),

          const SizedBox(height: 24),

          // Data section
          _buildSectionTitle(l.get('data'), Icons.storage_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildActionTile(
              l.get('clearChat'),
              l.get('clearChatDesc'),
              Icons.chat_bubble_outline_rounded,
              MilitaryTheme.textSecondary,
              () => _clearChatHistory(context, l),
            ),
            _buildDivider(),
            _buildActionTile(
              l.get('clearAllData'),
              l.get('clearAllDesc'),
              Icons.delete_forever_rounded,
              MilitaryTheme.commandRed,
              () => _clearAllData(context, l),
            ),
          ]),

          const SizedBox(height: 24),

          // About section
          _buildSectionTitle(l.get('about'), Icons.info_outline_rounded),
          const SizedBox(height: 10),
          _buildCardSection([
            _buildInfoTile(l.get('appName'), 'Yes Sir', Icons.shield_rounded, MilitaryTheme.goldAccent),
            _buildDivider(),
            _buildInfoTile(l.get('version'), '1.0.0', Icons.code_rounded, MilitaryTheme.textMuted),
            _buildDivider(),
            _buildInfoTile(l.get('aiEngine'), l.get('smartAI'), Icons.smart_toy_rounded, MilitaryTheme.accentGreen),
            _buildDivider(),
            _buildInfoTile(l.get('storage'), l.get('localStorage'), Icons.lock_rounded, MilitaryTheme.infoBlue),
          ]),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  l.get('appName'),
                  style: const TextStyle(
                    color: MilitaryTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.get('personalCommander'),
                  style: const TextStyle(
                    color: MilitaryTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.get('madeWithLove'),
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

  Widget _buildLanguageDropdown(BuildContext context, LocaleProvider localeProvider, AppLocalizations l) {
    final currentLocale = AppLocalizations.supportedLocales.firstWhere(
      (loc) => loc.code == localeProvider.locale.languageCode,
      orElse: () => AppLocalizations.supportedLocales.first,
    );

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentLocale.code,
            isExpanded: true,
            dropdownColor: MilitaryTheme.cardBackground,
            icon: const Icon(Icons.expand_more_rounded, color: MilitaryTheme.accentGreen),
            selectedItemBuilder: (context) {
              return AppLocalizations.supportedLocales.map((locale) {
                return Row(
                  children: [
                    Text(locale.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Text(
                      locale.name,
                      style: const TextStyle(
                        color: MilitaryTheme.accentGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
            items: AppLocalizations.supportedLocales.map((locale) {
              final isSelected = localeProvider.locale.languageCode == locale.code;
              return DropdownMenuItem<String>(
                value: locale.code,
                child: Row(
                  children: [
                    Text(locale.flag, style: const TextStyle(fontSize: 22)),
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
                      const Icon(Icons.check_circle_rounded, color: MilitaryTheme.accentGreen, size: 20),
                  ],
                ),
              );
            }).toList(),
            onChanged: (code) {
              if (code != null) {
                localeProvider.setLocale(code);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, AppLocalizations l) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MilitaryTheme.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: MilitaryTheme.accentGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.get('theme'), style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14)),
                Text(
                  isDark ? l.get('darkMode') : l.get('lightMode'),
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(context, Icons.dark_mode_rounded, isDark, () => themeProvider.setDarkMode(true)),
                _buildThemeOption(context, Icons.light_mode_rounded, !isDark, () => themeProvider.setDarkMode(false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? MilitaryTheme.accentGreen.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isActive ? MilitaryTheme.accentGreen : Theme.of(context).textTheme.bodySmall?.color,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildAppLockTile(BuildContext context, AppLocalizations l) {
    return FutureBuilder<bool>(
      future: _isPinSet(),
      builder: (context, snapshot) {
        final hasPIN = snapshot.data ?? false;
        return InkWell(
          onTap: () {
            if (hasPIN) {
              _showPINOptions(context, l);
            } else {
              _showSetPIN(context, l);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MilitaryTheme.infoBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasPIN ? Icons.lock_rounded : Icons.lock_open_rounded,
                    color: MilitaryTheme.infoBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.get('appLock'), style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 14)),
                      Text(
                        l.get('appLockDesc'),
                        style: const TextStyle(color: MilitaryTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasPIN
                        ? MilitaryTheme.accentGreen.withOpacity(0.1)
                        : MilitaryTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasPIN ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: hasPIN ? MilitaryTheme.accentGreen : MilitaryTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_pin') != null;
  }

  void _showSetPIN(BuildContext context, AppLocalizations l) {
    String pin = '';
    String confirmPin = '';
    bool isConfirmStep = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: MilitaryTheme.cardBackground,
          title: Text(
            isConfirmStep ? l.get('confirmPIN') : l.get('setPIN'),
            style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                autofocus: true,
                style: const TextStyle(
                  color: MilitaryTheme.textPrimary,
                  fontSize: 24,
                  letterSpacing: 10,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '• • • •',
                  hintStyle: TextStyle(
                    color: MilitaryTheme.textMuted.withOpacity(0.5),
                    fontSize: 24,
                    letterSpacing: 10,
                  ),
                  counterText: '',
                ),
                onChanged: (value) {
                  if (value.length == 4) {
                    if (!isConfirmStep) {
                      pin = value;
                      setState(() => isConfirmStep = true);
                    } else {
                      confirmPin = value;
                      if (pin == confirmPin) {
                        _savePIN(pin);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.get('pinSet')),
                            backgroundColor: MilitaryTheme.accentGreen,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.get('wrongPIN')),
                            backgroundColor: MilitaryTheme.commandRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        setState(() {
                          isConfirmStep = false;
                          pin = '';
                          confirmPin = '';
                        });
                      }
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.get('cancel')),
            ),
          ],
        ),
      ),
    );
  }

  void _showPINOptions(BuildContext context, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MilitaryTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MilitaryTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: MilitaryTheme.accentGreen),
              title: Text(l.get('changePIN'), style: const TextStyle(color: MilitaryTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showSetPIN(context, l);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: MilitaryTheme.commandRed),
              title: Text(l.get('removePIN'), style: const TextStyle(color: MilitaryTheme.commandRed)),
              onTap: () async {
                await _removePIN();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.get('pinRemoved')),
                      backgroundColor: MilitaryTheme.accentGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePIN(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', pin);
  }

  Future<void> _removePIN() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_pin');
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

  Widget _buildPremiumCard(BuildContext context, TokenManager tokenManager, AppLocalizations l) {
    final purchaseService = context.watch<PurchaseService>();

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
          Text(
            l.get('upgradePremium'),
            style: const TextStyle(
              color: MilitaryTheme.goldAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.get('premiumDesc'),
            style: const TextStyle(
              color: MilitaryTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '\$1.00 / month',
            style: TextStyle(
              color: MilitaryTheme.accentGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: purchaseService.isPurchasing
                  ? null
                  : () async {
                      if (!purchaseService.isAvailable) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Store not available. Please try again later.'),
                            backgroundColor: MilitaryTheme.commandRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        return;
                      }
                      final success = await purchaseService.buyPremium();
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Purchase could not be started. Please try again.'),
                            backgroundColor: MilitaryTheme.commandRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
              icon: purchaseService.isPurchasing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.rocket_launch_rounded, size: 20),
              label: Text(purchaseService.isPurchasing ? 'Processing...' : l.get('upgradeNow')),
              style: ElevatedButton.styleFrom(
                backgroundColor: MilitaryTheme.goldAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActiveCard(BuildContext context, TokenManager tokenManager, AppLocalizations l) {
    final purchaseService = context.watch<PurchaseService>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: MilitaryTheme.goldenAccentCard,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: MilitaryTheme.goldAccent, size: 24),
              const SizedBox(width: 8),
              Text(
                l.get('premiumActive'),
                style: const TextStyle(
                  color: MilitaryTheme.goldAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.get('premiumUnlocked'),
            style: const TextStyle(color: MilitaryTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.get('cancelPremium'), style: const TextStyle(fontSize: 18)),
                  content: Text('Are you sure you want to cancel your premium subscription?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l.get('cancel')),
                    ),
                    TextButton(
                      onPressed: () async {
                        await purchaseService.cancelSubscription();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.get('premiumDowngraded')),
                              backgroundColor: MilitaryTheme.surfaceDark,
                            ),
                          );
                        }
                      },
                      child: Text(l.get('cancelPremium'), style: const TextStyle(color: MilitaryTheme.commandRed)),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              l.get('cancelPremium'),
              style: const TextStyle(color: MilitaryTheme.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _clearChatHistory(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.get('clearChatConfirm'), style: const TextStyle(color: MilitaryTheme.textPrimary, fontSize: 18)),
        content: Text(l.get('clearChatMsg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.get('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.get('chatCleared')),
                    backgroundColor: MilitaryTheme.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Text(l.get('clear'), style: const TextStyle(color: MilitaryTheme.commandRed)),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.get('clearAllConfirm'), style: const TextStyle(color: MilitaryTheme.commandRed, fontSize: 18)),
        content: Text(l.get('clearAllMsg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.get('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.get('allDataCleared')),
                    backgroundColor: MilitaryTheme.commandRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: Text(l.get('deleteAll'), style: const TextStyle(color: MilitaryTheme.commandRed)),
          ),
        ],
      ),
    );
  }
}
