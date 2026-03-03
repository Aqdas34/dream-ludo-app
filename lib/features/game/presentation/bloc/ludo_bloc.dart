import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dream_ludo/features/game/data/models/ludo_models.dart';
import 'package:dream_ludo/features/game/utils/ludo_constants.dart';

// ── Events ────────────────────────────────────────────────────────
abstract class LudoEvent extends Equatable {
  const LudoEvent();
  @override
  List<Object?> get props => [];
}

class LudoInitialize extends LudoEvent {
  final List<String> playerNames;
  const LudoInitialize(this.playerNames);
}

class LudoRollDice extends LudoEvent {}

class LudoMovePiece extends LudoEvent {
  final int tokenIndex;
  const LudoMovePiece(this.tokenIndex);
}

class LudoRestart extends LudoEvent {}

// ── States ────────────────────────────────────────────────────────
class LudoGameState extends Equatable {
  final List<LudoPlayer> players;
  final int currentPlayerIndex;
  final int diceValue;
  final bool isDiceRolled;
  final LudoPlayer? winner;
  final List<int> movableTokenIndices;

  const LudoGameState({
    required this.players,
    this.currentPlayerIndex = 0,
    this.diceValue = 1,
    this.isDiceRolled = false,
    this.winner,
    this.movableTokenIndices = const [],
  });

  LudoPlayer get currentPlayer => players[currentPlayerIndex];

  LudoGameState copyWith({
    List<LudoPlayer>? players,
    int? currentPlayerIndex,
    int? diceValue,
    bool? isDiceRolled,
    LudoPlayer? winner,
    List<int>? movableTokenIndices,
  }) {
    return LudoGameState(
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      diceValue: diceValue ?? this.diceValue,
      isDiceRolled: isDiceRolled ?? this.isDiceRolled,
      winner: winner ?? this.winner,
      movableTokenIndices: movableTokenIndices ?? this.movableTokenIndices,
    );
  }

  @override
  List<Object?> get props => [players, currentPlayerIndex, diceValue, isDiceRolled, winner, movableTokenIndices];
}

// ── BLoC Logic ────────────────────────────────────────────────────
class LudoBloc extends Bloc<LudoEvent, LudoGameState?> {
  final _random = Random();

  LudoBloc() : super(null) {
    on<LudoInitialize>(_onInitialize);
    on<LudoRollDice>(_onRollDice);
    on<LudoMovePiece>(_onMovePiece);
    on<LudoRestart>(_onRestart);
  }

  void _onInitialize(LudoInitialize event, Emitter<LudoGameState?> emit) {
    final players = [
      LudoPlayer(
        name: event.playerNames[0],
        color: LudoColor.red,
        tokens: List.generate(4, (i) => LudoToken(id: i, color: LudoColor.red)),
      ),
      LudoPlayer(
        name: event.playerNames[1],
        color: LudoColor.green,
        tokens: List.generate(4, (i) => LudoToken(id: i, color: LudoColor.green)),
      ),
    ];
    emit(LudoGameState(players: players));
  }

  void _onRollDice(LudoRollDice event, Emitter<LudoGameState?> emit) {
    if (state == null || state!.isDiceRolled) return;

    final roll = _random.nextInt(6) + 1;
    final movableIndices = _getMovableTokenIndices(state!.currentPlayer, roll);

    emit(state!.copyWith(
      diceValue: roll,
      isDiceRolled: true,
      movableTokenIndices: movableIndices,
    ));

    // If no movable tokens, switch turn automatically
    if (movableIndices.isEmpty && roll != 6) {
       Future.delayed(const Duration(milliseconds: 1500), () {
          add(const LudoMovePiece(-1)); // Pseudo-move to skip turn
       });
    }
  }

  void _onMovePiece(LudoMovePiece event, Emitter<LudoGameState?> emit) {
    if (state == null) return;

    final current = state!;
    final players = List<LudoPlayer>.from(current.players);
    final playerIdx = current.currentPlayerIndex;
    final dice = current.diceValue;

    // Turn skip (when no moves possible)
    if (event.tokenIndex == -1) {
       emit(current.copyWith(
          currentPlayerIndex: (playerIdx + 1) % players.length,
          isDiceRolled: false,
          movableTokenIndices: [],
       ));
       return;
    }

    final tokens = List<LudoToken>.from(players[playerIdx].tokens);
    var token = tokens[event.tokenIndex];

    // Determine New Position
    int newStep = token.step;
    if (token.step == 0) {
      if (dice == 6) newStep = 1;
    } else {
      if (token.step + dice <= 57) newStep = token.step + dice;
    }

    // ── Kill Mechanic ─────────────────────────────────────────────
    bool killOccurred = false;
    final newOffset = LudoConstants.getOffsetForStep(players[playerIdx].color.name.toUpperCase(), newStep, event.tokenIndex);
    final isSafeZone = LudoConstants.safeSquares.contains(newOffset);

    if (newStep > 0 && newStep < 52 && !isSafeZone) {
      for (int i = 0; i < players.length; i++) {
        if (i == playerIdx) continue; // Skip same player

        final opponentTokens = List<LudoToken>.from(players[i].tokens);
        bool playerAffected = false;

        for (int j = 0; j < opponentTokens.length; j++) {
          final oppToken = opponentTokens[j];
          if (oppToken.step > 0 && oppToken.step < 52) {
             final oppOffset = LudoConstants.getOffsetForStep(players[i].color.name.toUpperCase(), oppToken.step, j);
             if (oppOffset == newOffset) {
                opponentTokens[j] = oppToken.copyWith(step: 0);
                playerAffected = true;
                killOccurred = true;
             }
          }
        }
        if (playerAffected) {
           players[i] = LudoPlayer(name: players[i].name, color: players[i].color, tokens: opponentTokens);
        }
      }
    }

    tokens[event.tokenIndex] = token.copyWith(step: newStep);
    players[playerIdx] = LudoPlayer(name: players[playerIdx].name, color: players[playerIdx].color, tokens: tokens);

    // ── Win Check ─────────────────────────────────────────────────
    bool hasWon = tokens.every((t) => t.step >= 57);
    if (hasWon) {
       emit(current.copyWith(players: players, winner: players[playerIdx]));
       return;
    }

    // ── Turn Logic ────────────────────────────────────────────────
    // Standard rule: Extra turn for Rolling 6 OR Killing a token
    int nextPlayerIdx = (dice == 6 || killOccurred) ? playerIdx : (playerIdx + 1) % players.length;

    emit(current.copyWith(
      players: players,
      currentPlayerIndex: nextPlayerIdx,
      isDiceRolled: false,
      movableTokenIndices: [],
    ));
  }

  void _onRestart(LudoRestart event, Emitter<LudoGameState?> emit) {
    if (state == null) return;
    add(LudoInitialize(state!.players.map((p) => p.name).toList()));
  }

  List<int> _getMovableTokenIndices(LudoPlayer player, int dice) {
    List<int> movable = [];
    for (int i = 0; i < player.tokens.length; i++) {
        final t = player.tokens[i];
        if (t.step == 0 && dice == 6) movable.add(i);
        else if (t.step > 0 && t.step + dice <= 57) movable.add(i);
    }
    return movable;
  }
}
