import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/game/data/models/ludo_models.dart';
import 'package:dream_ludo/features/game/presentation/bloc/ludo_bloc.dart';
import 'package:dream_ludo/features/game/presentation/widgets/ludo_board.dart';
import 'package:dream_ludo/features/game/presentation/widgets/ludo_piece.dart';
import 'package:dream_ludo/features/game/presentation/widgets/dice_widget.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final String roomId;
  final bool isJoining;

  const GamePage({
    super.key,
    required this.roomId,
    this.isJoining = false,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final LudoBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = LudoBloc()..add(const LudoInitialize(['Player 1', 'Player 2']));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text('Dream Ludo Match', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _bloc.add(LudoRestart()),
            ),
          ],
        ),
        body: BlocBuilder<LudoBloc, LudoGameState?>(
          builder: (context, state) {
            if (state == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            return Column(
              children: [
                // ── Top Player ─────────────────────────────────────────────
                _buildPlayerHeader(state.players[1], state.currentPlayerIndex == 1),
                
                const Spacer(),
                
                // ── Ludo Board & Pieces Stack ──────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final boardWidth = constraints.maxWidth - 32;
                    final cellSize = boardWidth / 15;
                    return Center(
                      child: Container(
                        width: boardWidth,
                        child: Stack(
                          children: [
                            const LudoBoardWidget(),
                            // Tokens
                            ...state.players.expand((p) => p.tokens.asMap().entries.map((e) {
                               final isMovable = state.currentPlayer.color == p.color && state.movableTokenIndices.contains(e.key);
                               return LudoPieceWidget(
                                  token: e.value,
                                  cellSize: cellSize,
                                  isSelectable: isMovable,
                                  onTap: () => _bloc.add(LudoMovePiece(e.key)),
                               );
                            })),

                            // Winner Overlay
                            if (state.winner != null)
                              _buildWinnerOverlay(state.winner!),
                          ],
                        ),
                      ),
                    );
                  }
                ),

                const Spacer(),

                // ── Dice & Current Turn ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       _buildDiceInfo(state),
                       DiceWidget(
                          value: state.diceValue,
                          isRolling: false, // Animation happens in BLoC sequence (TBD: simulated here)
                          isMyTurn: !state.isDiceRolled,
                          onTap: () => _bloc.add(LudoRollDice()),
                       ),
                    ],
                  ),
                ),

                // ── Bottom Player ──────────────────────────────────────────
                _buildPlayerHeader(state.players[0], state.currentPlayerIndex == 0),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerHeader(LudoPlayer player, bool isActive) {
    final color = _getColor(player.color);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: color, width: 2) : Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(isActive ? 'YOUR TURN' : 'WAITING...', style: TextStyle(color: isActive ? color : Colors.white54, fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
          const Spacer(),
          if (isActive) const Icon(Icons.stars, color: Colors.amber),
        ],
      ),
    );
  }

  Widget _buildDiceInfo(LudoGameState state) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Dice: ${state.diceValue}', 
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
           const SizedBox(height: 4),
           Text(state.isDiceRolled ? 'MOVE TOKEN!' : 'ROLL THE DICE!', 
              style: TextStyle(color: state.isDiceRolled ? Colors.amber : Colors.white54, fontWeight: FontWeight.bold)),
        ],
     );
  }

  Widget _buildWinnerOverlay(LudoPlayer winner) {
     return Center(
       child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
             color: Colors.black87,
             borderRadius: BorderRadius.circular(30),
             border: Border.all(color: AppColors.gold, width: 3),
             boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 40, spreadRadius: 10)],
          ),
          child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 80),
                const SizedBox(height: 16),
                Text('WINNER!', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(winner.name.toUpperCase(), style: const TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 24),
                ElevatedButton(
                   onPressed: () => _bloc.add(LudoRestart()),
                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                   child: const Text('PLAY AGAIN', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ),
             ],
          ),
       ),
     );
  }

  Color _getColor(LudoColor c) {
    switch (c) {
      case LudoColor.red: return Colors.red;
      case LudoColor.green: return Colors.green;
      case LudoColor.yellow: return Colors.yellow;
      case LudoColor.blue: return Colors.blue;
    }
  }
}
