import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for logout
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'TopicSelectionPage.dart'; // Import the TopicSelectionPage
import 'login.dart'; // Import the LoginPage for navigation
import 'AboutUs.dart'; // Import the AboutUs page for navigation

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDogSelected = false;
  String selectedAnimalName = ''; // Variable to store selected animal name
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    // Simulating initial loading to handle fetching delays
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Simulate some delay to fetch data properly, you can also
    // check if all images/data are loaded, but this simulates the process.
    await Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false; // Data fetched successfully
      });
    });
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                // Sign out the user
                await FirebaseAuth.instance.signOut();
                // Navigate to the Login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
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
        automaticallyImplyLeading: false, // Remove the back arrow
        title: const Text('Home'),
        backgroundColor: Colors.green,
        actions: [
          // About Us Button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Navigate to About Us page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            },
          ),
          const SizedBox(width: 10),
          // Version Number
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '1.0.0', // Update text to only show version number
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmation();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/loading.gif', // Loading GIF
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20), // Add some spacing
                  const Text(
                    'Loading...', // Display Loading text
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Animal:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Fetch and display animals from Firestore
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Animal')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No Animal data available'));
                        }

                        return ListView(
                          children: snapshot.data!.docs.map((document) {
                            final imageUrl = document['Image'];
                            final name =
                                document.id; // Use the document ID as the name

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAnimalName =
                                      name; // Store selected animal name
                                  isDogSelected =
                                      true; // Mark animal as selected
                                });
                              },
                              child: Card(
                                color: Colors.lightBlue[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: selectedAnimalName == name
                                      ? const BorderSide(
                                          color: Colors.green, width: 3)
                                      : BorderSide
                                          .none, // Highlight when selected
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        imageUrl, // Use network image
                                        height: 100,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            name, // Document ID used as name
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  // More Animals Coming Soon - Centered
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                              size: 50,
                            ),
                            onPressed: () {
                              // Action for future animal addition
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'More Animals will be coming soon',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isDogSelected
                ? () {
                    // Navigate to the TopicSelectionPage with the selected animal name
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TopicSelectionPage(animalName: selectedAnimalName),
                      ),
                    );
                  }
                : null, // Disable button if no animal is selected
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(
                  vertical: 15, horizontal: 10), // Adjusted padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
