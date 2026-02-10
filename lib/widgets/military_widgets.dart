import 'package:flutter/material.dart';
import '../theme/military_theme.dart';

class TokenCounter extends StatelessWidget {
  final int tokensRemaining;
  final int tokenLimit;
  final bool isPremium;

  const TokenCounter({
    super.key,
    required this.tokensRemaining,
    required this.tokenLimit,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = tokensRemaining / tokenLimit;
    Color tokenColor;
    if (percentage > 0.5) {
      tokenColor = MilitaryTheme.accentGreen;
    } else if (percentage > 0.2) {
      tokenColor = MilitaryTheme.warningOrange;
    } else {
      tokenColor = MilitaryTheme.commandRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: MilitaryTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium
              ? MilitaryTheme.goldAccent.withOpacity(0.5)
              : MilitaryTheme.surfaceLight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.star, color: MilitaryTheme.goldAccent, size: 14),
            ),
          Icon(Icons.bolt, color: tokenColor, size: 16),
          const SizedBox(width: 4),
          Text(
            '$tokensRemaining',
            style: TextStyle(
              color: tokenColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            ' / $tokenLimit',
            style: const TextStyle(
              color: MilitaryTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class MilitaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isGold;
  final bool isSmall;

  const MilitaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isGold = false,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 20,
            vertical: isSmall ? 8 : 14,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isGold
                  ? [MilitaryTheme.goldDark, MilitaryTheme.goldAccent]
                  : [MilitaryTheme.darkGreen, MilitaryTheme.militaryGreen],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: (isGold ? MilitaryTheme.goldAccent : MilitaryTheme.accentGreen)
                    .withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isGold ? Colors.black : Colors.white,
                  size: isSmall ? 16 : 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isGold ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmall ? 12 : 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final int priorityIndex;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priorityIndex,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['LOW', 'MED', 'HIGH', 'CRIT'];
    final color = MilitaryTheme.getPriorityColor(priorityIndex);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MilitaryTheme.getPriorityIcon(priorityIndex),
            color: color,
            size: compact ? 10 : 14,
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              labels[priorityIndex],
              style: TextStyle(
                color: color,
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final int statusIndex;

  const StatusBadge({super.key, required this.statusIndex});

  @override
  Widget build(BuildContext context) {
    final labels = ['PENDING', 'IN PROGRESS', 'COMPLETED', 'FAILED'];
    final icons = [Icons.schedule, Icons.play_arrow, Icons.check_circle, Icons.cancel];
    final color = MilitaryTheme.getStatusColor(statusIndex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[statusIndex], color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            labels[statusIndex],
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class MilitarySectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const MilitarySectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: MilitaryTheme.goldAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: MilitaryTheme.goldAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: MilitaryTheme.textMuted, size: 64),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: MilitaryTheme.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: MilitaryTheme.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
