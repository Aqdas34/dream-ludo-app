import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';

class CreateRoomBottomSheet extends StatefulWidget {
  const CreateRoomBottomSheet({super.key});

  @override
  State<CreateRoomBottomSheet> createState() => _CreateRoomBottomSheetState();
}

class _CreateRoomBottomSheetState extends State<CreateRoomBottomSheet> {
  bool _isPrivate = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'CREATE ONLINE ROOM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Private Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Only friends with code can join', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              Switch(
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final roomCode = (100000 + (DateTime.now().millisecond * 89900)).toString().substring(0, 6);
              context.push('/game/$roomCode?privacy=$_isPrivate');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('CREATE & PLAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
