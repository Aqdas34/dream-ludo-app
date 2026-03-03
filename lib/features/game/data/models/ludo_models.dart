import 'package:equatable/equatable.dart';

enum LudoColor { red, green, yellow, blue }

class LudoToken extends Equatable {
  final int id;
  final LudoColor color;
  final int step; // 0 (base), 1-51 (circular), 52-57 (home stretch), 58 (home)
  final bool isSafe;

  const LudoToken({
    required this.id,
    required this.color,
    this.step = 0,
    this.isSafe = true,
  });

  LudoToken copyWith({int? step, bool? isSafe}) {
    return LudoToken(
      id: id,
      color: color,
      step: step ?? this.step,
      isSafe: isSafe ?? this.isSafe,
    );
  }

  @override
  List<Object?> get props => [id, color, step, isSafe];
}

class LudoPlayer extends Equatable {
  final String name;
  final LudoColor color;
  final List<LudoToken> tokens;

  const LudoPlayer({
    required this.name,
    required this.color,
    required this.tokens,
  });

  @override
  List<Object?> get props => [name, color, tokens];
}
