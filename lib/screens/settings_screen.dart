import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/token_manager.dart';
import '../services/database_helper.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenManager = context.watch<TokenManager>();
    final localeProvider = context.watch<LocaleProvider>();
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;
    final errorColor = theme.colorScheme.error;
    final secondary = theme.colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(title: Text(l.get('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(l.get('language'), Icons.language_rounded, primary, textColor),
          const SizedBox(height: 10),
          _buildLanguageDropdown(context, localeProvider, l),
          const SizedBox(height: 24),

          _buildSectionTitle(l.get('appearance'), Icons.palette_rounded, primary, textColor),
          const SizedBox(height: 10),
          _buildCardSection(context, [_buildThemeToggle(context, l)]),
          const SizedBox(height: 24),

          _buildSectionTitle(l.get('profile'), Icons.person_rounded, primary, textColor),
          const SizedBox(height: 10),
          _buildCardSection(context, [
          _buildInfoTile(context, l.get('plan'), tokenManager.isPremium ? l.get('premium') : l.get('free'), tokenManager.isPremium ? Icons.star_rounded : Icons.favorite_rounded, tokenManager.isPremium ? secondary : mutedColor),
            _buildDivider(context),
            _buildInfoTile(context, l.get('dailyTokens'), '${tokenManager.tokenLimit}', Icons.bolt_rounded, primary),
          ]),
          const SizedBox(height: 20),

          if (!tokenManager.isPremium) _buildPremiumCard(context, tokenManager, l),
          if (tokenManager.isPremium) _buildPremiumActiveCard(context, tokenManager, l),
          const SizedBox(height: 24),

          _buildSectionTitle(l.get('security'), Icons.lock_rounded, primary, textColor),
          const SizedBox(height: 10),
          _buildCardSection(context, [_buildAppLockTile(context, l)]),
          const SizedBox(height: 24),

          _buildSectionTitle(l.get('data'), Icons.storage_rounded, primary, textColor),
          const SizedBox(height: 10),
          _buildCardSection(context, [
            _buildActionTile(context, l.get('clearChat'), l.get('clearChatDesc'), Icons.chat_bubble_outline_rounded, mutedColor, () => _clearChatHistory(context, l)),
            _buildDivider(context),
            _buildActionTile(context, l.get('clearAllData'), l.get('clearAllDesc'), Icons.delete_forever_rounded, errorColor, () => _clearAllData(context, l)),
          ]),
          const SizedBox(height: 24),

          _buildSectionTitle(l.get('about'), Icons.info_outline_rounded, primary, textColor),
          const SizedBox(height: 10),
          _buildCardSection(context, [
            _buildInfoTile(context, l.get('appName'), 'Yes Sir', Icons.favorite_rounded, secondary),
            _buildDivider(context),
            _buildInfoTile(context, l.get('version'), '1.1.0', Icons.code_rounded, mutedColor),
            _buildDivider(context),
            _buildInfoTile(context, l.get('aiEngine'), l.get('smartAI'), Icons.auto_awesome_rounded, primary),
            _buildDivider(context),
            _buildInfoTile(context, l.get('storage'), l.get('localStorage'), Icons.lock_rounded, Colors.blue),
          ]),
          const SizedBox(height: 24),

          _buildSectionTitle('Legal', Icons.gavel_rounded, primary, textColor),
          const SizedBox(height: 10),
          _buildCardSection(context, [
            _buildLinkTile(context, 'Privacy Policy', Icons.privacy_tip_rounded, 'https://yessir-app.pages.dev/privacy.html'),
            _buildDivider(context),
            _buildLinkTile(context, 'Terms of Service', Icons.description_rounded, 'https://yessir-app.pages.dev/terms.html'),
          ]),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Text(l.get('appName'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(l.get('personalCommander'), style: TextStyle(color: mutedColor, fontSize: 12)),
                const SizedBox(height: 4),
                Text(l.get('madeWithLove'), style: TextStyle(color: mutedColor.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor.withOpacity(0.2));
  }

  Widget _buildLanguageDropdown(BuildContext context, LocaleProvider localeProvider, AppLocalizations l) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    final currentLocale = AppLocalizations.supportedLocales.firstWhere(
      (loc) => loc.code == localeProvider.locale.languageCode,
      orElse: () => AppLocalizations.supportedLocales.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentLocale.code,
            isExpanded: true,
            dropdownColor: theme.colorScheme.surface,
            icon: Icon(Icons.expand_more_rounded, color: primary),
            selectedItemBuilder: (ctx) {
              return AppLocalizations.supportedLocales.map((locale) {
                return Row(
                  children: [
                    Text(locale.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Text(locale.name, style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600)),
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
                    Expanded(child: Text(locale.name, style: TextStyle(color: isSelected ? primary : textColor, fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal))),
                    if (isSelected) Icon(Icons.check_circle_rounded, color: primary, size: 20),
                  ],
                ),
              );
            }).toList(),
            onChanged: (code) {
              if (code != null) localeProvider.setLocale(code);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, AppLocalizations l) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.get('theme'), style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 14)),
                Text(isDark ? l.get('darkMode') : l.get('lightMode'), style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
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
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isActive ? primary : Theme.of(context).textTheme.bodySmall?.color, size: 18),
      ),
    );
  }

  Widget _buildAppLockTile(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

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
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(hasPIN ? Icons.lock_rounded : Icons.lock_open_rounded, color: Colors.blue, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.get('appLock'), style: TextStyle(color: textColor, fontSize: 14)),
                      Text(l.get('appLockDesc'), style: TextStyle(color: mutedColor, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasPIN ? primary.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(hasPIN ? 'ON' : 'OFF', style: TextStyle(color: hasPIN ? primary : mutedColor, fontSize: 11, fontWeight: FontWeight.w600)),
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
    return (prefs.getString('app_pin') ?? '').isNotEmpty;
  }

  void _showSetPIN(BuildContext context, AppLocalizations l) {
    String pin = '';
    bool isConfirmStep = false;
    final pinController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(isConfirmStep ? l.get('confirmPIN') : l.get('setPIN'), style: const TextStyle(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                autofocus: true,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 24, letterSpacing: 10),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '• • • •',
                  hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 24, letterSpacing: 10),
                  counterText: '',
                ),
                onChanged: (value) {
                  if (value.length == 4) {
                    if (!isConfirmStep) {
                      pin = value;
                      pinController.clear();
                      setState(() => isConfirmStep = true);
                    } else {
                      if (pin == value) {
                        _savePIN(pin);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.get('pinSet')), behavior: SnackBarBehavior.floating));
                      } else {
                        pinController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.get('wrongPIN')), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating));
                        setState(() {
                          isConfirmStep = false;
                          pin = '';
                        });
                      }
                    }
                  }
                },
              ),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.get('cancel')))],
        ),
      ),
    );
  }

  void _showPINOptions(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.textTheme.bodySmall?.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
              title: Text(l.get('changePIN'), style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
              onTap: () { Navigator.pop(ctx); _showSetPIN(context, l); },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
              title: Text(l.get('removePIN'), style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                await _removePIN();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.get('pinRemoved')), behavior: SnackBarBehavior.floating));
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

  Widget _buildInfoTile(BuildContext context, String title, String value, IconData icon, Color color) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 14),
          Text(title, style: TextStyle(color: textColor, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: color, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: mutedColor, fontSize: 12)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, IconData icon, String url) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: primary, size: 18)),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 14))),
            Icon(Icons.open_in_new_rounded, color: primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, TokenManager tokenManager, AppLocalizations l) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;
    final primary = theme.colorScheme.primary;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_rounded, color: secondary, size: 36),
          const SizedBox(height: 12),
          Text(l.get('upgradePremium'), style: TextStyle(color: secondary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l.get('premiumDesc'), style: TextStyle(color: mutedColor, fontSize: 13, height: 1.4), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded, color: primary, size: 18),
                const SizedBox(width: 8),
                Text('Coming Soon!', style: TextStyle(color: primary, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Premium features are being prepared with love. Stay tuned! \u{1F496}',
            style: TextStyle(color: mutedColor, fontSize: 12, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActiveCard(BuildContext context, TokenManager tokenManager, AppLocalizations l) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: secondary, size: 24),
              const SizedBox(width: 8),
              Text(l.get('premiumActive'), style: TextStyle(color: secondary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.get('premiumUnlocked'), style: TextStyle(color: mutedColor, fontSize: 12)),
        ],
      ),
    );
  }

  void _clearChatHistory(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.get('clearChatConfirm'), style: const TextStyle(fontSize: 18)),
        content: Text(l.get('clearChatMsg')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.get('cancel'))),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.get('chatCleared')), behavior: SnackBarBehavior.floating));
              }
            },
            child: Text(l.get('clear'), style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context, AppLocalizations l) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.get('clearAllConfirm'), style: TextStyle(color: theme.colorScheme.error, fontSize: 18)),
        content: Text(l.get('clearAllMsg')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.get('cancel'))),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearChatHistory();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.get('allDataCleared')), backgroundColor: theme.colorScheme.error, behavior: SnackBarBehavior.floating));
              }
            },
            child: Text(l.get('deleteAll'), style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
