# API Response Format for Chart/Graph Implementation

## Overview
یہ دستاویز API کے response format کے بارے میں تفصیلی معلومات فراہم کرتا ہے جو graphs اور charts بنانے کے لیے ضروری ہے۔ App میں historical data اور future predictions دونوں دکھانے کے لیے chart data کی ضرورت ہے۔

## Current Implementation Analysis

### Existing API Endpoints
```
Base URL: https://easygoing-beauty-production.up.railway.app

1. /api/asset/{symbol}/forecast?timeframe={timeframe}
2. /api/asset/{symbol}/trends?timeframe={timeframe}
3. /api/market/summary?limit={limit}&class={assetClass}
```

### WebSocket Endpoints
```
Base WS URL: wss://easygoing-beauty-production.up.railway.app/ws

1. /ws/asset/{symbol}/forecast
2. /ws/asset/{symbol}/trends
3. /ws/market/summary/{assetClass}
```

## Required API Response Format for Charts

### 1. Asset Forecast API (`/api/asset/{symbol}/forecast`)

**Expected Response Structure:**
```json
{
  "type": "forecast",
  "symbol": "BTC",
  "name": "Bitcoin",
  "timeframe": "1D",
  "forecast_direction": "UP",
  "confidence": 85,
  "predicted_range": "$42000-$45000",
  "current_price": 43250.50,
  "change_24h": 1250.75,
  "volume": 28500000000,
  "last_updated": "2024-01-15T10:30:00Z",
  "chart": {
    "past": [
      40500.25,
      41200.30,
      41800.75,
      42100.00,
      42800.50,
      43250.50
    ],
    "future": [
      43500.00,
      44200.25,
      44800.75,
      45000.00
    ],
    "timestamps": [
      "2024-01-15T06:00:00Z",
      "2024-01-15T07:00:00Z",
      "2024-01-15T08:00:00Z",
      "2024-01-15T09:00:00Z",
      "2024-01-15T10:00:00Z",
      "2024-01-15T10:30:00Z",
      "2024-01-15T11:00:00Z",
      "2024-01-15T12:00:00Z",
      "2024-01-15T13:00:00Z",
      "2024-01-15T14:00:00Z"
    ],
    "confidence_bands": {
      "upper": [44000, 44500, 45200, 45800],
      "lower": [43000, 43900, 44400, 44200]
    },
    "support_resistance": {
      "support_levels": [42000, 41500, 40800],
      "resistance_levels": [45000, 45500, 46000]
    }
  }
}
```

### 2. Enhanced Chart Data Structure

**Chart Object Detailed Explanation:**

```json
{
  "chart": {
    // Past price data (historical)
    "past": [
      40500.25,    // 6 hours ago
      41200.30,    // 5 hours ago
      41800.75,    // 4 hours ago
      42100.00,    // 3 hours ago
      42800.50,    // 2 hours ago
      43250.50     // current price
    ],

    // Future predicted prices
    "future": [
      43500.00,    // +1 hour prediction
      44200.25,    // +2 hours prediction
      44800.75,    // +3 hours prediction
      45000.00     // +4 hours prediction
    ],

    // Corresponding timestamps for all data points
    "timestamps": [
      "2024-01-15T06:00:00Z",  // past[0]
      "2024-01-15T07:00:00Z",  // past[1]
      "2024-01-15T08:00:00Z",  // past[2]
      "2024-01-15T09:00:00Z",  // past[3]
      "2024-01-15T10:00:00Z",  // past[4]
      "2024-01-15T10:30:00Z",  // past[5] (current)
      "2024-01-15T11:00:00Z",  // future[0]
      "2024-01-15T12:00:00Z",  // future[1]
      "2024-01-15T13:00:00Z",  // future[2]
      "2024-01-15T14:00:00Z"   // future[3]
    ],

    // Confidence bands for predictions (optional)
    "confidence_bands": {
      "upper": [44000, 44500, 45200, 45800],  // Upper bound for each future point
      "lower": [43000, 43900, 44400, 44200]   // Lower bound for each future point
    },

    // Support and resistance levels (optional)
    "support_resistance": {
      "support_levels": [42000, 41500, 40800],
      "resistance_levels": [45000, 45500, 46000]
    },

    // Additional indicators (optional)
    "indicators": {
      "rsi": 65.5,
      "macd": {
        "macd_line": 150.25,
        "signal_line": 145.30,
        "histogram": 4.95
      },
      "moving_averages": {
        "sma_20": 42500.00,
        "sma_50": 41800.00,
        "ema_12": 43100.00
      }
    }
  }
}
```

### 3. Market Summary API Enhancement

**Current vs Required Format:**

**Current Format (Working):**
```json
{
  "assets": [
    {
      "symbol": "BTC",
      "name": "Bitcoin",
      "current_price": 43250.50,
      "change_24h": 1250.75,
      "forecast_direction": "UP",
      "confidence": 85,
      "predicted_range": "$42000-$45000",
      "asset_class": "crypto"
    }
  ]
}
```

**Enhanced Format (For Chart Support):**
```json
{
  "assets": [
    {
      "symbol": "BTC",
      "name": "Bitcoin",
      "current_price": 43250.50,
      "change_24h": 1250.75,
      "forecast_direction": "UP",
      "confidence": 85,
      "predicted_range": "$42000-$45000",
      "asset_class": "crypto",
      "mini_chart": {
        "past_24h": [42000, 42500, 43000, 43250.50],
        "timestamps": ["00:00", "08:00", "16:00", "now"],
        "trend": "bullish"
      }
    }
  ]
}
```

### 4. WebSocket Real-time Updates

**Current Format (Working):**
```json
{
  "type": "realtime_update",
  "symbol": "BTC",
  "current_price": 43350.75,
  "change_24h": 1350.00,
  "confidence": 87,
  "forecast_direction": "UP",
  "predicted_range": "$42500-$45500",
  "timestamp": "2024-01-15T10:35:00Z"
}
```

**Enhanced Format (For Chart Updates):**
```json
{
  "type": "realtime_update",
  "symbol": "BTC",
  "current_price": 43350.75,
  "change_24h": 1350.00,
  "confidence": 87,
  "forecast_direction": "UP",
  "predicted_range": "$42500-$45500",
  "timestamp": "2024-01-15T10:35:00Z",
  "chart_update": {
    "new_price_point": 43350.75,
    "updated_predictions": [43600, 44300, 44900, 45200],
    "updated_confidence_bands": {
      "upper": [44100, 44600, 45300, 45900],
      "lower": [43100, 44000, 44500, 44500]
    }
  }
}
```

## Implementation Guidelines

### 1. Chart Data Array Length

**Recommended Data Points:**
- **1H timeframe**: 24 past points + 12 future points (36 total)
- **4H timeframe**: 24 past points + 6 future points (30 total)
- **1D timeframe**: 30 past points + 7 future points (37 total)
- **1W timeframe**: 12 past points + 4 future points (16 total)
- **1M timeframe**: 30 past points + 7 future points (37 total)

### 2. Timestamp Format

**Always use ISO 8601 format:**
```
"2024-01-15T10:30:00Z"
```

### 3. Price Precision

**Different assets require different precision:**
- **Crypto (BTC, ETH)**: 2 decimal places
- **Small cap crypto**: 4-6 decimal places
- **Stocks**: 2 decimal places
- **Forex**: 4-5 decimal places

### 4. Error Handling

**When chart data is unavailable:**
```json
{
  "symbol": "BTC",
  "current_price": 43250.50,
  "forecast_direction": "UP",
  "confidence": 85,
  "chart": null,
  "error": "Chart data temporarily unavailable"
}
```

## Chart Types to Support

### 1. Line Chart (Primary)
- Past price line (blue/white)
- Future prediction line (dashed, green/red based on direction)
- Current price marker

### 2. Candlestick Chart (Advanced)
```json
{
  "candlestick_data": [
    {
      "timestamp": "2024-01-15T09:00:00Z",
      "open": 42800.00,
      "high": 43100.00,
      "low": 42750.00,
      "close": 43000.00,
      "volume": 1250000
    }
  ]
}
```

### 3. Area Chart (Alternative)
- Same data as line chart but filled area under the curve
- Different colors for past vs future areas

## Flutter Implementation Notes

### Using fl_chart Package

**Line Chart Implementation:**
```dart
LineChart(
  LineChartData(
    lineBarsData: [
      // Past data line
      LineChartBarData(
        spots: pastPriceSpots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 2,
      ),
      // Future prediction line
      LineChartBarData(
        spots: futurePriceSpots,
        isCurved: true,
        color: Colors.green,
        barWidth: 2,
        dashArray: [5, 5], // Dashed line
      ),
    ],
  ),
)
```

### Data Parsing Example

```dart
class ChartDataParser {
  static List<FlSpot> parseChartData(Map<String, dynamic> chartData) {
    final pastPrices = List<double>.from(chartData['past'] ?? []);
    final futurePrices = List<double>.from(chartData['future'] ?? []);
    final timestamps = List<String>.from(chartData['timestamps'] ?? []);

    List<FlSpot> spots = [];

    // Add past data points
    for (int i = 0; i < pastPrices.length; i++) {
      spots.add(FlSpot(i.toDouble(), pastPrices[i]));
    }

    // Add future data points
    for (int i = 0; i < futurePrices.length; i++) {
      spots.add(FlSpot(
        (pastPrices.length + i).toDouble(),
        futurePrices[i]
      ));
    }

    return spots;
  }
}
```

## Performance Considerations

### 1. Data Caching
- Cache chart data for 1-5 minutes depending on timeframe
- Use local storage for offline chart viewing

### 2. WebSocket Optimization
- Throttle real-time updates to prevent UI lag
- Use debouncing for frequent price updates

### 3. Chart Rendering
- Limit maximum data points to 100 for smooth performance
- Use lazy loading for historical data

## API Response Size Optimization

### 1. Compressed Data Format
```json
{
  "chart_compressed": {
    "past": "40500.25,41200.30,41800.75,42100.00,42800.50,43250.50",
    "future": "43500.00,44200.25,44800.75,45000.00",
    "timestamps_start": "2024-01-15T06:00:00Z",
    "interval_minutes": 60
  }
}
```

### 2. Delta Updates
For WebSocket, send only price changes:
```json
{
  "type": "price_delta",
  "symbol": "BTC",
  "price_change": 100.25,
  "new_prediction": 44100.00,
  "timestamp": "2024-01-15T10:35:00Z"
}
```

## Testing Data Examples

### BTC Test Data
```json
{
  "symbol": "BTC",
  "chart": {
    "past": [42000, 42500, 41800, 42200, 43000, 43250.50],
    "future": [43500, 44000, 44500, 45000],
    "timestamps": [
      "2024-01-15T06:00:00Z",
      "2024-01-15T07:00:00Z",
      "2024-01-15T08:00:00Z",
      "2024-01-15T09:00:00Z",
      "2024-01-15T10:00:00Z",
      "2024-01-15T10:30:00Z",
      "2024-01-15T11:00:00Z",
      "2024-01-15T12:00:00Z",
      "2024-01-15T13:00:00Z",
      "2024-01-15T14:00:00Z"
    ]
  }
}
```

### ETH Test Data
```json
{
  "symbol": "ETH",
  "chart": {
    "past": [2800, 2850, 2780, 2820, 2900, 2925.75],
    "future": [2950, 3000, 3050, 3100],
    "timestamps": [
      "2024-01-15T06:00:00Z",
      "2024-01-15T07:00:00Z",
      "2024-01-15T08:00:00Z",
      "2024-01-15T09:00:00Z",
      "2024-01-15T10:00:00Z",
      "2024-01-15T10:30:00Z",
      "2024-01-15T11:00:00Z",
      "2024-01-15T12:00:00Z",
      "2024-01-15T13:00:00Z",
      "2024-01-15T14:00:00Z"
    ]
  }
}
```

## Conclusion

یہ API response format app میں beautiful اور informative charts بنانے کے لیے تمام ضروری data فراہم کرتا ہے۔ Historical اور future prediction data دونوں کو clearly separate کیا گیا ہے اور real-time updates کے لیے WebSocket support بھی شامل ہے۔

### Key Points:
1. **Past data** = Historical prices (blue line)
2. **Future data** = AI predictions (dashed green/red line)
3. **Timestamps** = X-axis labels
4. **Confidence bands** = Prediction uncertainty areas
5. **Real-time updates** = Live price and prediction changes

یہ format استعمال کرتے ہوئے آپ professional-grade trading charts بنا سکتے ہیں جو users کو clear visual representation فراہم کریں گے۔