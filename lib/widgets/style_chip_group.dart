import 'package:flutter/material.dart';
import '../models/generated_pick.dart';

class StyleChipGroup extends StatelessWidget {
  final PlayStyle selected;
  final ValueChanged<PlayStyle> onChanged;

  const StyleChipGroup({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _icons = {
    PlayStyle.balanced: Icons.balance,
    PlayStyle.hot: Icons.local_fire_department,
    PlayStyle.cold: Icons.ac_unit,
    PlayStyle.random: Icons.shuffle,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PlayStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withAlpha(150),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.black.withAlpha(13),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(46),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icons[style],
                  size: 15,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface.withAlpha(180),
                ),
                const SizedBox(width: 6),
                Text(
                  style.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
