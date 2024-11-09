import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemoriesPage extends StatefulWidget {
  final String userPhoneNumber;

  const MemoriesPage({super.key, required this.userPhoneNumber});
  @override
  _MemoriesPageState createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  Map<String, List<Map<String, dynamic>>> groupImages = {};
  bool sortByDate = false;

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  void loadImages() async {
    groupImages = await fetchImagesByGroup();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              setState(() {
                sortByDate = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () {
              setState(() {
                sortByDate = true;
              });
            },
          ),
        ],
      ),
      body: sortByDate ? buildDateSortedView() : buildGroupSortedView(),
    );
  }

  Widget buildGroupSortedView() {
    return ListView(
      children: groupImages.entries.map((entry) {
        String groupId = entry.key;

        List<Map<String, dynamic>> images = entry.value;

        return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId) // Reference the group document by its ID
                .get(), // Fetch the document
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Show loading indicator
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}')); // Handle error
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                    child: Text('Share Your Glints To Make Memories...'));
              }

              // Extract the group name from the document data
              String groupName = snapshot.data!['Groupname'] ?? 'No Name';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Group: $groupName',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemBuilder: (context, index) {
                      return Image.network(images[index]['url']);
                    },
                  ),
                ],
              );
            });
      }).toList(),
    );
  }

  Widget buildDateSortedView() {
    // Flatten the list and sort by timestamp
    List<Map<String, dynamic>> allImages = [];
    groupImages.forEach((_, images) => allImages.addAll(images));

    // Sort images by timestamp
    allImages.sort((a, b) =>
        (a['timestamp'] as Timestamp).compareTo(b['timestamp'] as Timestamp));

    // Group images by categories: Today, Yesterday, Last Week, Last Month
    Map<String, List<Map<String, dynamic>>> categorizedImages = {
      'Today': [],
      'Yesterday': [],
      'Last Week': [],
      'Last Month': [],
      'Earlier': [],
    };

    DateTime now = DateTime.now();

    // Categorize images
    for (var image in allImages) {
      DateTime imageDate = (image['timestamp'] as Timestamp).toDate();
      Duration difference = now.difference(imageDate);

      if (difference.inDays < 1) {
        categorizedImages['Today']?.add(image);
      } else if (difference.inDays == 1) {
        categorizedImages['Yesterday']?.add(image);
      } else if (difference.inDays <= 7) {
        categorizedImages['Last Week']?.add(image);
      } else if (difference.inDays <= 30) {
        categorizedImages['Last Month']?.add(image);
      } else {
        categorizedImages['Earlier']?.add(image);
      }
    }

    // Create a list to display the images grouped by categories
    List<Widget> imageWidgets = [];
    categorizedImages.forEach((category, images) {
      if (images.isNotEmpty) {
        // Add a category header
        imageWidgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              category, // Show the category name (e.g., Today, Yesterday)
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );

        // Display images under this category
        imageWidgets.add(
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 images per row
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemBuilder: (context, index) {
              return Image.network(images[index]['url']);
            },
          ),
        );
      }
    });

    return ListView(
      children: imageWidgets,
    );
  }

  Future<Map<String, List<Map<String, dynamic>>>> fetchImagesByGroup() async {
    Map<String, List<Map<String, dynamic>>> groupImages = {};

    // Fetch the groups the user is a part of
    QuerySnapshot groupSnapshot =
        await FirebaseFirestore.instance.collection('groups').get();

    List<QueryDocumentSnapshot> matchingGroups = [];
    for (var doc in groupSnapshot.docs) {
      List members = doc['members'];
      for (var member in members) {
        if (member['phone'] == widget.userPhoneNumber) {
          matchingGroups.add(doc);
          break;
        }
      }
    }

    // For each group, fetch the images collection
    for (var groupDoc in matchingGroups) {
      String groupId = groupDoc.id;

      // Fetch images in the group
      QuerySnapshot imagesSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('images')
          .orderBy('timestamp', descending: true) // Sort by timestamp
          .get();

      // Add images to the map
      groupImages[groupId] = imagesSnapshot.docs.map((doc) {
        return {
          'timestamp': doc['timestamp'],
          'uploadedBy': doc['uploadedBy'],
          'url': doc['url'],
        };
      }).toList();
    }

    return groupImages;
  }
}
