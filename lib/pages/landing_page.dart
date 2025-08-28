import 'package:flutter/material.dart';
import 'detection_page.dart';
import '../home_page.dart';

void main() {
  runApp(const GlaucomaApp());
}

class GlaucomaApp extends StatelessWidget {
  const GlaucomaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glaucoma Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F8FF), // Light blue
              Color(0xFFFFFFFF), // White
              Color(0xFFF0FFF0), // Light green
            ],
          ),
        ),
        child: Stack(
          children: [
            // Glassmorphism Background Elements
            _buildBackgroundElements(),
            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60), // Added more space for account button
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildMainCard(context),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
            // Account Button - Positioned at top right
            Positioned(
              top: 50, // Adjusted for SafeArea
              right: 16,
              child: _buildAccountButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.account_circle,
          size: 28,
          color: Color(0xFF2563EB), // Blue-600
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        Positioned(
          top: 80,
          left: 40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          right: 40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.05),
                  blurRadius: 60,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: 100,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.03),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.visibility,
            size: 32,
            color: Color(0xFF2563EB), // Blue-600
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Glaucoma Detection App',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937), // Gray-800
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'AI-powered glaucoma detection and monitoring using advanced fundus image analysis',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4B5563), // Gray-600
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'About Glaucoma Detection',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937), // Gray-800
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildContentText(),
          const SizedBox(height: 32),
          _buildFeatureCards(),
          const SizedBox(height: 24),
          _buildFinalText(),
          const SizedBox(height: 32),
          _buildCTAButton(context),
        ],
      ),
    );
  }

  Widget _buildContentText() {
    return const Column(
      children: [
        Text(
          'Glaucoma is a chronic, progressive eye disease that leads to optic nerve damage, usually associated with increased intraocular pressure (IOP). It is one of the leading causes of irreversible blindness globally.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF374151), // Gray-700
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 16),
        Text(
          'Optic disc (OD) segmentation and visual field (VF) progression prediction using fundus images is a critical task in glaucoma detection and monitoring. This application integrates GenAI models for these two tasks along with a VQA model for different imaging modalities of the optic nerve.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF374151), // Gray-700
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.flash_on,
          iconColor: const Color(0xFF2563EB), // Blue-600
          title: 'AI-Powered',
          description: 'Advanced GenAI models for accurate detection',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.visibility,
          iconColor: const Color(0xFF16A34A), // Green-600
          title: 'Optic Disc Analysis',
          description: 'Precise segmentation and monitoring',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.camera_alt,
          iconColor: const Color(0xFF9333EA), // Purple-600
          title: 'Fundus Imaging',
          description: 'Multiple imaging modality support',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937), // Gray-800
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563), // Gray-600
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalText() {
    return const Text(
      'Early detection and continuous monitoring are crucial for preventing vision loss. Our AI-powered approach provides healthcare professionals with advanced tools for accurate glaucoma assessment and patient care.',
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF374151), // Gray-700
        height: 1.6,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB), // Blue-600
            Color(0xFF16A34A), // Green-600
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetectionPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Go to Glaucoma Detection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'This application is designed for educational and research purposes. Always consult with healthcare professionals for medical advice.',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF4B5563), // Gray-600
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}