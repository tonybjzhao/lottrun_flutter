import 'package:flutter/material.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../services/insight_service.dart';

class DailyInsightBanner extends StatefulWidget {
  final Lottery lottery;
  final List<LotteryDraw> draws;

  const DailyInsightBanner({
    super.key,
    required this.lottery,
    required this.draws,
  });

  @override
  State<DailyInsightBanner> createState() => _DailyInsightBannerState();
}

class _DailyInsightBannerState extends State<DailyInsightBanner> {
  String? _insight;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DailyInsightBanner old) {
    super.didUpdateWidget(old);
    if (old.lottery.id != widget.lottery.id) _load();
  }

  Future<void> _load() async {
    final text = await InsightService.instance.getDailyInsight(
      lottery: widget.lottery,
      draws: widget.draws,
    );
    if (mounted) setState(() => _insight = text);
  }

  @override
  Widget build(BuildContext context) {
    if (_insight == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(80),
          border: Border.all(
              color: theme.colorScheme.primary.withAlpha(40), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊', style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Insight",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _insight!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
