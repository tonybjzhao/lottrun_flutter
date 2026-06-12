import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/analysis_style.dart';
import '../services/analysis_style_service.dart';
import '../services/background_notification_service.dart';
import '../services/insight_service.dart';
import '../services/locale_service.dart';
import '../services/result_notification_service.dart';

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
  TimeOfDay _notifScheduleTime = const TimeOfDay(
    hour: kDefaultNotifScheduleHour,
    minute: kDefaultNotifScheduleMinute,
  );
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
    final daily = await svc.getNotifPref(
      kNotifKeyDailyInsight,
      defaultValue: false,
    );
    final weekly = await svc.getNotifPref(kNotifKeyWeeklySummary);
    final scheduleTime = await svc.getNotificationScheduleTime();
    if (mounted) {
      setState(() {
        _notifResults = results;
        _notifMyPicks = myPicks;
        _notifDailyInsight = daily;
        _notifWeeklySummary = weekly;
        _notifScheduleTime = TimeOfDay(
          hour: scheduleTime.hour,
          minute: scheduleTime.minute,
        );
        _loaded = true;
      });
    }
  }

  Future<void> _setNotif(String key, bool value) async {
    await InsightService.instance.setNotifPref(key, value);
    if (key == kNotifKeyDailyInsight || key == kNotifKeyWeeklySummary) {
      await ResultNotificationService.instance
          .refreshScheduledInsightNotifications();
      await BackgroundNotificationService.instance.refreshRegistration();
    }
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notifScheduleTime,
    );
    if (picked == null) return;
    await InsightService.instance.setNotificationScheduleTime(
      hour: picked.hour,
      minute: picked.minute,
    );
    await ResultNotificationService.instance
        .refreshScheduledInsightNotifications();
    await BackgroundNotificationService.instance.refreshRegistration();
    if (mounted) {
      setState(() => _notifScheduleTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenSettingsTitle)),
      body: _loaded
          ? ListView(
              children: [
                // ── Notifications section ──────────────────────────
                _SectionHeader(label: l10n.settingsNotifications, theme: theme),
                _NotifTile(
                  icon: Icons.notifications_rounded,
                  title: l10n.settingsResults,
                  subtitle: l10n.settingsResultsSubtitle,
                  value: _notifResults,
                  onChanged: (v) {
                    setState(() => _notifResults = v);
                    _setNotif(kNotifKeyResults, v);
                  },
                  theme: theme,
                ),
                _NotifTile(
                  icon: Icons.bookmark_rounded,
                  title: l10n.settingsMyPicks,
                  subtitle: l10n.settingsMyPicksSubtitle,
                  value: _notifMyPicks,
                  onChanged: (v) {
                    setState(() => _notifMyPicks = v);
                    _setNotif(kNotifKeyMyPicks, v);
                  },
                  theme: theme,
                ),
                _NotifTile(
                  icon: Icons.lightbulb_outline_rounded,
                  title: l10n.settingsDailyInsights,
                  subtitle: l10n.settingsDailyInsightsSubtitle,
                  value: _notifDailyInsight,
                  onChanged: (v) {
                    setState(() => _notifDailyInsight = v);
                    _setNotif(kNotifKeyDailyInsight, v);
                  },
                  theme: theme,
                ),
                _NotifTile(
                  icon: Icons.calendar_today_rounded,
                  title: l10n.settingsWeeklySummary,
                  subtitle: l10n.settingsWeeklySummarySubtitle,
                  value: _notifWeeklySummary,
                  onChanged: (v) {
                    setState(() => _notifWeeklySummary = v);
                    _setNotif(kNotifKeyWeeklySummary, v);
                  },
                  theme: theme,
                ),
                ListTile(
                  onTap: _pickNotificationTime,
                  leading: _LeadingIcon(
                    color: theme.colorScheme.primaryContainer,
                    icon: Icons.schedule_rounded,
                    iconColor: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.settingsNotificationTime),
                  subtitle: Text(
                    l10n.settingsNotificationTimeSubtitle(
                      _notifScheduleTime.format(context),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: _pickNotificationTime,
                    tooltip: l10n.settingsNotificationTime,
                    icon: const Icon(Icons.edit_calendar_rounded),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    l10n.settingsMaxNotifications,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(100),
                      fontSize: 10,
                    ),
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),

                // ── Language section ─────────────────────────────────
                _SectionHeader(label: l10n.settingsLanguage, theme: theme),
                ListTile(
                  leading: _LeadingIcon(
                    color: theme.colorScheme.primaryContainer,
                    icon: Icons.language_rounded,
                    iconColor: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.settingsLanguage),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: LocaleService.instance.languageCode,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(l10n.languageEnglish),
                        ),
                        DropdownMenuItem(
                          value: 'zh',
                          child: Text(l10n.languageChinese),
                        ),
                        DropdownMenuItem(
                          value: 'fr',
                          child: Text(l10n.languageFrench),
                        ),
                        DropdownMenuItem(
                          value: 'es',
                          child: Text(l10n.languageSpanish),
                        ),
                        DropdownMenuItem(
                          value: 'de',
                          child: Text(l10n.languageGerman),
                        ),
                        DropdownMenuItem(
                          value: 'ja',
                          child: Text(l10n.languageJapanese),
                        ),
                      ],
                      onChanged: (code) {
                        if (code == null) return;
                        setState(() {});
                        LocaleService.instance.setLanguageCode(code);
                      },
                    ),
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),

                // ── Analysis Style section ────────────────────────────
                _SectionHeader(label: l10n.settingsAnalysisStyle, theme: theme),
                ListTile(
                  leading: _LeadingIcon(
                    color: theme.colorScheme.primaryContainer,
                    icon: Icons.analytics_outlined,
                    iconColor: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.settingsAnalysisStyle),
                  subtitle: Text(l10n.settingsAnalysisStyleSubtitle),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<AnalysisStyle>(
                      value: AnalysisStyleService.instance.style,
                      items: [
                        DropdownMenuItem(
                          value: AnalysisStyle.recentTrend,
                          child: Text(l10n.analysisStyleRecentTrend),
                        ),
                        DropdownMenuItem(
                          value: AnalysisStyle.balanced,
                          child: Text(l10n.analysisStyleBalanced),
                        ),
                        DropdownMenuItem(
                          value: AnalysisStyle.longTermPattern,
                          child: Text(l10n.analysisStyleLongTermPattern),
                        ),
                      ],
                      onChanged: (style) {
                        if (style == null) return;
                        setState(() {});
                        AnalysisStyleService.instance.setStyle(style);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                  child: Text(
                    l10n.analysisStyleDisclaimer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const Divider(indent: 16, endIndent: 16),

                // ── About section ──────────────────────────────────
                _SectionHeader(label: l10n.settingsAbout, theme: theme),
                ListTile(
                  leading: _LeadingIcon(
                    color: theme.colorScheme.surfaceContainerHighest,
                    icon: Icons.info_outline_rounded,
                    iconColor: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                  title: Text(l10n.settingsHistoricalResultsOnly),
                  subtitle: Text(
                    l10n.settingsHistoricalResultsOnlyBody,
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
  final Color? color;
  final IconData icon;
  final Color? iconColor;

  const _LeadingIcon({this.color, required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: iconColor ?? Colors.white),
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
      secondary: Icon(
        icon,
        size: 22,
        color: theme.colorScheme.onSurface.withAlpha(160),
      ),
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
