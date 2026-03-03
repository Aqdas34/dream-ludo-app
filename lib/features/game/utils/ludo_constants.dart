import 'package:flutter/material.dart';

class LudoConstants {
  static const int boardSize = 15;
  static const int totalCells = boardSize * boardSize;

  // ── Coordinates for the common path (52 steps) ───────────────────
  // Standard Ludo circular path
  static const List<Offset> commonPath = [
    Offset(6, 1), Offset(6, 2), Offset(6, 3), Offset(6, 4), Offset(6, 5),   // Top-Middle Right (Red Start)
    Offset(5, 6), Offset(4, 6), Offset(3, 6), Offset(2, 6), Offset(1, 6), Offset(0, 6), // Top-Left Up
    Offset(0, 7), Offset(0, 8),                                            // Center-Top
    Offset(1, 8), Offset(2, 8), Offset(3, 8), Offset(4, 8), Offset(5, 8),   // Top-Right Down
    Offset(6, 9), Offset(6, 10), Offset(6, 11), Offset(6, 12), Offset(6, 13), Offset(6, 14), // Right-Top Right
    Offset(7, 14), Offset(8, 14),                                          // Center-Right
    Offset(8, 13), Offset(8, 12), Offset(8, 11), Offset(8, 10), Offset(8, 9), // Right-Bottom Left
    Offset(9, 8), Offset(10, 8), Offset(11, 8), Offset(12, 8), Offset(13, 8), Offset(14, 8), // Bottom-Right Down
    Offset(14, 7), Offset(14, 6),                                          // Center-Bottom
    Offset(13, 6), Offset(12, 6), Offset(11, 6), Offset(10, 6), Offset(9, 6), // Bottom-Left Up
    Offset(8, 5), Offset(8, 4), Offset(8, 3), Offset(8, 2), Offset(8, 1), Offset(8, 0), // Left-Bottom Left
    Offset(7, 0),                                                          // Center-Left
  ];

  // ── Home Paths for each color (6 steps each inclusive of home) ──
  static const Map<String, List<Offset>> homePaths = {
    'RED': [
      Offset(7, 1), Offset(7, 2), Offset(7, 3), Offset(7, 4), Offset(7, 5), Offset(7, 6)
    ],
    'GREEN': [
      Offset(1, 7), Offset(2, 7), Offset(3, 7), Offset(4, 7), Offset(5, 7), Offset(6, 7)
    ],
    'YELLOW': [
      Offset(7, 13), Offset(7, 12), Offset(7, 11), Offset(7, 10), Offset(7, 9), Offset(7, 8)
    ],
    'BLUE': [
      Offset(13, 7), Offset(12, 7), Offset(11, 7), Offset(10, 7), Offset(9, 7), Offset(8, 7)
    ],
  };

  // ── Starting offsets in commonPath for each color ───────────────
  static const Map<String, int> startSteps = {
    'RED': 0,
    'GREEN': 13,
    'YELLOW': 26,
    'BLUE': 39,
  };

  // ── Base Positions (where tokens live when at home) ──────────────
  static const Map<String, List<Offset>> basePositions = {
    'RED': [Offset(1, 1), Offset(1, 4), Offset(4, 1), Offset(4, 4)],
    'GREEN': [Offset(1, 10), Offset(1, 13), Offset(4, 10), Offset(4, 13)],
    'YELLOW': [Offset(10, 10), Offset(10, 13), Offset(13, 10), Offset(13, 13)],
    'BLUE': [Offset(10, 1), Offset(10, 4), Offset(13, 1), Offset(13, 4)],
  };

  // ── Safe Squares (Star Positions) ───────────────────────────────
  static const List<Offset> safeSquares = [
    Offset(6, 1),   // Red Start
    Offset(8, 2),   // Random safe
    Offset(1, 8),   // Green Start
    Offset(2, 6),   // Random safe
    Offset(6, 13),  // Yellow Start
    Offset(7, 14),  // Random safe
    Offset(8, 13),  // Random safe
    Offset(13, 6),  // Blue Start
  ];

  // ── Get Offset for a Step ───────────────────────────────────────
  static Offset getOffsetForStep(String color, int step, int tokenId) {
    if (step == 0) {
      return basePositions[color]![tokenId];
    }
    if (step >= 58) {
      return const Offset(7, 7); // Center Home
    }
    if (step >= 52) {
      return homePaths[color]![step - 52];
    }

    // Common Path
    int startIndex = startSteps[color]!;
    int commonIndex = (startIndex + (step - 1)) % commonPath.length;
    return commonPath[commonIndex];
  }
}
