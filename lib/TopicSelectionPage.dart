import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'content_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TopicSelectionPage extends StatefulWidget {
  final String animalName;

  const TopicSelectionPage({super.key, required this.animalName});

  @override
  _TopicSelectionPageState createState() => _TopicSelectionPageState();
}

class _TopicSelectionPageState extends State<TopicSelectionPage> {
  final List<Color> cardColors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.yellow,
    Colors.indigo,
    Colors.cyan,
    Colors.deepPurple,
    Colors.amber,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.lime,
  ];

  String? selectedTopic;
  int selectedIndex = -1; // Keep track of the selected index
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<DocumentSnapshot> topics = [];
  bool isLoading = true; // Track loading state

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _scrollToSelected(int index) {
    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Show a confirmation dialog with Next and Undo buttons
  Future<void> _showTopicDialog(BuildContext context, String docID) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Selection'),
          content: const Text('Would you like to proceed with this topic?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Undo'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Next'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentPage(
                      selectedTopic: docID,
                      animalName: widget.animalName,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Topic'),
        backgroundColor: Colors.green,
        actions: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '1.0.0',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your Topic:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Animal')
                    .doc(widget.animalName)
                    .collection('Topic')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Still loading, show loading.gif
                    return Center(
                      child: Image.asset(
                        'assets/images/loading.gif', // Path to your loading.gif
                        height: 50, // Adjust size as needed
                        width: 50,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('An error occurred.'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No topics available.'));
                  }

                  topics = snapshot.data!.docs;
                  isLoading = false; // Mark loading complete

                  return ScrollablePositionedList.builder(
                    itemCount: topics.length,
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    itemBuilder: (context, index) {
                      var topicData = topics[index];
                      var title = topicData['Name'] as String? ?? 'No Title';
                      var imageUrl = topicData['Image'] as String? ?? '';

                      Color cardColor = cardColors[index % cardColors.length];
                      bool isSelected = selectedTopic == title;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTopic = title;
                            selectedIndex = index; // Update the selected index
                          });

                          // Calculate docID based on index
                          String docID =
                              String.fromCharCode(65 + index); // 'A' is 65

                          // Show the pop-up dialog
                          _showTopicDialog(context, docID);

                          // Scroll to the selected topic
                          _scrollToSelected(index);
                        },
                        child: _buildTopicCard(
                          context,
                          title,
                          imageUrl,
                          cardColor,
                          isSelected,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, String title, String imagePath,
      Color color, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.transparent,
            width: isSelected ? 4 : 0,
          ),
        ),
        elevation: 4,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Improved Image Handling
              imagePath.isNotEmpty &&
                      (imagePath.startsWith('http') ||
                          imagePath.startsWith('https'))
                  ? Image.network(
                      imagePath,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.error,
                          size: 80,
                          color: Colors.white),
                    )
                  : const Icon(Icons.image_not_supported,
                      size: 80, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
