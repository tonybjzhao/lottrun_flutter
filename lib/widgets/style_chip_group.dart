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
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: PlayStyle.values.map((style) {
        final isSelected = style == selected;
        return FilterChip(
          avatar: Icon(
            _icons[style],
            size: 16,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
          ),
          label: Text(style.label),
          selected: isSelected,
          onSelected: (_) => onChanged(style),
          showCheckmark: false,
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
