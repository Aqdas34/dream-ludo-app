// ───────────────────────────────────────────────────────────────
// websocket_service.dart  –  WebSocket / STOMP client
// For real-time: match updates, chat, game room events
// Uses stomp_dart_client ^3.0.1 (breaking change from v1.x)
// v3.x removed StompConfig.webSocket() → use StompConfig(url:)
// ───────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:logger/logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:dream_ludo/core/config/env.dart';
import 'package:dream_ludo/core/services/storage_service.dart';

typedef MessageCallback = void Function(String message);
typedef VoidCallback = void Function();

class WebSocketService {
  final StorageService _storage;
  final Logger _logger = Logger();

  StompClient? _stompClient;
  bool _isConnected = false;

  final Map<String, StompUnsubscribe> _subscriptions = {};

  WebSocketService(this._storage);

  bool get isConnected => _isConnected;

  // ── Connect to STOMP WebSocket ─────────────────────────────────
  // stomp_dart_client v3.x: use StompConfig(url: ...) directly
  // (StompConfig.webSocket was removed in v3.0.0)

  Future<void> connect({VoidCallback? onConnected}) async {
    if (_isConnected) return;

    final token = await _storage.getToken() ?? '';

    _stompClient = StompClient(
      config: StompConfig(
        url: Env.wsUrl,
        onConnect: (frame) {
          _isConnected = true;
          _logger.i('WebSocket connected');
          onConnected?.call();
        },
        onDisconnect: (_) {
          _isConnected = false;
          _logger.w('WebSocket disconnected');
        },
        onWebSocketError: (error) {
          _isConnected = false;
          _logger.e('WebSocket error: $error');
        },
        onStompError: (frame) {
          _logger.e('STOMP error: ${frame.body}');
        },
        reconnectDelay: const Duration(seconds: 5),
        connectionTimeout: const Duration(seconds: 10),
        stompConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    _stompClient!.activate();
  }

  // ── Subscribe to a topic/destination ──────────────────────────

  void subscribe({
    required String destination,
    required MessageCallback onMessage,
  }) {
    if (!_isConnected || _stompClient == null) {
      _logger.w('Not connected. Cannot subscribe to $destination');
      return;
    }

    if (_subscriptions.containsKey(destination)) return;

    final unsubscribe = _stompClient!.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body != null) {
          onMessage(frame.body!);
        }
      },
    );

    _subscriptions[destination] = unsubscribe;
    _logger.d('Subscribed to $destination');
  }

  // ── Send a message to a destination ───────────────────────────

  void send({
    required String destination,
    required String body,
    Map<String, String>? headers,
  }) {
    if (!_isConnected || _stompClient == null) {
      _logger.w('Not connected. Cannot send to $destination');
      return;
    }

    _stompClient!.send(
      destination: destination,
      body: body,
      headers: headers,
    );
  }

  // ── Unsubscribe from a topic ───────────────────────────────────

  void unsubscribe(String destination) {
    final unsub = _subscriptions.remove(destination);
    unsub?.call();
    _logger.d('Unsubscribed from $destination');
  }

  // ── Room-specific helpers ──────────────────────────────────────

  void subscribeToMatch({
    required String matchId,
    required MessageCallback onMessage,
  }) {
    subscribe(destination: '/topic/match/$matchId', onMessage: onMessage);
  }

  void subscribeToChat({
    required String matchId,
    required MessageCallback onMessage,
  }) {
    subscribe(destination: '/topic/chat/$matchId', onMessage: onMessage);
  }

  void sendChatMessage({required String matchId, required String message}) {
    send(destination: '/app/chat/$matchId', body: message);
  }

  // ── Disconnect ─────────────────────────────────────────────────

  void disconnect() {
    for (final unsub in _subscriptions.values) {
      unsub.call();
    }
    _subscriptions.clear();
    _stompClient?.deactivate();
    _isConnected = false;
    _logger.i('WebSocket disconnected');
  }
}
