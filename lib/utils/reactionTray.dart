import 'package:cloud_firestore/cloud_firestore.dart';
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

class ReactionsDisplay extends StatefulWidget {
  final String groupId;
  final String imageId;

  ReactionsDisplay({required this.groupId, required this.imageId});

  @override
  State<ReactionsDisplay> createState() => _ReactionsDisplayState();
}

class _ReactionsDisplayState extends State<ReactionsDisplay> {
  late Map<String, String> _cachedReactions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cachedReactions = {};
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('images')
          .doc(widget.imageId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (_isLoading) {
            return const CircularProgressIndicator(); // Show loading only the first time
          }
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No reactions yet"));
        }

        var imageData = snapshot.data!.data() as Map<String, dynamic>;
        Map<String, dynamic> reactions = imageData['reactions'] ?? {};

        // Only rebuild if reactions have changed
        if (_cachedReactions != reactions) {
          _cachedReactions = Map.from(reactions);
          _isLoading = false;
        }

        List<String> displayedReactions = _cachedReactions.values.toList();
        String extraReactionsCount = displayedReactions.length > 5
            ? "+${displayedReactions.length - 5} more"
            : '';

        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.grey.withOpacity(0.5)),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...displayedReactions.take(5).map((reactionType) {
                return Text(
                  getReactionEmoji(reactionType),
                  style: TextStyle(fontSize: 20),
                );
              }).toList(),
              if (extraReactionsCount.isNotEmpty)
                Text(
                  extraReactionsCount,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to return emoji based on reaction type
  String getReactionEmoji(String reactionType) {
    switch (reactionType) {
      case 'smile':
        return '😊';
      case 'like':
        return '👍';
      case 'heart':
        return '❤️';

      default:
        return '';
    }
  }
}
