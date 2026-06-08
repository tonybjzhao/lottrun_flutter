# Analysis Weights Implementation Guide

## Overview

The Analysis Style setting allows users to choose how historical lottery data is weighted when calculating trends, hot/cold numbers, and match scores.

## Available Styles

### 1. Recent Trend
Emphasizes recent patterns:
- 0-12 weeks: 70%
- 13-52 weeks: 20%
- 1-5 years: 10%

### 2. Balanced (Default)
Equal consideration across all periods:
- 0-12 weeks: 50%
- 13-52 weeks: 30%
- 1-5 years: 20%

### 3. Long-Term Pattern
Emphasizes historical patterns:
- 0-12 weeks: 30%
- 13-52 weeks: 30%
- 1-5 years: 40%

## Usage

### Access Current Weights

```dart
import 'package:lottfun_flutter/services/analysis_style_service.dart';

// Get current style
final style = AnalysisStyleService.instance.style;

// Get current weights
final weights = AnalysisStyleService.instance.weights;
final recentWeight = weights['recent']!;    // e.g., 0.50
final mediumWeight = weights['medium']!;    // e.g., 0.30
final longTermWeight = weights['longTerm']!; // e.g., 0.20
```

### Apply Weights in Analysis Code

When calculating hot/cold numbers, match scores, or trends, weight the data based on time periods:

```dart
double calculateWeightedScore(List<LotteryDraw> draws) {
  final weights = AnalysisStyleService.instance.weights;
  final now = DateTime.now();
  
  double score = 0.0;
  
  for (final draw in draws) {
    final age = now.difference(draw.date);
    
    double weight;
    if (age.inDays <= 84) {  // 0-12 weeks
      weight = weights['recent']!;
    } else if (age.inDays <= 365) {  // 13-52 weeks
      weight = weights['medium']!;
    } else {  // 1-5 years
      weight = weights['longTerm']!;
    }
    
    score += calculateDrawScore(draw) * weight;
  }
  
  return score;
}
```

### Example: Hot Numbers Calculation

```dart
Map<int, double> calculateHotNumbers(List<LotteryDraw> draws) {
  final weights = AnalysisStyleService.instance.weights;
  final now = DateTime.now();
  final frequency = <int, double>{};
  
  for (final draw in draws) {
    final age = now.difference(draw.date);
    
    // Determine weight based on age
    double weight;
    if (age.inDays <= 84) {
      weight = weights['recent']!;
    } else if (age.inDays <= 365) {
      weight = weights['medium']!;
    } else if (age.inDays <= 1825) {  // 5 years
      weight = weights['longTerm']!;
    } else {
      continue;  // Skip draws older than 5 years
    }
    
    // Weight each number's occurrence
    for (final number in draw.mainNumbers) {
      frequency[number] = (frequency[number] ?? 0.0) + weight;
    }
  }
  
  return frequency;
}
```

### Time Period Boundaries

- **Recent**: 0-12 weeks (0-84 days)
- **Medium**: 13-52 weeks (85-365 days)
- **Long-Term**: 1-5 years (366-1825 days)

## Integration Points

Apply these weights in the following areas:

1. **Hot/Cold Number Analysis**
   - Weight number frequency by time period
   - More recent occurrences get higher weight with "Recent Trend"
   - Historical occurrences get higher weight with "Long-Term Pattern"

2. **Historical Match Score**
   - Weight historical matches by when they occurred
   - Adjust similarity scores based on draw age

3. **Trend Analysis**
   - Weight trend calculations by time period
   - Emphasize recent or long-term trends based on style

4. **Pattern Detection**
   - Weight pattern occurrences by age
   - Detect patterns in weighted frequency distributions

## User Disclaimer

**Important**: The app displays this disclaimer to users:

> "This only changes how historical trends are weighted. It does not improve the odds of winning."

This feature is for historical analysis preferences only. It does not:
- Improve winning odds
- Predict future results
- Guarantee any outcomes

## Settings UI

Users can select their preferred Analysis Style in Settings:
- Settings → Analysis Style
- Choose from: Recent Trend, Balanced, Long-Term Pattern
- Selection is persisted and survives app restarts
- Updates take effect immediately

## Testing

See `test/analysis_style_test.dart` for comprehensive tests covering:
- Weight configurations
- Persistence
- ID conversion
- Default values
- Service integration

All weights sum to 1.0 (100%) and are validated in tests.

## Localization

Analysis Style settings are fully localized in 5 languages:
- English
- Chinese (中文)
- French (Français)
- Spanish (Español)
- German (Deutsch)

Each style name, description, and disclaimer is translated.
