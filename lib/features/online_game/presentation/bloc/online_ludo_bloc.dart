import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dream_ludo/core/services/socket_service.dart';
import 'package:dream_ludo/features/online_game/data/models/online_game_model.dart';

// ── Events ───────────────────────────────────────────
abstract class OnlineLudoEvent extends Equatable {
  const OnlineLudoEvent();
  @override
  List<Object?> get props => [];
}

class ConnectToGame extends OnlineLudoEvent {
  final String roomId;
  final bool isJoining;
  final int playerCount;
  final String? userId;
  final String? username;
  final bool isPrivate;
  const ConnectToGame(this.roomId, {this.isJoining = false, this.playerCount = 4, this.userId, this.username, this.isPrivate = true});
}

class RollDiceRequested extends OnlineLudoEvent {}

class PieceMoveRequested extends OnlineLudoEvent {
  final int pieceIndex;
  const PieceMoveRequested(this.pieceIndex);
}

class SendChatMessage extends OnlineLudoEvent {
  final String message;
  const SendChatMessage(this.message);
}

class UpdateRoomState extends OnlineLudoEvent {
  final Map<String, dynamic> json;
  const UpdateRoomState(this.json);
}

class ReceivedMessage extends OnlineLudoEvent {
  final Map<String, dynamic> json;
  const ReceivedMessage(this.json);
}

class StartGameRequested extends OnlineLudoEvent {}

class SocketErrorReceived extends OnlineLudoEvent {
  final String message;
  const SocketErrorReceived(this.message);
  @override
  List<Object?> get props => [message];
}

class PlayerLeftReceived extends OnlineLudoEvent {
  final String username;
  const PlayerLeftReceived(this.username);
  @override
  List<Object?> get props => [username];
}

// ── BLoC ──────────────────────────────────────────────
class OnlineLudoBloc extends Bloc<OnlineLudoEvent, OnlineLudoState> {
  final SocketService _socket;

  OnlineLudoBloc(this._socket) : super(const OnlineLudoState()) {
    on<ConnectToGame>(_onConnect);
    on<UpdateRoomState>(_onUpdateState);
    on<RollDiceRequested>(_onRollDice);
    on<PieceMoveRequested>(_onMovePiece);
    on<SendChatMessage>(_onSendMessage);
    on<ReceivedMessage>(_onReceivedMessage);
    on<StartGameRequested>(_onStartGame);
    on<SocketErrorReceived>((event, emit) => emit(state.copyWith(errorMessage: event.message)));
    on<PlayerLeftReceived>((event, emit) => emit(state.copyWith(errorMessage: 'Player ${event.username} left the room.')));
  }

  Future<void> _onConnect(ConnectToGame event, Emitter<OnlineLudoState> emit) async {
    try {
      await _socket.connect();
      
      _socket.on('roomCreated', _onRoomCreated);
      _socket.on('roomUpdated', _onRoomUpdated);
      _socket.on('gameStarted', _onGameStarted);
      _socket.on('diceRolled', _onDiceRolledFromSocket);
      _socket.on('newMessage', _onNewMessage);
      _socket.on('error', _onError);
      _socket.on('playerLeft', _onPlayerLeft);

      // Join or create
      if (event.isJoining) {
        _socket.emit('joinRoom', {
          'roomId': event.roomId,
          'userId': event.userId,
          'username': event.username,
        });
      } else {
        _socket.emit('createRoom', {
          'roomId': event.roomId,
          'playerCount': event.playerCount,
          'isPrivate': event.isPrivate,
          'userId': event.userId,
          'username': event.username,
        });
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Connection Failed: $e'));
    }
  }

  void _onRoomCreated(dynamic data) => add(UpdateRoomState(data as Map<String, dynamic>));
  void _onRoomUpdated(dynamic data) => add(UpdateRoomState(data as Map<String, dynamic>));
  void _onGameStarted(dynamic data) => add(UpdateRoomState(data as Map<String, dynamic>));
  void _onDiceRolledFromSocket(dynamic data) {
      // Local animation trigger if needed, but for now we'll just wait for roomUpdated
  }
  void _onNewMessage(dynamic data) => add(ReceivedMessage(data as Map<String, dynamic>));
  void _onError(dynamic err) => add(SocketErrorReceived(err.toString()));
  void _onPlayerLeft(dynamic data) => add(PlayerLeftReceived(data['username']));

  void _onUpdateState(UpdateRoomState event, Emitter<OnlineLudoState> emit) {
    emit(OnlineLudoState.fromJson(event.json));
  }

  void _onRollDice(RollDiceRequested event, Emitter<OnlineLudoState> emit) {
    if (state.status != OnlineGameStatus.playing) return;
    _socket.emit('rollDice', state.roomId);
  }

  void _onMovePiece(PieceMoveRequested event, Emitter<OnlineLudoState> emit) {
     _socket.emit('movePiece', {
       'roomId': state.roomId,
       'pieceIndex': event.pieceIndex
     });
  }

  void _onSendMessage(SendChatMessage event, Emitter<OnlineLudoState> emit) {
    _socket.emit('sendMessage', {
      'roomId': state.roomId,
      'message': event.message
    });
  }

  void _onReceivedMessage(ReceivedMessage event, Emitter<OnlineLudoState> emit) {
    final msg = OnlineChatMessage.fromJson(event.json);
    emit(state.copyWith(messages: [...state.messages, msg]));
  }

  void _onStartGame(StartGameRequested event, Emitter<OnlineLudoState> emit) {
    _socket.emit('startGame', state.roomId);
  }

  @override
  Future<void> close() {
    _socket.off('roomCreated', _onRoomCreated);
    _socket.off('roomUpdated', _onRoomUpdated);
    _socket.off('gameStarted', _onGameStarted);
    _socket.off('diceRolled', _onDiceRolledFromSocket);
    _socket.off('newMessage', _onNewMessage);
    _socket.off('error', _onError);
    _socket.off('playerLeft', _onPlayerLeft);
    return super.close();
  }
}
