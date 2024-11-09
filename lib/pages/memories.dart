import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        title: Padding(
          padding: const EdgeInsets.only(right: 50),
          child: const Center(child: Text('Memories')),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.w, vertical: 12.h),
                      elevation: 0,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() {
                      sortByDate = false;
                    });
                  },
                  child: const Text('By Group')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 50.w, vertical: 12.h),
                      elevation: 0,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() {
                      sortByDate = true;
                    });
                  },
                  child: const Text('By Date '))
            ],
          ),
          Expanded(
              child:
                  sortByDate ? buildDateSortedView() : buildGroupSortedView()),
        ],
      ),
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
                      crossAxisCount: 2,
                      crossAxisSpacing: 2.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index]['url'],
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(), // Placeholder while loading
                        errorWidget: (context, url, error) => const Icon(
                            Icons.error), // Error icon in case of failure
                      );
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index]['url'],
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
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
