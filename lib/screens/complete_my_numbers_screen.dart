import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/l10n.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../services/generator_service.dart';
import '../services/lottery_service.dart';
import '../services/analytics_service.dart';
import '../widgets/lotto_ball.dart';
import '../widgets/style_chip_group.dart';
import '../widgets/disclaimer_card.dart';

class CompleteMyNumbersScreen extends StatefulWidget {
  final Lottery lottery;

  const CompleteMyNumbersScreen({
    super.key,
    required this.lottery,
  });

  @override
  State<CompleteMyNumbersScreen> createState() =>
      _CompleteMyNumbersScreenState();
}

class _CompleteMyNumbersScreenState extends State<CompleteMyNumbersScreen> {
  final Set<int> _lockedMainNumbers = {};
  final Set<int> _lockedBonusNumbers = {};
  PlayStyle _selectedStyle = PlayStyle.balanced;
  GeneratedPick? _generatedPick;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.completeMyNumbers),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            l10n.completeMyNumbersTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.completeMyNumbersSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Main Numbers Section
          _buildNumberSection(
            title: l10n.selectYourNumbers,
            subtitle: l10n.tapToLockNumbers(
              _lockedMainNumbers.length,
              widget.lottery.mainCount,
            ),
            min: widget.lottery.mainMin,
            max: widget.lottery.mainMax,
            lockedNumbers: _lockedMainNumbers,
            maxSelection: widget.lottery.mainCount,
            isBonus: false,
          ),
          const SizedBox(height: 24),

          // Bonus Numbers Section (if applicable)
          if (widget.lottery.hasBonus) ...[
            _buildNumberSection(
              title: widget.lottery.bonusLabel ?? l10n.bonusNumbers,
              subtitle: l10n.tapToLockBonusNumbers(
                _lockedBonusNumbers.length,
                widget.lottery.bonusCount!,
              ),
              min: widget.lottery.bonusMin!,
              max: widget.lottery.bonusMax!,
              lockedNumbers: _lockedBonusNumbers,
              maxSelection: widget.lottery.bonusCount!,
              isBonus: true,
            ),
            const SizedBox(height: 24),
          ],

          // Strategy Selection
          Text(
            l10n.generationStrategy,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          StyleChipGroup(
            selected: _selectedStyle,
            onChanged: (style) {
              setState(() => _selectedStyle = style);
              _generatedPick = null;
            },
          ),
          const SizedBox(height: 24),

          // Generate Button
          FilledButton.icon(
            onPressed: _canGenerate ? _generateNumbers : null,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_fix_high),
            label: Text(
              _lockedMainNumbers.isEmpty
                  ? l10n.generateAllNumbers
                  : l10n.completeRemainingNumbers,
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),

          // Generated Result
          if (_generatedPick != null) _buildResultCard(),

          const SizedBox(height: 24),

          // Disclaimer
          Card(
            color: const Color(0xFFFFF8E1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF9A825), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.completeMyNumbersDisclaimer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF795548),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSection({
    required String title,
    required String subtitle,
    required int min,
    required int max,
    required Set<int> lockedNumbers,
    required int maxSelection,
    required bool isBonus,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            max - min + 1,
            (index) {
              final number = min + index;
              final isLocked = lockedNumbers.contains(number);
              return _buildNumberButton(
                number: number,
                isLocked: isLocked,
                isBonus: isBonus,
                onTap: () => _toggleNumber(number, isBonus, maxSelection),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton({
    required int number,
    required bool isLocked,
    required bool isBonus,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final size = 48.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLocked
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isLocked
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isLocked ? 2 : 1,
          ),
          boxShadow: isLocked
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$number',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isLocked
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: isLocked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pick = _generatedPick!;

    // Separate locked and generated numbers for display
    final lockedMain = pick.mainNumbers.where(_lockedMainNumbers.contains).toList();
    final generatedMain = pick.mainNumbers.where((n) => !_lockedMainNumbers.contains(n)).toList();
    final lockedBonus = pick.bonusNumbers?.where(_lockedBonusNumbers.contains).toList();
    final generatedBonus = pick.bonusNumbers?.where((n) => !_lockedBonusNumbers.contains(n)).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.yourCompletedNumbers,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pick.style.tagline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Numbers
          _buildNumbersRow(
            locked: lockedMain,
            generated: generatedMain,
            isBonus: false,
          ),

          // Bonus Numbers
          if (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
            const SizedBox(height: 12),
            _buildNumbersRow(
              locked: lockedBonus ?? [],
              generated: generatedBonus ?? [],
              isBonus: true,
            ),
          ],

          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                icon: Icons.lock,
                label: l10n.locked,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                icon: Icons.auto_fix_high,
                label: l10n.generated,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.reset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _generateNumbers,
                  icon: const Icon(Icons.casino),
                  label: Text(l10n.regenerate),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumbersRow({
    required List<int> locked,
    required List<int> generated,
    required bool isBonus,
  }) {
    final theme = Theme.of(context);
    final allNumbers = [...locked, ...generated]..sort();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: allNumbers.map((number) {
        final isLocked = locked.contains(number);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            LottoBall(
              number: number,
              isBonus: isBonus,
              size: 56,
            ),
            if (isLocked)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 12,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _toggleNumber(int number, bool isBonus, int maxSelection) {
    setState(() {
      final targetSet = isBonus ? _lockedBonusNumbers : _lockedMainNumbers;

      if (targetSet.contains(number)) {
        targetSet.remove(number);
      } else if (targetSet.length < maxSelection) {
        targetSet.add(number);
      } else {
        // Show feedback that max is reached
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.maxNumbersSelected(maxSelection),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      _generatedPick = null;
      HapticFeedback.selectionClick();
    });
  }

  bool get _canGenerate {
    final totalLocked = _lockedMainNumbers.length +
        (widget.lottery.hasBonus ? _lockedBonusNumbers.length : 0);
    final totalNeeded = widget.lottery.mainCount +
        (widget.lottery.hasBonus ? widget.lottery.bonusCount! : 0);

    // Can generate if we haven't locked ALL numbers
    return totalLocked < totalNeeded && !_isGenerating;
  }

  Future<void> _generateNumbers() async {
    setState(() => _isGenerating = true);

    await Future.delayed(const Duration(milliseconds: 500));

    final history = LotteryService.instance.getRecentDraws(
      widget.lottery.id,
      limit: 100,
    );

    final pick = GeneratorService.instance.generate(
      lottery: widget.lottery,
      style: _selectedStyle,
      history: history,
      lockedMainNumbers: _lockedMainNumbers.toList(),
      lockedBonusNumbers: _lockedBonusNumbers.toList(),
    );

    unawaited(
      AnalyticsService.logGenerateNumbers(
        lottery: widget.lottery.id,
        strategy: _selectedStyle.analyticsName,
        pickCount: 1,
        source: 'complete_my_numbers',
      ),
    );

    if (!mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _generatedPick = pick;
      _isGenerating = false;
    });
  }

  void _reset() {
    setState(() {
      _lockedMainNumbers.clear();
      _lockedBonusNumbers.clear();
      _generatedPick = null;
    });
    HapticFeedback.lightImpact();
  }
}
