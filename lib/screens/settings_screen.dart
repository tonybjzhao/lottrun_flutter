import 'package:flutter/material.dart';
import '../services/insight_service.dart';
import '../services/premium_service.dart';
import '../widgets/premium_paywall_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifResults = true;
  bool _notifMyPicks = true;
  bool _notifDailyInsight = false;
  bool _notifWeeklySummary = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final svc = InsightService.instance;
    final results = await svc.getNotifPref(kNotifKeyResults);
    final myPicks = await svc.getNotifPref(kNotifKeyMyPicks);
    final daily = await svc.getNotifPref(kNotifKeyDailyInsight, defaultValue: false);
    final weekly = await svc.getNotifPref(kNotifKeyWeeklySummary);
    if (mounted) {
      setState(() {
        _notifResults = results;
        _notifMyPicks = myPicks;
        _notifDailyInsight = daily;
        _notifWeeklySummary = weekly;
        _loaded = true;
      });
    }
  }

  Future<void> _setNotif(String key, bool value) async {
    await InsightService.instance.setNotifPref(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loaded
          ? ListView(
              children: [
                // ── Premium section ────────────────────────────────
                _SectionHeader(label: 'Analysis', theme: theme),
                ListenableBuilder(
                  listenable: PremiumService.instance,
                  builder: (context, _) {
                    final isPremium = PremiumService.instance.isPremium;
                    return ListTile(
                      leading: _LeadingIcon(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.analytics_rounded,
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
                          ? _UnlockedBadge(theme: theme)
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: isPremium
                          ? null
                          : () => showPremiumPaywall(context),
                    );
                  },
                ),
                const Divider(indent: 16, endIndent: 16),

                // ── Notifications section ──────────────────────────
                _SectionHeader(label: 'Notifications', theme: theme),
                _NotifTile(
                  icon: Icons.notifications_rounded,
                  title: 'Results',
                  subtitle: 'When draw results are available for your saved picks',
                  value: _notifResults,
                  onChanged: (v) {
                    setState(() => _notifResults = v);
                    _setNotif(kNotifKeyResults, v);
                  },
                  theme: theme,
                ),
                _NotifTile(
                  icon: Icons.bookmark_rounded,
                  title: 'My Picks',
                  subtitle: 'When your saved numbers appear in recent results',
                  value: _notifMyPicks,
                  onChanged: (v) {
                    setState(() => _notifMyPicks = v);
                    _setNotif(kNotifKeyMyPicks, v);
                  },
                  theme: theme,
                ),
                _NotifTile(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Daily Insights',
                  subtitle: 'One short trend observation per day',
                  value: _notifDailyInsight,
                  onChanged: (v) {
                    setState(() => _notifDailyInsight = v);
                    _setNotif(kNotifKeyDailyInsight, v);
                  },
                  theme: theme,
                ),
                _NotifTile(
                  icon: Icons.calendar_today_rounded,
                  title: 'Weekly Summary',
                  subtitle: 'A brief weekly pattern summary every Sunday',
                  value: _notifWeeklySummary,
                  onChanged: (v) {
                    setState(() => _notifWeeklySummary = v);
                    _setNotif(kNotifKeyWeeklySummary, v);
                  },
                  theme: theme,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'Max 2 notifications per day total.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(100),
                      fontSize: 10,
                    ),
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),

                // ── About section ──────────────────────────────────
                _SectionHeader(label: 'About', theme: theme),
                ListTile(
                  leading: _LeadingIcon(
                    color: theme.colorScheme.surfaceContainerHighest,
                    icon: Icons.info_outline_rounded,
                    iconColor: theme.colorScheme.onSurface.withAlpha(160),
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
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SectionHeader({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(120),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final Gradient? gradient;
  final Color? color;
  final IconData icon;
  final Color? iconColor;

  const _LeadingIcon({
    this.gradient,
    this.color,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: iconColor ?? Colors.white),
    );
  }
}

class _UnlockedBadge extends StatelessWidget {
  final ThemeData theme;
  const _UnlockedBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Unlocked',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.green.shade700,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon,
          size: 22, color: theme.colorScheme.onSurface.withAlpha(160)),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(140),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
