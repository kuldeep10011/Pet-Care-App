import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // White background for the entire body
          Container(
            color: Colors.white, // Set the background color to white
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  // Dr. Sanjib Borah Card
                  _buildProfileCard(
                    'Dr. Sanjib Borah',
                    'assets/images/sanjibbora.jpg', // Replace with actual image path
                    'Dr. Sanjib Borah is an esteemed academician and researcher, currently an Associate Professor in the Department of Veterinary Physiology and Biochemistry at Lakhimpur College of Veterinary Science, Assam Agricultural University. His research focuses on reproductive physiology and molecular biology in livestock, with notable work on growth, reproduction, stress and immune function. Proficient in Assisted Reproductive Techniques and molecular biology, he has secured substantial research funding from prestigious research funding agencies. These projects have not only advanced scientific knowledge but have also yielded practical implications for enhancing animal productivity and welfare. He was also a part of the research team to produce the world’s first Embryo Transfer Technology (ETT) born yak calf - MISMO in 2005. An accomplished educator since 2014, Dr. Borah has received multiple awards and authored numerous research papers, contributed to books, and participated in scientific committees, making significant contributions to veterinary science and animal welfare.',
                    Colors.green
                        .shade200, // Light green background color for the card
                  ),
                  const SizedBox(height: 20),
                  // Dr. Simson Soren Card
                  _buildProfileCard(
                    'Dr. Simson Soren',
                    'assets/images/simpson.jpg', // Replace with actual image path
                    'Dr. Simson Soren, Ph.D., is working as an Assistant Professor in the Department of Veterinary Physiology and Biochemistry at Lakhimpur College of Veterinary Science, Assam Agricultural University, since 2019. He was awarded a Ph.D. in Animal Physiology from ICAR-NDRI, Karnal in 2016. He has been certified by prestigious institutions in laboratory animal care. He was also part of the research team that produced the world’s first test tube Yak calf named “NORGYAL”. His research has been recognized on national and international platforms, and he has actively published scientific articles, book chapters, and popular articles.',
                    Colors.green
                        .shade200, // Slightly darker green background color for the card
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the profile cards
  Widget _buildProfileCard(
      String name, String imagePath, String description, Color cardColor) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: cardColor, // Use the matching color for the card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath, // Replace with actual image path
                height: 200, // Increased the height to 200 for better display
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 15),
            // Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
