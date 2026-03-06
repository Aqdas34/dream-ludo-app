import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/core/config/env.dart';

class SocketService {
  final StorageService _storage;
  IO.Socket? _socket;
  
  SocketService(this._storage);

  bool get isConnected => _socket?.connected ?? false;

  Future<void>? _connectFuture;

  Future<void> connect() async {
    if (_socket?.connected == true) return;
    if (_connectFuture != null) return _connectFuture;

    _connectFuture = _doConnect();
    try {
      await _connectFuture;
    } finally {
      _connectFuture = null;
    }
  }

  Future<void> _doConnect() async {
    final completer = Completer<void>();
    final token = await _storage.getToken();
    final wsUrl = Env.wsUrl;

    print('🌐 Attempting socket connection to $wsUrl...');

    _socket = IO.io(wsUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .disableAutoConnect()
        .setReconnectionAttempts(3)
        .build());

    _socket?.onConnect((_) {
      print('🔌 Connected to Node.js backend');
      if (!completer.isCompleted) completer.complete();
    });

    _socket?.onConnectError((err) {
      print('❌ Connection Error: $err');
      if (!completer.isCompleted) completer.completeError(err);
    });

    _socket?.onDisconnect((_) => print('❌ Socket Disconnected'));

    _socket?.connect();

    try {
      return await completer.future.timeout(const Duration(seconds: 15));
    } catch (e) {
      print('⌛ Connection timeout: $e');
      dispose();
      rethrow;
    }
  }

  void emit(String event, dynamic data) {
    if (_socket == null) {
      print('⚠️ Socket not initialized! Call connect() first.');
      return;
    }
    _socket!.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket == null) {
      print('⚠️ Socket not initialized! Call connect() first.');
      return;
    }
    _socket!.on(event, callback);
  }

  void off(String event, [Function(dynamic)? callback]) {
    if (callback != null) {
      _socket?.off(event, callback);
    } else {
      _socket?.off(event);
    }
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
