import 'package:flutter/material.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/rewards/data/models/reward_models.dart';

class GemStorePage extends StatelessWidget {
  const GemStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy packages for now. In real app, fetch from service.
    final List<GemPackage> packages = [
      GemPackage(id: 'small', name: 'Handful of Gems', gemsAmount: 100, bonusGems: 0, price: 0.99, currency: 'USD'),
      GemPackage(id: 'medium', name: 'Bag of Gems', gemsAmount: 500, bonusGems: 50, price: 4.99, currency: 'USD', isPopular: true),
      GemPackage(id: 'large', name: 'Chest of Gems', gemsAmount: 1200, bonusGems: 200, price: 9.99, currency: 'USD'),
      GemPackage(id: 'massive', name: 'Vault of Gems', gemsAmount: 3000, bonusGems: 1000, price: 24.99, currency: 'USD'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GEM STORE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        actions: [
          _buildGemBalance(),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Power up your game experience with Gems!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPackageCard(context, packages[index]),
                childCount: packages.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGemBalance() {
    return Container(
      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.diamond_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 4),
          Text('1,240', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, GemPackage pkg) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pkg.isPopular ? AppColors.primary : Colors.white10, width: 2),
      ),
      child: Stack(
        children: [
          if (pkg.isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(22), bottomLeft: Radius.circular(12)),
                ),
                child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond_rounded, size: 60, color: AppColors.primary),
                const SizedBox(height: 12),
                Text(
                  '${pkg.gemsAmount}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                if (pkg.bonusGems > 0)
                  Text(
                    '+${pkg.bonusGems} BONUS',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('\$${pkg.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
