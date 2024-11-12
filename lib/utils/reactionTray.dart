import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glint/utils/colorPallet.dart';
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
  final String groupId; // Group ID (e.g., BVqfV9nb201nSecbqgsE)
  final String imageId; // Image ID (e.g., ja9gEkRa2GtFiqzhsaWD)

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
        if (_cachedReactions != reactions) {
          _cachedReactions = Map.from(reactions);
          _isLoading = false;
        }

        List<String> displayedReactions = _cachedReactions.values.toList();
        String extraReactionsCount = displayedReactions.length > 5
            ? "+${displayedReactions.length - 5} more"
            : '';

        return GestureDetector(
          onTap: () {
            _showReactionDetails(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: AppColors.lightGray.withOpacity(0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...displayedReactions.take(5).map((reactionType) {
                      return Text(
                        getReactionEmoji(reactionType),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      );
                    }).toList(),
                    if (extraReactionsCount.isNotEmpty)
                      Text(
                        extraReactionsCount,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
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

  void _showReactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.groupId)
              .collection('images')
              .doc(widget.imageId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No reactions available"));
            }

            var imageData = snapshot.data!.data() as Map<String, dynamic>;
            Map<String, dynamic> reactions = imageData['reactions'] ?? {};

            return SizedBox(
              height: 350,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reactions",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    reactions.isEmpty
                        ? const Center(child: Text("No reactions yet"))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: reactions.length,
                              itemBuilder: (context, index) {
                                var user = reactions.keys.elementAt(index);
                                var reaction = reactions[user];
                                return ListTile(
                                  leading:
                                      Text(getReactionEmoji(reaction ?? '')),
                                  title: Text(user),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
