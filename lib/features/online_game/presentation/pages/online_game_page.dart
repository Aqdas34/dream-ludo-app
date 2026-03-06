import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/online_game/presentation/bloc/online_ludo_bloc.dart';
import 'package:dream_ludo/features/online_game/data/models/online_game_model.dart';
import 'package:dream_ludo/features/online_game/presentation/widgets/game_chat_overlay.dart';
import 'package:dream_ludo/features/game/presentation/widgets/ludo_board.dart';
import 'package:dream_ludo/features/game/utils/ludo_constants.dart';
import 'package:dream_ludo/features/game/presentation/widgets/dice_widget.dart';
import 'package:dream_ludo/core/services/storage_service.dart';

class OnlineGamePage extends StatefulWidget {
  final String roomId;
  final bool isJoining;
  final bool isPrivate;

  const OnlineGamePage({
    super.key,
    required this.roomId,
    this.isJoining = false,
    this.isPrivate = true,
  });

  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  late final OnlineLudoBloc _bloc;
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    _bloc = sl<OnlineLudoBloc>();
    _initUser();
  }

  Future<void> _initUser() async {
    final storage = sl<StorageService>();
    String? uid = await storage.getUserId();
    String? username = storage.getString(StorageKeys.username);
    
    if (uid == null || uid.isEmpty) {
      uid = await _getOrGenerateGuestId();
    }
    
    if (username == null || username.isEmpty) {
       username = 'Guest_${uid.toString().substring(uid.length - 4)}';
    }

    if (mounted) {
      setState(() => currentUserId = uid!);
      _bloc.add(ConnectToGame(
        widget.roomId, 
        isJoining: widget.isJoining,
        isPrivate: widget.isPrivate,
        userId: uid,
        username: username,
      ));
    }
  }

  Future<String> _getOrGenerateGuestId() async {
    final storage = sl<StorageService>();
    String guestId = storage.getString('GUEST_ID');
    if (guestId.isEmpty) {
      guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      await storage.setString('GUEST_ID', guestId);
    }
    return guestId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ONLINE BATTLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Room: ${widget.roomId}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          actions: [
            _buildRoomInfo(),
          ],
        ),
        body: BlocBuilder<OnlineLudoBloc, OnlineLudoState>(
          builder: (context, state) {
            if (state.errorMessage != null) {
              return _buildErrorState(state.errorMessage!);
            }

            if (state.status == OnlineGameStatus.waiting) {
              return _buildLobby(state);
            }

            return Stack(
              children: [
                _buildGameBoard(state),
                const GameChatOverlay(),
                if (state.status == OnlineGameStatus.finished) _buildWinnerOverlay(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoomInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: const Row(
            children: [
              CircleAvatar(backgroundColor: Colors.green, radius: 3),
              SizedBox(width: 8),
              Text('SYNCED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLobby(OnlineLudoState state) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.meeting_room_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text('ROOM LOBBY', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Waiting for players to join (${state.players.length}/${state.totalPlayerCount})...', style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 48),
          Expanded(
            child: ListView.builder(
              key: ValueKey('lobby_${state.players.length}_${state.status}'), // Force rebuild on length/status change
              itemCount: state.totalPlayerCount,
              itemBuilder: (context, index) {
                final player = index < state.players.length ? state.players[index] : null;
                return _buildLobbyPlayerTile(player, index);
              },
            ),
          ),
          const SizedBox(height: 24),
          if (state.players.isNotEmpty && state.players.first.userId == currentUserId)
            ElevatedButton(
              onPressed: state.players.length >= 2 
                  ? () => _bloc.add(StartGameRequested())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('START GAME', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildLobbyPlayerTile(OnlineLudoPlayer? player, int index) {
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: AppColors.surface,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white10),
       ),
       child: Row(
         children: [
           CircleAvatar(
             backgroundColor: player != null ? _parseColor(player.color) : Colors.white12,
             child: player != null ? const Icon(Icons.person, color: Colors.white) : const Icon(Icons.add, color: Colors.white38),
           ),
           const SizedBox(width: 16),
           Text(player?.username ?? 'Waiting for Player...', 
             style: TextStyle(color: player != null ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
           const Spacer(),
           if (player != null) const Icon(Icons.check_circle, color: Colors.green, size: 20),
         ],
       ),
     );
  }

  Widget _buildGameBoard(OnlineLudoState state) {
    final currentPlayer = state.players[state.turn];
    final isMyTurn = currentPlayer.userId.toString() == currentUserId.toString();

    return Column(
      children: [
        // Opponent Headers
        _buildOpponentHeaders(state),
        const Spacer(),
        _buildBoard(state),
        const Spacer(),
        // Bottom Control Bar
        _buildControlBar(state, isMyTurn),
      ],
    );
  }

  Widget _buildBoard(OnlineLudoState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth - 40;
        final cellSize = boardWidth / 15;
        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardWidth,
            child: Stack(
              children: [
                const LudoBoardWidget(),
                // Tokens
                ...state.players.asMap().entries.expand((playerEntry) {
                   final pIdx = playerEntry.key;
                   final player = playerEntry.value;
                   return player.pieces.asMap().entries.map((pieceEntry) {
                      final tokenId = pieceEntry.key;
                      final step = pieceEntry.value;
                      final offset = LudoConstants.getOffsetForStep(player.color, step, tokenId);
                      
                      final isMyTurn = state.players[state.turn].userId.toString() == currentUserId.toString();
                      final isMovable = isMyTurn && state.hasRolled && player.userId.toString() == currentUserId.toString() && _canMove(step, state.diceValue);

                      return _buildAnimatedPiece(offset, cellSize, player.color, isMovable, tokenId);
                   });
                }),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildAnimatedPiece(Offset offset, double cellSize, String colorName, bool isMovable, int tokenId) {
     return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        top: offset.dx * cellSize,
        left: offset.dy * cellSize,
        width: cellSize,
        height: cellSize,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isMovable ? () => _bloc.add(PieceMoveRequested(tokenId)) : null,
          child: Container(
            margin: const EdgeInsets.all(2), // Smaller margin makes piece larger
            decoration: BoxDecoration(
              color: _parseColor(colorName),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                if (isMovable) ...[
                  BoxShadow(color: _parseColor(colorName).withOpacity(0.8), blurRadius: 12, spreadRadius: 4),
                  BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 4, spreadRadius: 1),
                ],
                BoxShadow(color: Colors.black26, offset: const Offset(1, 1), blurRadius: 2),
              ],
            ),
            child: isMovable 
              ? const Center(child: Icon(Icons.touch_app_rounded, size: 16, color: Colors.white)) 
              : null,
          ),
        ),
     );
  }

  bool _canMove(int currentStep, int diceValue) {
     if (currentStep == 0 && diceValue != 6) return false;
     if (currentStep + diceValue > 57) return false;
     return true;
  }

  Widget _buildControlBar(OnlineLudoState state, bool isMyTurn) {
     final currentPlayer = state.players.isNotEmpty ? state.players[state.turn % state.players.length] : null;
     if (currentPlayer == null) return const SizedBox.shrink();

     return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isMyTurn ? 'YOUR TURN' : '${currentPlayer.username.toUpperCase()}\'S TURN', 
                  style: TextStyle(color: isMyTurn ? AppColors.primary : Colors.white54, fontWeight: FontWeight.w900, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Roll the dice to move', style: TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
            DiceWidget(
              value: state.diceValue,
              isRolling: state.isRolling,
              isMyTurn: isMyTurn && !state.isRolling,
              onTap: () => _bloc.add(RollDiceRequested()),
            ),
          ],
        ),
     );
  }

  Widget _buildOpponentHeaders(OnlineLudoState state) {
     final opponents = state.players.where((p) => p.userId != currentUserId).toList();
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceAround,
         children: opponents.map((opt) => Column(
           children: [
             CircleAvatar(
               backgroundColor: _parseColor(opt.color),
               radius: 12,
               child: const Icon(Icons.person, size: 14, color: Colors.white),
             ),
             const SizedBox(height: 4),
             Text(opt.username, style: const TextStyle(color: Colors.white54, fontSize: 8)),
           ],
         )).toList(),
       ),
     );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => context.pop(), child: const Text('GO BACK')),
        ],
      ),
    );
  }

  Widget _buildWinnerOverlay(OnlineLudoState state) {
      final winner = state.players.firstWhere((p) => p.userId == state.winner, orElse: () => state.players.first);
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
              const SizedBox(height: 24),
              const Text('GAMEOVER', style: TextStyle(color: Colors.white54, fontSize: 16, letterSpacing: 4)),
              Text('${winner.username.toUpperCase()} WINS!', 
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                child: const Text('EXIT LOBBY'),
              ),
            ],
          ),
        ),
      );
  }

  Color _parseColor(String color) {
    switch (color) {
      case 'RED': return Colors.red;
      case 'GREEN': return Colors.green;
      case 'YELLOW': return Colors.yellow;
      case 'BLUE': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
