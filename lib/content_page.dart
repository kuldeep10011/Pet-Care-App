import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentPage extends StatefulWidget {
  final String selectedTopic; // A to P based on user selection
  final String animalName; // Animal name to fetch the topic name

  const ContentPage(
      {super.key, required this.selectedTopic, required this.animalName});

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  List<String> explanation = []; // Updated to handle an array of explanations
  String title = '';
  String imageUrl = '';
  String topicName = ''; // Variable to store topic name
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExplanation();
    _fetchTopicName(); // Fetch the topic name for the AppBar
  }

  // Function to parse explanation data from Firestore
  void parseExplanationData(dynamic docData) {
    if (docData.containsKey('Explain')) {
      var explainData = docData['Explain'];

      // Check if it's a list or a single string and handle accordingly
      if (explainData is List) {
        explanation = List<String>.from(explainData);
      } else if (explainData is String) {
        explanation = [explainData]; // Convert a single string into a list
      } else {
        explanation = ['Explain field has an unexpected format'];
      }
    } else {
      explanation = ['No explanation found'];
    }
  }

  // Function to fetch explanation based on selected topic (A to P)
  Future<void> _fetchExplanation() async {
    try {
      print("Fetching explanation for topic: ${widget.selectedTopic}");

      // Fetch the document for the selected topic from the Explanation collection
      final explanationSnapshot = await FirebaseFirestore.instance
          .collection('Explanation')
          .doc(widget.selectedTopic) // A to P document ID
          .get();

      // Check if the document exists
      if (explanationSnapshot.exists) {
        print("Document exists for topic: ${widget.selectedTopic}");
        var docData = explanationSnapshot.data();

        // Print the fetched document data for debugging
        print("Fetched Explanation Data: $docData");

        if (docData != null) {
          setState(() {
            parseExplanationData(docData); // Use method to handle parsing
            title = docData['Title'] ?? 'No title available';
            imageUrl = docData['Image'] ?? '';

            // Print fetched image URL and explanation for debugging
            print("Fetched Image URL: $imageUrl");
            print("Fetched Explanations: ${explanation.join(', ')}");

            // If image URL is empty or invalid, use a default image
            if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
              imageUrl =
                  'https://example.com/default-image.png'; // Default image
            }

            isLoading = false;
          });
        } else {
          print("Document data is null for topic: ${widget.selectedTopic}");
          setState(() {
            explanation = ['No explanation found'];
            isLoading = false;
          });
        }
      } else {
        print("No document found for topic: ${widget.selectedTopic}");
        setState(() {
          explanation = ['No explanation found'];
          isLoading = false;
        });
      }
    } catch (error) {
      print(
          "Error fetching explanation for topic: ${widget.selectedTopic}, Error: $error");
      setState(() {
        explanation = ['Error fetching explanation'];
        isLoading = false;
      });
    }
  }

  // Function to fetch topic name from the 'Topic' collection
  Future<void> _fetchTopicName() async {
    try {
      print(
          "Fetching topic name for animal: ${widget.animalName}, topic: ${widget.selectedTopic}");
      final topicSnapshot = await FirebaseFirestore.instance
          .collection('Animal')
          .doc(widget.animalName)
          .collection('Topic')
          .doc(widget.selectedTopic)
          .get();

      if (topicSnapshot.exists) {
        var docData = topicSnapshot.data();
        if (docData != null) {
          setState(() {
            topicName = docData['Name'] ?? 'No topic name available';
          });
        }
      }
    } catch (error) {
      print("Error fetching topic name: $error");
      setState(() {
        topicName = 'Error fetching topic name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topicName.isNotEmpty ? topicName : 'Topic Details'),
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
              // Handle logout action
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display the loading GIF
                  Image.asset(
                    'assets/images/loading.gif',
                    width: 100, // Adjust size as needed
                    height: 100, // Adjust size as needed
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220, // Adjust the height as needed
                            color: Colors.black
                                .withOpacity(0.3), // Slight blur effect
                            colorBlendMode: BlendMode.darken,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Image could not be loaded');
                            },
                          ),
                        ),
                        Positioned(
                          bottom:
                              20, // Adjust the position of the title on the image
                          left: 20,
                          right: 20,
                          child: Text(
                            title.isNotEmpty ? title : 'No title available',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.8),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Divider(
                      color: Colors
                          .grey[400], // Subtle line between title and content
                    ),
                    const SizedBox(height: 10),

                    // Loop through the explanation array and display each as a paragraph
                    explanation.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: explanation
                                .map((paragraph) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: Text(
                                        paragraph,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          height:
                                              1.5, // Line height for readability
                                        ),
                                      ),
                                    ))
                                .toList(),
                          )
                        : const Text(
                            'No explanation available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
