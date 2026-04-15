import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import 'lotto_ball.dart';

class ResultPanel extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final LotteryDraw? recentDraw; // for match-check display
  final VoidCallback onSave;
  final bool isSaved;

  const ResultPanel({
    super.key,
    required this.pick,
    required this.lottery,
    this.recentDraw,
    required this.onSave,
    this.isSaved = false,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _buildShareText() {
    final main = pick.mainNumbers.join('  ');
    final bonus = (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty)
        ? '\n+ Powerball: ${pick.bonusNumbers!.join(' ')}'
        : '';
    return '${pick.style.tagline} — ${lottery.name}\n\n$main$bonus\n\n'
        '${pick.style.taglineSubtitle}\n'
        'Generated for fun — LottFun 🎲';
  }

  String _buildCopyText() {
    final main = pick.mainNumbers.join('  ');
    final lines = <String>[
      '${pick.style.label} · ${lottery.name}',
      main,
      if (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty)
        'Powerball: ${pick.bonusNumbers!.join(' ')}',
      'Generated for fun — LottFun',
    ];
    return lines.join('\n');
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _buildCopyText()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _share() async {
    HapticFeedback.lightImpact();
    await Share.share(_buildShareText());
  }

  // ── Match check ────────────────────────────────────────────────────────────

  Widget? _buildMatchRow(ThemeData theme) {
    if (recentDraw == null) return null;
    final draw = recentDraw!;
    final matched =
        pick.mainNumbers.where((n) => draw.mainNumbers.contains(n)).toList();
    final bonusHit = pick.bonusNumbers != null &&
        draw.bonusNumbers != null &&
        pick.bonusNumbers!.any((n) => draw.bonusNumbers!.contains(n));
    final dateStr = DateFormat('d MMM yyyy').format(draw.drawDate);

    String label;
    Color color;
    if (matched.length >= 5 || (matched.length >= 4 && bonusHit)) {
      label = '🎯 ${matched.length} matched${bonusHit ? ' + PB' : ''}! Last draw $dateStr';
      color = Colors.green.shade700;
    } else if (matched.length >= 3) {
      label = '✅ ${matched.length} matched${bonusHit ? ' + PB' : ''}. Last draw $dateStr';
      color = theme.colorScheme.primary;
    } else if (matched.isNotEmpty) {
      label = '${matched.length} matched last draw ($dateStr)';
      color = theme.colorScheme.onSurface.withAlpha(140);
    } else {
      label = '0 matched last draw ($dateStr)';
      color = theme.colorScheme.onSurface.withAlpha(100);
    }

    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: matched.length >= 3 ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM yyyy · HH:mm').format(pick.createdAt);
    final matchRow = _buildMatchRow(theme);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emotional tagline ────────────────────────────────
            Text(
              '${pick.style.tagline} · ${lottery.name}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              pick.style.taglineSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: 16),

            // ── Main balls ───────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  pick.mainNumbers.map((n) => LottoBall(number: n)).toList(),
            ),

            // ── Bonus ball ───────────────────────────────────────
            if (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Powerball',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFD32F2F),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...pick.bonusNumbers!.map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: LottoBall(number: n, isBonus: true),
                    ),
                  ),
                ],
              ),
            ],

            // ── Match check ──────────────────────────────────────
            if (matchRow != null) ...[
              const SizedBox(height: 10),
              matchRow,
            ],

            // ── Disclaimer ───────────────────────────────────────
            const SizedBox(height: 10),
            Text(
              'Generated for fun using historical patterns.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(80),
                fontStyle: FontStyle.italic,
              ),
            ),

            // ── Actions ──────────────────────────────────────────
            const SizedBox(height: 10),
            Text(
              timeStr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(80),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share_rounded, size: 15),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaved ? null : onSave,
                    icon: Icon(
                      isSaved ? Icons.check : Icons.bookmark_outline,
                      size: 15,
                    ),
                    label: Text(isSaved ? 'Saved' : 'Save'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
