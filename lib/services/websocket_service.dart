import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/chart_update.dart';

import '../models/real_time_update.dart';

import '../models/trends_update.dart';

class WebSocketService {
  static const String baseWsUrl = 'wss://trading-production-85d8.up.railway.app/ws';

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  StreamController<RealTimeUpdate>? _realTimeController;
  StreamController<TrendsUpdate>? _trendsController;
  StreamController<ChartUpdate>? _chartController;
  Stream<Map<String, dynamic>>? _stream;
  Stream<RealTimeUpdate>? _realTimeStream;
  Stream<TrendsUpdate>? _trendsStream;
  Stream<ChartUpdate>? _chartStream;
  bool _isConnected = false;
  Map<String, RealTimeUpdate> latestUpdates = {};
  Map<String, ChartUpdate> latestChartData = {};

  Stream<Map<String, dynamic>>? get stream => _stream;
  Stream<RealTimeUpdate>? get realTimeStream => _realTimeStream;
  Stream<TrendsUpdate>? get trendsStream => _trendsStream;
  Stream<ChartUpdate>? get chartStream => _chartStream;
  bool get isConnected => _isConnected;

  Future<void> connectToAssetForecast(String symbol) async {
    await _disconnect();

    try {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
      _realTimeController = StreamController<RealTimeUpdate>.broadcast();
      _channel = WebSocketChannel.connect(
        Uri.parse('$baseWsUrl/asset/$symbol/forecast'),
      );

      _stream = _controller!.stream;
      _realTimeStream = _realTimeController!.stream;
      _isConnected = true;

      //print('🔗 Connected to asset forecast WebSocket for $symbol');

      _channel!.stream.listen(
            (data) {
          try {
            final jsonData = json.decode(data);
            _controller!.add(jsonData);
            if (jsonData['type'] == 'realtime_update' || jsonData['type'] == 'price_update') {
              final realTimeUpdate = RealTimeUpdate.fromJson(jsonData);
              latestUpdates[realTimeUpdate.symbol] = realTimeUpdate;
              _realTimeController!.add(realTimeUpdate);
            }
          } catch (e) {
            //print('Error parsing WebSocket data for $symbol: $e');
          }
        },
        onError: (error) {
          //print('WebSocket error for $symbol: $error');
          _isConnected = false;
          Future.delayed(Duration(seconds: 5), () {
            connectToAssetForecast(symbol);
          });
        },
        onDone: () {
          //print('WebSocket connection closed for $symbol');
          _isConnected = false;
          Future.delayed(Duration(seconds: 5), () {
            connectToAssetForecast(symbol);
          });
        },
      );
    } catch (e) {
      //print('Error connecting to WebSocket for $symbol: $e');
      _isConnected = false;
      Future.delayed(Duration(seconds: 5), () {
        connectToAssetForecast(symbol);
      });
    }
  }

  Future<void> connectToAssetTrends(String symbol) async {
    await _disconnect();

    try {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
      _trendsController = StreamController<TrendsUpdate>.broadcast();
      _channel = WebSocketChannel.connect(
        Uri.parse('$baseWsUrl/asset/$symbol/trends'),
      );

      _stream = _controller!.stream;
      _trendsStream = _trendsController!.stream;
      _isConnected = true;

      //print('🔗 Connected to trends WebSocket for $symbol');

      _channel!.stream.listen(
            (data) {
          try {
            final jsonData = json.decode(data);
            _controller!.add(jsonData);
            final trendsUpdate = TrendsUpdate.fromJson(jsonData);
            _trendsController!.add(trendsUpdate);
            //print('📈 Trends update received: ${trendsUpdate.symbol} - Accuracy: ${trendsUpdate.accuracy.toStringAsFixed(1)}%');
          } catch (e) {
            //print('Error parsing WebSocket data for $symbol: $e');
          }
        },
        onError: (error) {
          //print('WebSocket error for $symbol: $error');
          _isConnected = false;
          Future.delayed(Duration(seconds: 5), () {
            connectToAssetTrends(symbol);
          });
        },
        onDone: () {
          //print('WebSocket connection closed for $symbol');
          _isConnected = false;
          Future.delayed(Duration(seconds: 5), () {
            connectToAssetTrends(symbol);
          });
        },
      );
    } catch (e) {
      //print('Error connecting to WebSocket for $symbol: $e');
      _isConnected = false;
      Future.delayed(Duration(seconds: 5), () {
        connectToAssetTrends(symbol);
      });
    }
  }

  Future<void> connectToMarketSummary({String? assetClass, List<String>? symbols}) async {
    await _disconnect();

    try {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
      _realTimeController = StreamController<RealTimeUpdate>.broadcast();

      String endpoint = '$baseWsUrl/market/summary';
      if (assetClass != null) {
        endpoint += '/$assetClass';
      }

      _channel = WebSocketChannel.connect(Uri.parse(endpoint));

      _stream = _controller!.stream;
      _realTimeStream = _realTimeController!.stream;
      _isConnected = true;

      //print('🔗 Connected to market summary WebSocket for ${assetClass ?? 'all assets'}');

      if (symbols != null && symbols.isNotEmpty) {
        sendMessage({
          'type': 'subscribe',
          'symbols': symbols,
          'data_types': ['summary', 'prices', 'confidence'],
          'interval': '1s',
        });
      }

      _channel!.stream.listen(
            (data) {
          try {
            final jsonData = json.decode(data);
            _controller!.add(jsonData);

            if (jsonData['type'] == 'price_update' || jsonData['type'] == 'market_update') {
              final realTimeUpdate = RealTimeUpdate.fromJson(jsonData);
              latestUpdates[realTimeUpdate.symbol] = realTimeUpdate;
              _realTimeController!.add(realTimeUpdate);
            }
          } catch (e) {
            //print('Error parsing WebSocket data: $e');
          }
        },
        onError: (error) {
          //print('Market WebSocket error: $error');
          _isConnected = false;
          Future.delayed(Duration(seconds: 5), () {
            connectToMarketSummary(assetClass: assetClass, symbols: symbols);
          });
        },
        onDone: () {
          //print('Market WebSocket connection closed');
          _isConnected = false;
          Future.delayed(Duration(seconds: 5), () {
            connectToMarketSummary(assetClass: assetClass, symbols: symbols);
          });
        },
      );
    } catch (e) {
      //print('Error connecting to market WebSocket: $e');
      _isConnected = false;
      Future.delayed(Duration(seconds: 5), () {
        connectToMarketSummary(assetClass: assetClass, symbols: symbols);
      });
    }
  }

  Future<void> connectToRealtimeUpdates(List<String> symbols) async {
    if (symbols.isEmpty) {
      //print('No symbols provided for real-time updates');
      return;
    }

    // Only disconnect if we're not already connected to these symbols
    if (!_isConnected || !_hasRequiredSymbols(symbols)) {
      await _disconnect();

      try {
        _controller = StreamController<Map<String, dynamic>>.broadcast();
        _realTimeController = StreamController<RealTimeUpdate>.broadcast();
        _stream = _controller!.stream;
        _realTimeStream = _realTimeController!.stream;
        _isConnected = true;

        //print('🎯 Initializing shared streams for real-time updates');

        await _connectToIndividualAssets(symbols);
      } catch (e) {
        //print('Error initiating real-time updates: $e');
        _isConnected = false;
        Future.delayed(Duration(seconds: 5), () {
          connectToRealtimeUpdates(symbols);
        });
      }
    } else {
      //print('✅ Real-time connection already active for required symbols');
    }
  }

  bool _hasRequiredSymbols(List<String> requiredSymbols) {
    // Simple check - if we have parallel channels, assume we're connected to symbols
    return _parallelChannels.isNotEmpty;
  }

  Future<void> _connectToIndividualAssets(List<String> symbols) async {
    if (symbols.isEmpty) {
      //print('No symbols provided for individual connections');
      return;
    }

    try {
      await _disconnectParallelChannels();

      //print('🚀 Creating parallel connections for ${symbols.length} symbols: $symbols');

      for (final symbol in symbols) {
        try {
          final channel = WebSocketChannel.connect(
            Uri.parse('$baseWsUrl/asset/$symbol/forecast'),
          );

          _parallelChannels.add(channel);
          //print('🔗 Connected to asset forecast: $symbol');

          channel.stream.listen(
                (data) => _handleParallelWebSocketData(data, symbol),
            onError: (error) {
              //print('❌ WebSocket error for $symbol: $error');
              _parallelChannels.removeWhere((ch) => ch == channel);
              Future.delayed(Duration(seconds: 5), () {
                _reconnectSingleAsset(symbol);
              });
            },
            onDone: () {
              //print('🔚 WebSocket connection closed for $symbol');
              _parallelChannels.removeWhere((ch) => ch == channel);
              Future.delayed(Duration(seconds: 5), () {
                _reconnectSingleAsset(symbol);
              });
            },
          );
        } catch (e) {
          //print('❌ Failed to connect to $symbol: $e');
          Future.delayed(Duration(seconds: 5), () {
            _reconnectSingleAsset(symbol);
          });
        }
      }

      if (_parallelChannels.isEmpty) {
        //print('❌ No parallel connections established');
        _isConnected = false;
        Future.delayed(Duration(seconds: 5), () {
          _connectToIndividualAssets(symbols);
        });
      }
    } catch (e) {
      //print('❌ Error setting up parallel connections: $e');
      _isConnected = false;
      Future.delayed(Duration(seconds: 5), () {
        _connectToIndividualAssets(symbols);
      });
    }
  }

  Future<void> _reconnectSingleAsset(String symbol) async {
    try {
      final channel = WebSocketChannel.connect(
        Uri.parse('$baseWsUrl/asset/$symbol/forecast'),
      );

      _parallelChannels.add(channel);
      //print('🔗 Reconnected to asset forecast: $symbol');

      channel.stream.listen(
            (data) => _handleParallelWebSocketData(data, symbol),
        onError: (error) {
          //print('❌ WebSocket error for $symbol: $error');
          _parallelChannels.removeWhere((ch) => ch == channel);
          Future.delayed(Duration(seconds: 5), () {
            _reconnectSingleAsset(symbol);
          });
        },
        onDone: () {
          //print('🔚 WebSocket connection closed for $symbol');
          _parallelChannels.removeWhere((ch) => ch == channel);
          Future.delayed(Duration(seconds: 5), () {
            _reconnectSingleAsset(symbol);
          });
        },
      );
    } catch (e) {
      //print('❌ Failed to reconnect to $symbol: $e');
      Future.delayed(Duration(seconds: 5), () {
        _reconnectSingleAsset(symbol);
      });
    }
  }

  final List<WebSocketChannel> _parallelChannels = [];

  void _handleParallelWebSocketData(dynamic data, String expectedSymbol) {
    try {
      dynamic jsonData;

      if (data is String) {
        try {
          jsonData = json.decode(data);
        } catch (decodeError) {
          //print('❌ JSON decode error for $expectedSymbol: $decodeError');
          return;
        }
      } else if (data is Map) {
        jsonData = data;
      } else {
        String dataString = data.toString();
        try {
          jsonData = json.decode(dataString);
        } catch (decodeError) {
          //print('❌ JSON decode error for $expectedSymbol: $decodeError');
          return;
        }
      }

      if (jsonData is! Map<String, dynamic>) {
        //print('❌ Expected Map<String, dynamic> for $expectedSymbol, got ${jsonData.runtimeType}');
        return;
      }

      final messageType = jsonData['type']?.toString() ?? 'unknown';
      final symbol = jsonData['symbol']?.toString() ?? expectedSymbol;

      if (_controller != null && !_controller!.isClosed) {
        _controller!.add(jsonData);
      }

      if (messageType == 'realtime_update' || messageType == 'price_update') {
        try {
          final realTimeUpdate = RealTimeUpdate.fromJson(jsonData);
          latestUpdates[symbol] = realTimeUpdate;
          if (_realTimeController != null && !_realTimeController!.isClosed) {
            _realTimeController!.add(realTimeUpdate);
          }
        } catch (parseError) {
          //print('❌ Error creating RealTimeUpdate for $symbol: $parseError');
        }
      }
    } catch (e) {
      //print('❌ Unexpected error handling data for $expectedSymbol: $e');
    }
  }

  Future<void> _disconnectParallelChannels() async {
    for (final channel in _parallelChannels) {
      try {
        await channel.sink.close(status.goingAway);
      } catch (e) {
        //print('Error closing parallel channel: $e');
      }
    }
    _parallelChannels.clear();
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(json.encode(message));
    }
    for (final channel in _parallelChannels) {
      try {
        channel.sink.add(json.encode(message));
      } catch (e) {
        //print('Error sending message to parallel channel: $e');
      }
    }
  }

  void changeTimeframe(String timeframe) {
    sendMessage({
      'type': 'set_timeframe',
      'timeframe': timeframe,
    });
  }

  void changeSymbol(String symbol) {
    sendMessage({
      'type': 'set_symbol',
      'symbol': symbol,
    });
  }

  /// Change timeframe for chart connection without reconnecting
  void changeChartTimeframe(String timeframe) {
    if (_isConnected && _channel != null) {
      //print('📡 Sending timeframe change message: $timeframe');
      sendMessage({
        'type': 'change_timeframe',
        'timeframe': timeframe,
      });
    } else {
      //print('⚠️ Cannot change timeframe: WebSocket not connected');
    }
  }

  Future<void> connectToAssetChart(String symbol, {String timeframe = '7D'}) async {
    await _disconnect();

    try {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
      _chartController = StreamController<ChartUpdate>.broadcast();
      _channel = WebSocketChannel.connect(
        Uri.parse('$baseWsUrl/chart/$symbol?timeframe=$timeframe'),
      );

      _stream = _controller!.stream;
      _chartStream = _chartController!.stream;
      _isConnected = true;


      //print('📈 Connected to chart WebSocket for $symbol ($timeframe)');

      _channel!.stream.listen(
            (data) {
          //print('📡 Received WebSocket data: $data');
          try {
            final jsonData = json.decode(data is String ? data : data.toString());
            _controller!.add(jsonData);


            if (jsonData['type'] == 'chart_update') {
              final chartUpdate = ChartUpdate.fromJson(jsonData);
              //print('📊 Parsed ChartUpdate: symbol=${chartUpdate.symbol}, timeframe=${chartUpdate.timeframe}, pastPoints=${chartUpdate.chartData.pastDataPoints}, futurePoints=${chartUpdate.chartData.futureDataPoints}');
              latestChartData[chartUpdate.symbol] = chartUpdate;
              _chartController!.add(chartUpdate);
            }
          } catch (e, _) {
            //print('❌ Error parsing chart WebSocket data for $symbol: $e');
            //print('StackTrace: $stackTrace');
          }
        },
        onError: (error) {
          //print('❌ Chart WebSocket error for $symbol: $error');
          _isConnected = false;
          _scheduleReconnect(symbol, timeframe);
        },
        onDone: () {
          //print('🔚 Chart WebSocket connection closed for $symbol');
          _isConnected = false;
          _scheduleReconnect(symbol, timeframe);
        },
      );
    } catch (e) {
      //print('❌ Error connecting to chart WebSocket for $symbol: $e');
      _isConnected = false;
      _scheduleReconnect(symbol, timeframe);
    }
  }

  void _scheduleReconnect(String symbol, String timeframe) {
    Future.delayed(Duration(seconds: 5), () {
      if (!_isConnected) {
        //print('🔄 Attempting to reconnect WebSocket for $symbol');
        connectToAssetChart(symbol, timeframe: timeframe);
      }
    });
  }


  Future<void> _disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    await _disconnectParallelChannels();

    if (_controller != null) {
      await _controller!.close();
      _controller = null;
    }

    if (_realTimeController != null) {
      await _realTimeController!.close();
      _realTimeController = null;
    }

    if (_trendsController != null) {
      await _trendsController!.close();
      _trendsController = null;
    }

    if (_chartController != null) {
      await _chartController!.close();
      _chartController = null;
    }

    _isConnected = false;
  }

  Future<void> disconnect() async {
    await _disconnect();
  }

  void dispose() {
    disconnect();
  }
}


class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  final Map<String, WebSocketService> _connections = {};

  WebSocketService getConnection(String key) {
    if (!_connections.containsKey(key)) {
      _connections[key] = WebSocketService();
    }
    return _connections[key]!;
  }

  void removeConnection(String key) {
    if (_connections.containsKey(key)) {
      _connections[key]!.dispose();
      _connections.remove(key);
    }
  }

  void disposeAll() {
    for (var connection in _connections.values) {
      connection.dispose();
    }
    _connections.clear();
  }
}