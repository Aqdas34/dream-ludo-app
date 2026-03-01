// ── match_card.dart  –  Reusable match card widget ─────────────

import 'package:flutter/material.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/match/data/models/match_model.dart';
import 'package:dream_ludo/shared/widgets/app_button.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onJoinTap;
  final VoidCallback? onTap;
  final bool showJoinButton;

  const MatchCard({
    super.key,
    required this.match,
    this.onJoinTap,
    this.onTap,
    this.showJoinButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Accent Bar (matches FrameLayout weight 0.015)
            Container(
              width: 5,
              color: AppColors.primaryLight,
            ),

            // Main Content (matches weight 0.935)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Board Number
                    Text(
                      '#${match.id} BOARD NUMBER',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Stats Row: Win | Timer | Fee
                    Row(
                      children: [
                        // Win
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₹${match.prize?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Text('Win', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            ],
                          ),
                        ),

                        // Timer
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              const Text(
                                'Board close in\n1m 30s',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textHint),
                              ),
                            ],
                          ),
                        ),

                        // Fee
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${match.matchFee?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const Text('Fee', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Progress and Join Row
                    Row(
                      children: [
                        // Spots Left / Progress
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: ((match.tableSize ?? 0) - (match.spotsLeft ?? 0)) / (match.tableSize ?? 1),
                                backgroundColor: AppColors.grey10,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                minHeight: 4,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Only ${match.spotsLeft ?? 0} player left',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                                  ),
                                  Text(
                                    'Player:${(match.tableSize ?? 0) - (match.spotsLeft ?? 0)}/${match.tableSize ?? 0}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Join Button
                        if (showJoinButton)
                          ElevatedButton(
                            onPressed: match.isOpen ? onJoinTap : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primaryLight,
                              minimumSize: const Size(60, 29),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              side: const BorderSide(color: AppColors.primaryLight),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              elevation: 0,
                            ),
                            child: const Text('Join', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Right Type Bar (matches VerticalTextView weight 0.06)
            Container(
              width: 30,
              color: AppColors.primaryLight,
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    match.tableSize == 2 ? 'SINGLE' : '4 PLAYERS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final int spotsLeft;
  const _StatusChip({required this.spotsLeft});

  @override
  Widget build(BuildContext context) {
    final color =
        spotsLeft == 0 ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        spotsLeft == 0 ? 'FULL' : '$spotsLeft OPEN',
        style: AppTextStyles.caption.copyWith(color: color),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoTile({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(value, style: valueStyle ?? AppTextStyles.heading3),
      ],
    );
  }
}
