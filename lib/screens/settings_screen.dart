import 'package:flutter/material.dart';
import '../services/premium_service.dart';
import '../widgets/premium_paywall_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Premium section ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text(
              'Analysis',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ListenableBuilder(
            listenable: PremiumService.instance,
            builder: (context, _) {
              final isPremium = PremiumService.instance.isPremium;
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics_rounded,
                      size: 18, color: Colors.white),
                ),
                title: const Text('Advanced Analysis Mode'),
                subtitle: Text(
                  isPremium
                      ? 'Unlocked — deeper patterns, top 10 similar draws, no ads'
                      : 'Deeper historical analysis, saved picks tracking, no ads',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
                trailing: isPremium
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(
                              color: Colors.green.shade300, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Unlocked',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: isPremium
                    ? null
                    : () => showPremiumPaywall(context),
              );
            },
          ),
          const Divider(indent: 16, endIndent: 16),

          // ── About section ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              'About',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.info_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurface.withAlpha(160)),
            ),
            title: const Text('Post-draw analysis only'),
            subtitle: Text(
              'All analysis is based on historical draw data. Nothing here predicts results or improves odds.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
