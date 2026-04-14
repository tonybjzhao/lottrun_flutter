import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import 'lotto_ball.dart';

class ResultPanel extends StatelessWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final VoidCallback onSave;
  final bool isSaved;

  const ResultPanel({
    super.key,
    required this.pick,
    required this.lottery,
    required this.onSave,
    this.isSaved = false,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('d MMM yyyy · HH:mm').format(pick.createdAt);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.star_rounded,
                    color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${pick.style.label} · ${lottery.name}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              pick.style.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
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

            // ── Bonus ball (Powerball) ────────────────────────────
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

            // ── Fun disclaimer (caption style, no box) ───────────
            const SizedBox(height: 14),
            Text(
              'Generated for fun using historical patterns.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(90),
                fontStyle: FontStyle.italic,
              ),
            ),

            // ── Actions ──────────────────────────────────────────
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  timeStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(90),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: isSaved ? null : onSave,
                  icon: Icon(
                    isSaved ? Icons.check : Icons.bookmark_outline,
                    size: 15,
                  ),
                  label: Text(isSaved ? 'Saved' : 'Save'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 13),
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
