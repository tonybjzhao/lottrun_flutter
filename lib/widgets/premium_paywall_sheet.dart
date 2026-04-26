import 'package:flutter/material.dart';
import '../navigator_key.dart';
import '../services/premium_service.dart';

Future<void> showPremiumPaywall(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PremiumPaywallSheet(),
  );
}

class _PremiumPaywallSheet extends StatefulWidget {
  const _PremiumPaywallSheet();

  @override
  State<_PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends State<_PremiumPaywallSheet> {
  String? _errorMessage;
  bool _didShowSuccess = false;

  Future<void> _purchase() async {
    setState(() => _errorMessage = null);
    final result = await PremiumService.instance.purchase();
    if (!mounted) return;
    if (result == PurchaseResult.unavailable) {
      setState(() => _errorMessage = 'Temporarily unavailable. Please try again later.');
    } else if (result == PurchaseResult.error) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    }
    // pending → purchaseStream callback will unlock → build() shows success dialog
  }

  Future<void> _restore() async {
    setState(() => _errorMessage = null);
    final result = await PremiumService.instance.restore();
    if (!mounted) return;
    if (result == PurchaseResult.unavailable) {
      setState(() => _errorMessage = 'Store unavailable. Please try again later.');
    } else if (result == PurchaseResult.error) {
      setState(() => _errorMessage = 'Restore failed. Please try again.');
    }
  }

  void _showSuccessAndClose(BuildContext context) {
    _didShowSuccess = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Close the paywall sheet
      Navigator.pop(context);
      // Use the global navigator so the dialog context is always valid
      final navContext = globalNavigatorKey.currentContext;
      if (navContext == null) return;
      await showDialog<void>(
        context: navContext,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Premium unlocked 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'You now have access to advanced analysis features.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PremiumService.instance,
      builder: (context, _) {
        final svc = PremiumService.instance;
        if (svc.isPremium && !_didShowSuccess) {
          _showSuccessAndClose(context);
        }
        return _buildSheet(context, svc);
      },
    );
  }

  Widget _buildSheet(BuildContext context, PremiumService svc) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final loadState = svc.loadState;
    final productUnavailable = loadState == ProductLoadState.notFound ||
        loadState == ProductLoadState.storeUnavailable;
    final alreadyPremium = svc.isPremium;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(30),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 8, 20, mq.viewInsets.bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(theme: theme),
                    const SizedBox(height: 20),
                    ..._kFeatures.map(
                        (f) => _FeatureRow(feature: f, theme: theme)),
                    const SizedBox(height: 20),

                    // ── Already premium ───────────────────────────────
                    if (alreadyPremium) ...[
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: null,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.green.shade600,
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            "You're Premium ✓",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // ── Error / status message ──────────────────────
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(120),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ] else if (productUnavailable) ...[
                        Text(
                          'Store product is still loading. Please try again later.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(120),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // ── CTA button ──────────────────────────────────
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: svc.canPurchase ? _purchase : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                theme.colorScheme.onSurface.withAlpha(20),
                            disabledForegroundColor:
                                theme.colorScheme.onSurface.withAlpha(80),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: svc.isPurchasing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white),
                                )
                              : Text(
                                  'Unlock Advanced Analysis — ${svc.displayPrice}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'One-time payment · No subscription',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: svc.isPurchasing ? null : _restore,
                          child: Text(
                            'Restore Purchase',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(140),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Maybe later',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Post-draw analysis only. Premium does not predict results or improve odds.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(80),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final ThemeData theme;
  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text(
            'Unlock Advanced Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Go deeper into historical draw patterns\nand track your saved picks over time.',
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Feature list ──────────────────────────────────────────────────────────────

class _PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  const _PremiumFeature(this.icon, this.title, this.description);
}

const _kFeatures = [
  _PremiumFeature(
    Icons.block_rounded,
    'No Ads',
    'Clean, distraction-free experience',
  ),
  _PremiumFeature(
    Icons.analytics_rounded,
    'Deeper Historical Analysis',
    'Extended pattern breakdowns and top 10 similar draws',
  ),
  _PremiumFeature(
    Icons.bookmark_rounded,
    'Saved Picks Pro',
    'Track how your saved picks compare with recent results over time',
  ),
  _PremiumFeature(
    Icons.tune_rounded,
    'Custom Analysis Controls',
    'Adjust analysis window and trend weighting',
  ),
  _PremiumFeature(
    Icons.share_rounded,
    'Premium Share Cards',
    'Create cleaner result cards',
  ),
];

class _FeatureRow extends StatelessWidget {
  final _PremiumFeature feature;
  final ThemeData theme;
  const _FeatureRow({required this.feature, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withAlpha(18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon,
                size: 18, color: const Color(0xFF7C3AED)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feature.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(140),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              size: 18, color: Color(0xFF7C3AED)),
        ],
      ),
    );
  }
}
