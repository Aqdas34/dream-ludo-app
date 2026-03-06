// ── matches_tab_view.dart  –  Tabbed matches view ───────────────
// Mirrors: Java → MatchFragment (UPCOMING/ONGOING/COMPLETED tabs)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/di/service_locator.dart';
import 'package:dream_ludo/core/router/app_router.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/match/domain/usecases/get_matches_usecase.dart';
import 'package:dream_ludo/features/match/presentation/bloc/match_bloc.dart';
import 'package:dream_ludo/features/match/data/models/match_model.dart';
import 'package:dream_ludo/features/online_game/data/models/online_game_model.dart';
import 'package:dream_ludo/shared/widgets/match_card.dart';

class MatchesTabView extends StatefulWidget {
  const MatchesTabView({super.key});

  @override
  State<MatchesTabView> createState() => _MatchesTabViewState();
}

class _MatchesTabViewState extends State<MatchesTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _historyFilter = 'All'; // 'All', 'Wins', 'Left'

  final _tabs = const [
    Tab(text: 'HISTORY'),
    Tab(text: 'UPCOMING'),
    Tab(text: 'ONGOING'),
    Tab(text: 'COMPLETED'),
  ];

  final _tabValues = [
    MatchTab.history,
    MatchTab.upcoming,
    MatchTab.ongoing,
    MatchTab.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<MatchBloc>()
            .add(TabChanged(_tabValues[_tabController.index]));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tabs
        Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _tabController,
            tabs: _tabs,
            isScrollable: true,
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withOpacity(0.7),
            dividerColor: Colors.transparent,
          ),
        ),

        // ── Tab Content
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F7), 
            child: BlocBuilder<MatchBloc, MatchState>(
              builder: (context, state) {
                if (state is MatchLoading) {
                  return _buildShimmer();
                }
                if (state is MatchError) {
                  return _buildError(state.message, context, state.activeTab);
                }
                if (state is MatchLoaded) {
                  List<dynamic> filteredMatches = state.matches;
                  
                  if (state.activeTab == MatchTab.history) {
                    final history = state.matches.cast<MatchModel>();
                    if (_historyFilter == 'Wins') {
                      filteredMatches = history.where((m) => m.resultStatus == "COMPLETED").toList();
                    } else if (_historyFilter == 'Left') {
                      filteredMatches = history.where((m) => m.resultStatus == "LEFT").toList();
                    }
                  }

                  if (filteredMatches.isEmpty) {
                    return Column(
                      children: [
                        if (state.activeTab == MatchTab.history) _buildFilterBar(),
                        Expanded(child: _buildEmpty(state.activeTab)),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      if (state.activeTab == MatchTab.history) _buildFilterBar(),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            context.read<MatchBloc>().add(
                                  RefreshMatches(state.activeTab),
                                );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: filteredMatches.length,
                            itemBuilder: (_, i) {
                              final item = filteredMatches[i];
                              
                              if (state.activeTab == MatchTab.history) {
                                return _buildHistoryCard(item as MatchModel);
                              }
                              
                              final match = item as MatchModel;
                              return MatchCard(
                                match: match,
                                showJoinButton: state.activeTab == MatchTab.upcoming,
                                onTap: () => context
                                    .push('/match/${match.id}', extra: match),
                                onJoinTap: () =>
                                    context.push('/match/${match.id}', extra: match),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublicRoomCard(OnlineLudoState room) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.public, color: AppColors.primary),
        ),
        title: Text('Public Room: ${room.roomId}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${room.players.length}/${room.totalPlayerCount} Players joined', style: const TextStyle(color: AppColors.textHint)),
        trailing: ElevatedButton(
          onPressed: () => context.push('/game/${room.roomId}?join=true'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: const Text('JOIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 8),
          _buildFilterChip('Wins'),
          const SizedBox(width: 8),
          _buildFilterChip('Left'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _historyFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _historyFilter = label);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textDark,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: isSelected ? AppColors.primary : Colors.black12),
      showCheckmark: false,
    );
  }

  Widget _buildHistoryCard(MatchModel match) {
    final bool isWin = match.resultStatus == "COMPLETED";
    final statusColor = isWin ? Colors.green : Colors.redAccent;
    final List<String> names = match.participantNames;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: statusColor.withOpacity(0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(isWin ? Icons.emoji_events_rounded : Icons.logout_rounded, 
                        color: statusColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isWin ? 'Match Won' : 'Match Left',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '#${match.roomId ?? "N/A"}',
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PARTICIPANTS', style: TextStyle(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: names.isEmpty 
                                ? [const Text('No names recorded', style: TextStyle(color: AppColors.textHint, fontSize: 12))]
                                : names.take(4).map((n) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F0FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(n, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  )).toList(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Column(
                          children: [
                            Text('+${match.gemsAwarded ?? 0}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 20)),
                            const Text('GEMS', style: TextStyle(color: Colors.amber, fontSize: 8, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isWin) ...[
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Text('Winner: ${match.winnerName ?? "Unknown"}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceVariant,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message, BuildContext context, MatchTab tab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context
                .read<MatchBloc>()
                .add(LoadMatches(tab)),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(MatchTab tab) {
    final isHistory = tab == MatchTab.history;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isHistory ? Icons.history_toggle_off : Icons.casino_outlined,
              size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(isHistory ? 'No match history' : 'No matches found', 
            style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            isHistory ? 'Play some games to see your history!' : 'Check back later for new matches!',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
