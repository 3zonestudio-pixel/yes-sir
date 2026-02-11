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
    final theme = Theme.of(context);
    Color tokenColor;
    if (percentage > 0.5) {
      tokenColor = theme.colorScheme.primary;
    } else if (percentage > 0.2) {
      tokenColor = Colors.orange;
    } else {
      tokenColor = theme.colorScheme.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.star_rounded, color: theme.colorScheme.secondary, size: 14),
            ),
          Icon(Icons.bolt_rounded, color: tokenColor, size: 16),
          const SizedBox(width: 4),
          Text('$tokensRemaining', style: TextStyle(color: tokenColor, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(' / $tokenLimit', style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 14 : 22, vertical: isSmall ? 10 : 14),
          decoration: BoxDecoration(
            color: isGold ? secondary : primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: (isGold ? secondary : primary).withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: isGold ? Colors.black87 : Colors.white, size: isSmall ? 16 : 20),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(color: isGold ? Colors.black87 : Colors.white, fontWeight: FontWeight.w600, fontSize: isSmall ? 12 : 14)),
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

  const PriorityBadge({super.key, required this.priorityIndex, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final labels = ['Low', 'Med', 'High', 'Crit'];
    final color = MilitaryTheme.getPriorityColor(priorityIndex);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(MilitaryTheme.getPriorityIcon(priorityIndex), color: color, size: compact ? 10 : 14),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(labels[priorityIndex], style: TextStyle(color: color, fontSize: compact ? 9 : 11, fontWeight: FontWeight.w600)),
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
    final labels = ['Pending', 'In Progress', 'Completed', 'Failed'];
    final icons = [Icons.schedule_rounded, Icons.play_circle_outline_rounded, Icons.check_circle_rounded, Icons.cancel_rounded];
    final color = MilitaryTheme.getStatusColor(statusIndex);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[statusIndex], color: color, size: 13),
          const SizedBox(width: 4),
          Text(labels[statusIndex], style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
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

  const EmptyStateWidget({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final mutedColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(icon, color: mutedColor, size: 48),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: mutedColor, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
