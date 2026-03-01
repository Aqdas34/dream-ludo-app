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
import 'package:dream_ludo/shared/widgets/match_card.dart';

class MatchesTabView extends StatefulWidget {
  const MatchesTabView({super.key});

  @override
  State<MatchesTabView> createState() => _MatchesTabViewState();
}

class _MatchesTabViewState extends State<MatchesTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _tabs = const [
    Tab(text: 'UPCOMING'),
    Tab(text: 'ONGOING'),
    Tab(text: 'COMPLETED'),
  ];

  final _tabValues = [
    MatchTab.upcoming,
    MatchTab.ongoing,
    MatchTab.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        // ── Tabs (Red background in Kotlin fragment_match.xml) ─────
        Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _tabController,
            tabs: _tabs,
            isScrollable: false,
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withOpacity(0.7),
            dividerColor: Colors.transparent,
          ),
        ),

        // ── Tab Content ───────────────────────────────────────────
        Expanded(
          child: Container(
            color: AppColors.white, // Most lists in Kotlin have light bg? 
            // Actually usually white/light grey for cards.
            child: BlocBuilder<MatchBloc, MatchState>(
              builder: (context, state) {
                if (state is MatchLoading) {
                  return _buildShimmer();
                }
                if (state is MatchError) {
                  return _buildError(state.message, context);
                }
                if (state is MatchLoaded) {
                  if (state.matches.isEmpty) {
                    return _buildEmpty();
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<MatchBloc>().add(
                            RefreshMatches(state.activeTab),
                          );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: state.matches.length,
                      itemBuilder: (_, i) {
                        final match = state.matches[i];
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

  Widget _buildError(String message, BuildContext context) {
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
                .add(const LoadMatches(MatchTab.upcoming)),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.casino_outlined,
              size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No matches found', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Check back later for new matches!',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
