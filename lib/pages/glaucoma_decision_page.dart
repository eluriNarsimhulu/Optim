//root/lib/pages/glaucoma_decision_page.dart
import 'package:flutter/material.dart';
import 'detection_page.dart';
import 'glaucoma_segmentation_page.dart';
import 'glaucoma_classification_page.dart';
import 'glaucoma_advance_classify.dart';

class GlaucomaDecisionPage extends StatelessWidget {
  const GlaucomaDecisionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEBF4FF),
              Colors.white,
              Color(0xFFF0FDF4),
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
                    const SizedBox(height: 20),
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildMainCard(context),
                    const SizedBox(height: 24),
                    _buildFeatureCards(context),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          left: 30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: 50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.green.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 350,
          right: 80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.teal.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            ),
            Text(
              'Back to Home',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
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
            Icons.visibility,
            size: 36,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Glaucoma Detection Suite',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Choose the type of analysis you want to perform',
            style: TextStyle(
              fontSize: 16,
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
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
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
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: Colors.blue[600],
          ),
          const SizedBox(height: 16),
          const Text(
            'Advanced Glaucoma Analysis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Our platform offers comprehensive glaucoma detection capabilities using state-of-the-art AI models. Each module is designed to provide specific insights into different aspects of glaucoma diagnosis and progression.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Select Analysis Type',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        _buildFeatureCard(
          context: context,
          icon: Icons.category,
          title: 'Glaucoma Classification',
          description:
              'Binary classification to determine presence or absence of glaucoma from fundus images',
          gradientColors: [
            const Color(0xFF3B82F6),
            const Color(0xFF2563EB),
          ],
          // isComingSoon: true,
          // onTap: () {
          //   _showComingSoonDialog(context, 'Glaucoma Classification');
          // },
          isComingSoon: false,
          badge: 'AVAILABLE NOW',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GlaucomaClassificationPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.healing,
          title: 'Glaucoma Segmentation',
          description:
              'Precise optic disc and optic cup segmentation for cup-to-disc ratio analysis',
          gradientColors: [
            const Color(0xFF10B981),
            const Color(0xFF059669),
          ],
          // isComingSoon: true,
          // onTap: () {
          //   _showComingSoonDialog(context, 'Glaucoma Segmentation');
          // },
          isComingSoon: false,
          badge: 'AVAILABLE NOW',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GlaucomaSegmentationPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          context: context,
          icon: Icons.auto_awesome,
          title: 'Advanced Classification',
          description:
              'Multi-class glaucoma detection with severity assessment and visual field progression prediction',
          gradientColors: [
            const Color(0xFF8B5CF6),
            const Color(0xFF7C3AED),
          ],
          isComingSoon: false,
          badge: 'AVAILABLE NOW',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GlaucomaAdvanceClassifyPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required bool isComingSoon,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComingSoon
              ? [Colors.grey[400]!, Colors.grey[500]!]
              : gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isComingSoon ? Colors.grey[400]! : gradientColors[0])
                .withOpacity(0.3),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const Spacer(),
                    if (isComingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          'COMING SOON',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    if (badge != null && !isComingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[400],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      isComingSoon ? 'Stay tuned' : 'Start analysis',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isComingSoon
                          ? Icons.access_time
                          : Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
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
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              const Text(
                'Pro Tip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'For best results, use high-quality fundus images with clear optic disc visibility. Early detection is key to preventing vision loss from glaucoma.',
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

  void _showComingSoonDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.construction, color: Colors.orange[600]),
              const SizedBox(width: 8),
              const Text('Coming Soon'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch,
                size: 64,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(height: 16),
              Text(
                '$featureName is under development.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re working hard to bring you this feature. Stay tuned for updates!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}