import 'package:flutter/material.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/game/utils/ludo_constants.dart';

class LudoBoardWidget extends StatelessWidget {
  const LudoBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 15,
          ),
          itemCount: 225,
          itemBuilder: (context, index) {
            int row = index ~/ 15;
            int col = index % 15;
            return _buildCell(row, col);
          },
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col) {
    Color? color;
    Widget? child;

    // ── Base Areas ────────────────────────────────────────────────
    if (row < 6 && col < 6) color = Colors.green.withOpacity(0.15); // Top-Left
    else if (row < 6 && col > 8) color = Colors.yellow.withOpacity(0.15); // Top-Right
    else if (row > 8 && col < 6) color = Colors.red.withOpacity(0.15); // Bottom-Left
    else if (row > 8 && col > 8) color = Colors.blue.withOpacity(0.15); // Bottom-Right

    // ── Home Paths AND Safe Zone ──────────────────────────────────
    final offset = Offset(row.toDouble(), col.toDouble());
    
    // Check if it's a home path
    LudoConstants.homePaths.forEach((c, path) {
       if (path.contains(offset)) {
          if (c == 'RED') color = Colors.red;
          else if (c == 'GREEN') color = Colors.green;
          else if (c == 'YELLOW') color = Colors.yellow;
          else if (c == 'BLUE') color = Colors.blue;
       }
    });

    // Check if it's a safe square (star)
    if (LudoConstants.safeSquares.contains(offset)) {
       child = const Icon(Icons.stars_rounded, size: 10, color: Colors.grey);
    }

    // ── Middle Home Center ────────────────────────────────────────
    if (row >= 6 && row <= 8 && col >= 6 && col <= 8) {
       color = Colors.white;
       if (row == 7 && col == 7) color = AppColors.primary;
    }

    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 0.2),
      ),
      child: child,
    );
  }
}
