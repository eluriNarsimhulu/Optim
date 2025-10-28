//root/lib/pages/landing_page.dart
import 'package:flutter/material.dart';
import 'detection_page.dart';
import 'glaucoma_decision_page.dart';
import 'vqa_page.dart';
import '../home_page.dart';

void main() {
  runApp(const GlaucomaApp());
}

class GlaucomaApp extends StatelessWidget {
  const GlaucomaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ophthalmology AI Platform',
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
            _buildBackgroundElements(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildMainCard(context),
                    const SizedBox(height: 24),
                    _buildFeatureButtons(context),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
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
          color: Color(0xFF2563EB),
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
            Icons.remove_red_eye,
            size: 32,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'AI-Powered Ophthalmology Platform',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Advancing eye care through intelligent image analysis and visual question answering',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF4B5563),
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
            'About Our Platform',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildContentText(),
          const SizedBox(height: 32),
          _buildFeatureCards(),
        ],
      ),
    );
  }

  Widget _buildContentText() {
    return const Column(
      children: [
        Text(
          'Welcome to our comprehensive AI-powered ophthalmology platform that combines cutting-edge technology with clinical expertise to revolutionize eye care diagnosis and monitoring.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF374151),
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 16),
        Text(
          'Our platform integrates two powerful AI-driven modules designed to assist healthcare professionals in accurate and efficient eye disease detection:',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF374151),
            height: 1.6,
            fontWeight: FontWeight.w500,
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
          icon: Icons.chat_bubble_outline,
          iconColor: const Color(0xFF9333EA),
          title: 'Visual Question Answering',
          description:
              'Interactive AI system that answers questions about ophthalmological images across multiple imaging modalities, providing instant insights and detailed analysis',
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.analytics_outlined,
          iconColor: const Color(0xFF2563EB),
          title: 'Glaucoma Detection & Classification',
          description:
              'Advanced deep learning models for precise optic disc segmentation, glaucoma classification, and visual field progression prediction from fundus images',
        ),
        const SizedBox(height: 24),
        const Text(
          'Both modules leverage state-of-the-art GenAI models to deliver accurate, reliable results that support clinical decision-making and enhance patient care outcomes.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF374151),
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
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
      padding: const EdgeInsets.all(20),
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
            size: 40,
            color: iconColor,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButtons(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Choose Your Feature',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildNavigationButton(
          context: context,
          icon: Icons.question_answer,
          title: 'VQA Ophthalmology',
          description: 'Ask questions about eye images',
          gradientColors: [
            const Color(0xFF9333EA),
            const Color(0xFF7C3AED),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VQAPage()),
            );
          },
          // onTap: () {
          //   // TODO: Navigate to VQA page
          //   // Navigator.push(
          //   //   context,
          //   //   MaterialPageRoute(builder: (context) => VQAPage()),
          //   // );
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('VQA feature coming soon!'),
          //       backgroundColor: Color(0xFF9333EA),
          //     ),
          //   );
          // },
        ),
        const SizedBox(height: 16),
        _buildNavigationButton(
          context: context,
          icon: Icons.visibility,
          title: 'Glaucoma Detection',
          description: 'Classify and segment fundus images',
          gradientColors: [
            const Color(0xFF2563EB),
            const Color(0xFF16A34A),
          ],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GlaucomaDecisionPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Color(0xFF4B5563),
              ),
              SizedBox(width: 8),
              Text(
                'Important Notice',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'This platform is designed for educational and research purposes. Results should not replace professional medical diagnosis. Always consult qualified healthcare professionals for medical advice and treatment decisions.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}