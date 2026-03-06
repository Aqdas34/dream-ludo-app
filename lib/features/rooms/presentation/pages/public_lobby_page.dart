import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/match/presentation/bloc/match_bloc.dart';
import 'package:dream_ludo/features/match/domain/usecases/get_matches_usecase.dart';
import 'package:dream_ludo/features/online_game/data/models/online_game_model.dart';

class PublicLobbyPage extends StatelessWidget {
  const PublicLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MatchBloc>()..add(const TabChanged(MatchTab.public)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('PUBLIC LOBBY'),
          backgroundColor: AppColors.primary,
        ),
        body: BlocBuilder<MatchBloc, MatchState>(
          builder: (context, state) {
            if (state is MatchLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is MatchError) {
              return _buildError(context, state.message);
            }
            if (state is MatchLoaded) {
              final rooms = state.matches.whereType<OnlineLudoState>().toList();
              
              if (rooms.isEmpty) {
                return _buildEmpty();
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<MatchBloc>().add(const TabChanged(MatchTab.public));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return _buildRoomCard(context, rooms[index]);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, OnlineLudoState room) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.public_rounded, color: AppColors.primary),
        ),
        title: Text(
          'Room: ${room.roomId}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: Colors.white54, size: 14),
              const SizedBox(width: 8),
              Text(
                '${room.players.length} / ${room.totalPlayerCount} joined',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => context.push('/game/${room.roomId}?join=true'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('JOIN', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.white24),
          const SizedBox(height: 24),
          const Text(
            'NO PUBLIC ROOMS',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try creating one or check back later.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<MatchBloc>().add(const TabChanged(MatchTab.public)),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}
