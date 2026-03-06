import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_ludo/core/theme/app_theme.dart';
import 'package:dream_ludo/features/online_game/presentation/bloc/online_ludo_bloc.dart';
import 'package:dream_ludo/features/online_game/data/models/online_game_model.dart';

class GameChatOverlay extends StatefulWidget {
  const GameChatOverlay({super.key});

  @override
  State<GameChatOverlay> createState() => _GameChatOverlayState();
}

class _GameChatOverlayState extends State<GameChatOverlay> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineLudoBloc, OnlineLudoState>(
      builder: (context, state) {
        return Stack(
          children: [
            if (_isExpanded) _buildChatWindow(context, state),
            _buildFloatingButton(),
          ],
        );
      },
    );
  }

  Widget _buildFloatingButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        heroTag: 'chat_fab',
        mini: true,
        onPressed: () => setState(() => _isExpanded = !_isExpanded),
        backgroundColor: AppColors.primary,
        child: Icon(_isExpanded ? Icons.close : Icons.chat_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildChatWindow(BuildContext context, OnlineLudoState state) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      bottom: isKeyboardOpen ? keyboardHeight + 10 : 120,
      right: 20,
      left: 20,
      child: Container(
        height: isKeyboardOpen ? 220 : 320,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
          boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 20, spreadRadius: 5)],
        ),
        child: Column(
          children: [
            _buildChatHeader(),
            Expanded(child: _buildMessagesList(state.messages)),
            if (!isKeyboardOpen) _buildQuickReplies(),
            _buildInputField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('REAL-TIME CHAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                CircleAvatar(backgroundColor: Colors.green, radius: 2),
                SizedBox(width: 4),
                Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<OnlineChatMessage> messages) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '${msg.username}: ', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                TextSpan(text: msg.message, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickReplies() {
     final replies = ['Good luck!', 'Well played!', 'Nice move!', 'GG 🎮', 'Ouch!', 'Hurry up!'];
     return Container(
       height: 40,
       padding: const EdgeInsets.only(bottom: 8),
       child: ListView.builder(
         scrollDirection: Axis.horizontal,
         padding: const EdgeInsets.symmetric(horizontal: 16),
         itemCount: replies.length,
         itemBuilder: (context, index) => GestureDetector(
           onTap: () => context.read<OnlineLudoBloc>().add(SendChatMessage(replies[index])),
           child: Container(
             margin: const EdgeInsets.only(right: 8),
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
             decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
             child: Center(child: Text(replies[index], style: const TextStyle(color: Colors.white, fontSize: 10))),
           ),
         ),
       ),
     );
  }

  Widget _buildInputField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onSubmitted: (v) => _sendMessage(context),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () => _sendMessage(context),
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<OnlineLudoBloc>().add(SendChatMessage(_messageController.text.trim()));
      _messageController.clear();
    }
  }
}
