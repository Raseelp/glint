import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class ReactionTray extends StatelessWidget {
  final Function(String) onReactionSelected;

  ReactionTray({required this.onReactionSelected});
  Color beige = const Color(0xFFF7F2E7);
  Color darkBlue = const Color(0xFF4682B4);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: beige,
          borderRadius: BorderRadius.vertical(top: Radius.circular(17))),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          LikeButton(
            likeBuilder: (bool isLiked) {
              return const Icon(Icons.thumb_up, color: Colors.blue);
            },
            onTap: (_) async {
              onReactionSelected('like');
              return false;
            },
          ),
          LikeButton(
            likeBuilder: (bool isLiked) {
              return const Icon(Icons.favorite, color: Colors.red);
            },
            onTap: (_) async {
              onReactionSelected('heart');
              return false;
            },
          ),
          LikeButton(
            likeBuilder: (bool isLiked) {
              return const Icon(Icons.emoji_emotions,
                  color: Color.fromARGB(255, 199, 180, 10));
            },
            onTap: (_) async {
              onReactionSelected('smile');
              return false;
            },
          ),
          // Add more LikeButtons for other reactions if needed
        ],
      ),
    );
  }
}
