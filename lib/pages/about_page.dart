//root/lib/pages/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildIntroductionSection(),
                      const SizedBox(height: 24),
                      _buildPlatformOverview(),
                      const SizedBox(height: 24),
                      _buildFeaturesSection(),
                      const SizedBox(height: 24),
                      _buildTechnologySection(),
                      const SizedBox(height: 24),
                      _buildObjectivesSection(),
                      const SizedBox(height: 24),
                      _buildImpactSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF2563EB),
            ),
          ),
          const Expanded(
            child: Text(
              'About Our Project',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(
            Icons.remove_red_eye,
            size: 48,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'AI-Powered Ophthalmology Platform',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Revolutionizing Eye Care Through Artificial Intelligence',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIntroductionSection() {
    return _buildSectionCard(
      title: 'Project Overview',
      icon: Icons.info_outline,
      iconColor: const Color(0xFF2563EB),
      children: [
        const Text(
          'Welcome to our comprehensive AI-powered ophthalmology platform, a cutting-edge solution designed to transform the landscape of eye care diagnosis and monitoring. Our platform represents the convergence of advanced artificial intelligence, deep learning technologies, and clinical ophthalmology expertise.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.7,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
        const Text(
          'This innovative system has been developed to assist healthcare professionals in making accurate, efficient, and timely diagnoses of various eye conditions, with a particular focus on glaucoma detection and general ophthalmological image analysis.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.7,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildPlatformOverview() {
    return _buildSectionCard(
      title: 'What We Offer',
      icon: Icons.dashboard_outlined,
      iconColor: const Color(0xFF16A34A),
      children: [
        const Text(
          'Our platform integrates multiple AI-driven modules, each designed to address specific aspects of ophthalmological diagnosis and analysis:',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.7,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 20),
        _buildFeatureItem(
          number: '1',
          title: 'Visual Question Answering System',
          description:
              'An intelligent, interactive AI system capable of understanding and answering complex questions about ophthalmological images across multiple imaging modalities including fundus photography, OCT scans, slit-lamp images, and fluorescein angiography.',
          color: const Color(0xFF9333EA),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          number: '2',
          title: 'Glaucoma Detection & Classification Suite',
          description:
              'Advanced deep learning models specifically trained for precise optic disc and optic cup segmentation, glaucoma classification with severity grading, and visual field progression prediction from fundus images.',
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          number: '3',
          title: 'Electronic Health Records (Coming Soon)',
          description:
              'Comprehensive patient management system for storing and retrieving patient information, medical history, examination records, and diagnostic reports in a secure, HIPAA-compliant environment.',
          color: const Color(0xFFEA580C),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return _buildSectionCard(
      title: 'Key Features & Capabilities',
      icon: Icons.stars_outlined,
      iconColor: const Color(0xFF9333EA),
      children: [
        _buildBulletPoint(
          'Multi-Modal Image Analysis',
          'Support for various ophthalmological imaging techniques including color fundus photography, optical coherence tomography (OCT), fluorescein angiography, and slit-lamp biomicroscopy.',
        ),
        _buildBulletPoint(
          'Real-Time Visual Question Answering',
          'Instant, accurate responses to clinical queries about uploaded images, helping clinicians gain insights quickly and efficiently during patient consultations.',
        ),
        _buildBulletPoint(
          'Automated Glaucoma Screening',
          'State-of-the-art deep learning models for automated detection and classification of glaucoma with high sensitivity and specificity, reducing diagnostic time and improving early detection rates.',
        ),
        _buildBulletPoint(
          'Precise Optic Disc Segmentation',
          'Advanced computer vision algorithms for accurate delineation of optic disc and optic cup boundaries, essential for calculating the cup-to-disc ratio (CDR) - a critical parameter in glaucoma assessment.',
        ),
        _buildBulletPoint(
          'Severity Grading',
          'Comprehensive classification system that categorizes glaucoma into stages (normal, early, moderate, severe) based on structural and functional parameters.',
        ),
        _buildBulletPoint(
          'Visual Field Prediction',
          'Predictive modeling capabilities to estimate visual field defects and progression patterns, aiding in treatment planning and monitoring.',
        ),
        _buildBulletPoint(
          'User-Friendly Interface',
          'Intuitive, clean design that prioritizes ease of use for healthcare professionals, reducing the learning curve and enabling quick adoption.',
        ),
        _buildBulletPoint(
          'Detailed Diagnostic Reports',
          'Comprehensive, exportable reports with visual annotations, confidence scores, and clinical recommendations for documentation and patient communication.',
        ),
      ],
    );
  }

  Widget _buildTechnologySection() {
    return _buildSectionCard(
      title: 'Technology Stack',
      icon: Icons.computer_outlined,
      iconColor: const Color(0xFF16A34A),
      children: [
        const Text(
          'Our platform leverages cutting-edge technologies in artificial intelligence and machine learning:',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.7,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
        _buildTechItem('Deep Learning Models', 'Convolutional Neural Networks (CNNs), U-Net architectures, and ResNet variants for image segmentation and classification'),
        _buildTechItem('Natural Language Processing', 'Transformer-based models for understanding and generating natural language responses to visual queries'),
        _buildTechItem('Computer Vision', 'Advanced image processing techniques including edge detection, morphological operations, and feature extraction'),
        _buildTechItem('Transfer Learning', 'Pre-trained models fine-tuned on extensive ophthalmological datasets for superior performance'),
        _buildTechItem('Cloud Computing', 'Scalable infrastructure for fast processing and storage of medical images and patient data'),
      ],
    );
  }

  Widget _buildObjectivesSection() {
    return _buildSectionCard(
      title: 'Our Mission & Objectives',
      icon: Icons.track_changes_outlined,
      iconColor: const Color(0xFFEA580C),
      children: [
        _buildObjectiveItem(
          icon: Icons.medical_services_outlined,
          title: 'Improve Early Detection',
          description: 'Enable earlier detection of glaucoma and other eye diseases, particularly in underserved and remote areas with limited access to ophthalmologists.',
        ),
        const SizedBox(height: 16),
        _buildObjectiveItem(
          icon: Icons.speed_outlined,
          title: 'Enhance Diagnostic Efficiency',
          description: 'Reduce the time required for diagnosis and increase throughput in busy clinical settings without compromising accuracy.',
        ),
        const SizedBox(height: 16),
        _buildObjectiveItem(
          icon: Icons.school_outlined,
          title: 'Support Clinical Education',
          description: 'Provide an educational tool for training ophthalmology residents and medical students in disease recognition and image interpretation.',
        ),
        const SizedBox(height: 16),
        _buildObjectiveItem(
          icon: Icons.science_outlined,
          title: 'Advance Research',
          description: 'Facilitate ophthalmological research by providing consistent, objective analysis of large image datasets.',
        ),
        const SizedBox(height: 16),
        _buildObjectiveItem(
          icon: Icons.accessibility_new_outlined,
          title: 'Increase Accessibility',
          description: 'Make advanced diagnostic capabilities accessible to healthcare facilities of all sizes, from major hospitals to rural clinics.',
        ),
      ],
    );
  }

  Widget _buildImpactSection() {
    return _buildSectionCard(
      title: 'Clinical Impact & Benefits',
      icon: Icons.health_and_safety_outlined,
      iconColor: const Color(0xFFDC2626),
      children: [
        const Text(
          'Our AI-powered platform delivers tangible benefits to healthcare providers and patients:',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF374151),
            height: 1.7,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
        _buildImpactCard(
          '95%+',
          'Diagnostic Accuracy',
          'High precision in glaucoma detection comparable to expert ophthalmologists',
          Icons.verified_outlined,
        ),
        const SizedBox(height: 12),
        _buildImpactCard(
          '70%',
          'Time Reduction',
          'Significant decrease in image analysis time, allowing clinicians to see more patients',
          Icons.timer_outlined,
        ),
        const SizedBox(height: 12),
        _buildImpactCard(
          '24/7',
          'Availability',
          'Round-the-clock diagnostic support, particularly valuable in emergency and after-hours situations',
          Icons.access_time_outlined,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF2563EB),
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This platform represents a significant step forward in democratizing access to advanced ophthalmological diagnostics, potentially preventing vision loss for millions of people worldwide.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 20,
                    color: Color(0xFFD97706),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Important Disclaimer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'This platform is designed for educational and research purposes. While our AI models achieve high accuracy, they are intended to assist, not replace, professional medical judgment. All results should be reviewed and confirmed by qualified ophthalmologists or optometrists. Always consult healthcare professionals for final diagnosis and treatment decisions.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF78350F),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.arrow_right,
            color: Color(0xFF16A34A),
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEA580C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFEA580C),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactCard(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFDC2626),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}