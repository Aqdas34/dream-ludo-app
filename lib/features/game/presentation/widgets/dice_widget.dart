import 'package:flutter/material.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';

class DiceWidget extends StatefulWidget {
  final int value;
  final bool isRolling;
  final bool isMyTurn;
  final VoidCallback onTap;

  const DiceWidget({
    super.key,
    required this.value,
    this.isRolling = false,
    required this.isMyTurn,
    required this.onTap,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _controller.repeat();
    } else if (!widget.isRolling && oldWidget.isRolling) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMyTurn && !widget.isRolling ? widget.onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isMyTurn ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             if (widget.isMyTurn)
               BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 15, spreadRadius: 5)
          ],
        ),
        child: RotationTransition(
          turns: _controller,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))],
            ),
            child: Icon(
              _getDiceIcon(widget.value),
              size: 50,
              color: widget.isMyTurn ? AppColors.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDiceIcon(int value) {
    switch (value) {
      case 1: return Icons.casino_outlined;
      case 2: return Icons.looks_two_outlined;
      case 3: return Icons.looks_3_outlined;
      case 4: return Icons.looks_4_outlined;
      case 5: return Icons.looks_5_outlined;
      case 6: return Icons.looks_6_outlined;
      default: return Icons.casino_rounded;
    }
  }
}
