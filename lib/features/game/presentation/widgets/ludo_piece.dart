import 'package:flutter/material.dart';
import 'package:dream_ludo/features/game/data/models/ludo_models.dart';
import 'package:dream_ludo/features/game/utils/ludo_constants.dart';

class LudoPieceWidget extends StatelessWidget {
  final LudoToken token;
  final double cellSize;
  final bool isSelectable;
  final VoidCallback onTap;

  const LudoPieceWidget({
    super.key,
    required this.token,
    required this.cellSize,
    required this.isSelectable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final offset = LudoConstants.getOffsetForStep(
      token.color.name.toUpperCase(),
      token.step,
      token.id,
    );

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: offset.dy * cellSize, // Row/Col swap for Dy/Dx in Flutter
      top: offset.dx * cellSize,
      child: GestureDetector(
        onTap: isSelectable ? onTap : null,
        child: Container(
          width: cellSize,
          height: cellSize,
          padding: EdgeInsets.all(cellSize * 0.15),
          child: Container(
            decoration: BoxDecoration(
              color: _getColor(),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                 if (isSelectable)
                   BoxShadow(color: _getColor().withOpacity(0.5), blurRadius: 8, spreadRadius: 4),
                 BoxShadow(color: Colors.black26, offset: const Offset(2, 2), blurRadius: 2),
              ],
            ),
            child: Center(
              child: isSelectable 
                ? const Icon(Icons.touch_app_rounded, color: Colors.white, size: 10) 
                : null,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (token.color) {
      case LudoColor.red: return Colors.red;
      case LudoColor.green: return Colors.green;
      case LudoColor.yellow: return Colors.yellow;
      case LudoColor.blue: return Colors.blue;
    }
  }
}
