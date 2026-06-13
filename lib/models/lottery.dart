class Lottery {
  final String id;
  final String countryCode;
  final String countryName;
  final String name;
  final int mainCount;
  final int mainMin;
  final int mainMax;
  final int? bonusCount;
  final int? bonusMin;
  final int? bonusMax;
  final bool hasSeparateBonusPool;
  final int drawRoundsPerTicket;

  /// Inline label shown before bonus balls (e.g. "Powerball", "Mega Ball").
  /// null = supplementary style (shown on second row, labeled "Supp").
  final String? bonusLabel;

  /// Shared dataset ID for multi-country lotteries (e.g. 'euromillions', 'eurojackpot').
  /// When set, this lottery uses a shared historical dataset instead of country-specific data.
  /// Example: Both 'uk_euromillions' and 'fr_euromillions' use sharedDatasetId: 'euromillions'
  final String? sharedDatasetId;

  const Lottery({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.name,
    required this.mainCount,
    required this.mainMin,
    required this.mainMax,
    this.bonusCount,
    this.bonusMin,
    this.bonusMax,
    this.hasSeparateBonusPool = false,
    this.drawRoundsPerTicket = 1,
    this.bonusLabel,
    this.sharedDatasetId,
  });

  bool get hasBonus => bonusCount != null && bonusCount! > 0;

  /// true = bonus balls are secondary (Supp row); false = inline powerball-style
  bool get bonusIsSupplementary => hasBonus && bonusLabel == null;

  String get displayName => '$countryName · $name';
}
