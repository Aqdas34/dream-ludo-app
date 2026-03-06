// ── match_bloc.dart  –  Match state management ─────────────────

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dream_ludo/core/services/storage_service.dart';
import 'package:dream_ludo/core/services/socket_service.dart';
import 'package:dream_ludo/features/match/data/models/match_model.dart';
import 'package:dream_ludo/features/match/domain/usecases/get_matches_usecase.dart';
import 'package:dream_ludo/features/online_game/data/models/online_game_model.dart';

// ── Events ────────────────────────────────────────────────────

abstract class MatchEvent extends Equatable {
  const MatchEvent();
  @override
  List<Object?> get props => [];
}

class LoadMatches extends MatchEvent {
  final MatchTab tab;
  const LoadMatches(this.tab);
  @override
  List<Object> get props => [tab];
}

class RefreshMatches extends MatchEvent {
  final MatchTab tab;
  const RefreshMatches(this.tab);
  @override
  List<Object> get props => [tab];
}

class TabChanged extends MatchEvent {
  final MatchTab tab;
  const TabChanged(this.tab);
  @override
  List<Object> get props => [tab];
}

class MatchUpdatedFromWS extends MatchEvent {
  final MatchModel updatedMatch;
  const MatchUpdatedFromWS(this.updatedMatch);
  @override
  List<Object> get props => [updatedMatch];
}

class PublicRoomsReceived extends MatchEvent {
  final List<OnlineLudoState> rooms;
  const PublicRoomsReceived(this.rooms);
  @override
  List<Object> get props => [rooms];
}

// ── States ────────────────────────────────────────────────────

abstract class MatchState extends Equatable {
  final MatchTab activeTab;
  const MatchState({this.activeTab = MatchTab.history});
  @override
  List<Object?> get props => [activeTab];
}

class MatchInitial extends MatchState {}

class MatchLoading extends MatchState {
  const MatchLoading({super.activeTab});
}

class MatchLoaded extends MatchState {
  final List<dynamic> matches; // Can be List<MatchModel> or List<OnlineLudoState>
  const MatchLoaded(this.matches, {super.activeTab});
  @override
  List<Object> get props => [matches, activeTab];
}

class MatchError extends MatchState {
  final String message;
  const MatchError(this.message, {super.activeTab});
  @override
  List<Object> get props => [message, activeTab];
}

// ── BLoC ──────────────────────────────────────────────────────

class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final GetMatchesUseCase _getMatchesUseCase;
  final StorageService _storage;
  final SocketService _socketService;

  MatchTab _currentTab = MatchTab.history;

  MatchBloc({
    required GetMatchesUseCase getMatchesUseCase,
    required StorageService storage,
    required SocketService socketService,
  })  : _getMatchesUseCase = getMatchesUseCase,
        _storage = storage,
        _socketService = socketService,
        super(MatchInitial()) {
    on<LoadMatches>(_onLoadMatches);
    on<RefreshMatches>(_onLoadMatches);
    on<TabChanged>(_onTabChanged);
    on<MatchUpdatedFromWS>(_onMatchUpdatedFromWS);
    on<PublicRoomsReceived>((event, emit) {
      if (_currentTab == MatchTab.public) {
        emit(MatchLoaded(event.rooms, activeTab: MatchTab.public));
      }
    });

    _setupPublicRoomsListener();
  }

  Future<void> _onLoadMatches(MatchEvent event, Emitter<MatchState> emit) async {
    final tab = event is LoadMatches ? event.tab : (event as RefreshMatches).tab;
    _currentTab = tab;

    if (event is LoadMatches) {
      emit(MatchLoading(activeTab: tab));
    }

    if (tab == MatchTab.public) {
      _socketService.emit('getPublicRooms', {});
      return; 
    }

    final userId = await _storage.getUserId() ?? '';
    final result = await _getMatchesUseCase(userId: userId, tab: tab);

    result.fold(
      (failure) => emit(MatchError(failure.message, activeTab: tab)),
      (matches) => emit(MatchLoaded(matches, activeTab: tab)),
    );
  }

  void _onTabChanged(TabChanged event, Emitter<MatchState> emit) {
    _currentTab = event.tab;
    add(LoadMatches(event.tab));
  }

  void _onMatchUpdatedFromWS(
      MatchUpdatedFromWS event, Emitter<MatchState> emit) {
    if (state is MatchLoaded) {
      final current = (state as MatchLoaded).matches;
      final updated = current.map((m) {
        return m.id == event.updatedMatch.id ? event.updatedMatch : m;
      }).toList();
      emit(MatchLoaded(updated, activeTab: _currentTab));
    }
  }

  // Subscribe to Socket.IO for live match updates
  void subscribeToMatchUpdates() {
    _socketService.connect().then((_) {
      _socketService.on('matchesUpdate', (message) {
        try {
          // Socket.IO often sends direct objects, not JSON strings
          final json = message is String ? jsonDecode(message) : message;
          final updatedMatch = MatchModel.fromJson(json as Map<String, dynamic>);
          add(MatchUpdatedFromWS(updatedMatch));
        } catch (_) {}
      });
    }).catchError((e) {
      print('❌ MatchBloc: Socket connection failed: $e');
    });
  }

  void _setupPublicRoomsListener() {
    _socketService.connect().then((_) {
      _socketService.on('publicRoomsList', (data) {
        try {
          final listData = data as List;
          final rooms = listData.map((json) => OnlineLudoState.fromJson(json as Map<String, dynamic>)).toList();
          add(PublicRoomsReceived(rooms));
        } catch (_) {}
      });
    });
  }
}
