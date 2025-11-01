//root/lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _progressController;
  late AnimationController _textController;
  late AnimationController _particleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize all animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    // Define animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _particleController,
    );

    // Start animations
    _startAnimations();

    // Navigate after delay
    Timer(const Duration(milliseconds: 3500), _navigateToNextScreen);
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _rotateController.forward();
    _progressController.forward();
    _textController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (mounted) {
      // Use named routes for navigation
      if (user != null) {
        // User is logged in, go to landing page
        Navigator.pushReplacementNamed(context, '/landing');
      } else {
        // User is not logged in, go to auth page
        Navigator.pushReplacementNamed(context, '/auth');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            _buildAnimatedParticles(),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated eye icon
                  _buildAnimatedIcon(),
                  const SizedBox(height: 40),

                  // App title with fade and slide animation
                  _buildAnimatedTitle(),
                  const SizedBox(height: 16),

                  // Subtitle
                  _buildAnimatedSubtitle(),
                  const SizedBox(height: 60),

                  // Progress indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),

                  // Loading text
                  _buildLoadingText(),
                ],
              ),
            ),

            // Version info at bottom
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final offset = index * 0.1;
            final progress = (_particleAnimation.value + offset) % 1.0;
            final size = 4.0 + (index % 3) * 3.0;
            final left = (index * 37.0) % MediaQuery.of(context).size.width;
            final top = progress * MediaQuery.of(context).size.height;

            return Positioned(
              left: left,
              top: top,
              child: Opacity(
                opacity: 0.3 * (1 - progress),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildAnimatedIcon() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateAnimation.value * 0.5,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 70,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    Positioned(
                      top: 35,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue[300],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return FadeTransition(
      opacity: _textAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(_textController),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFE0E0E0)],
              ).createShader(bounds),
              child: const Text(
                'Optim',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return FadeTransition(
      opacity: _textAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.8),
          end: Offset.zero,
        ).animate(_textController),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Text(
            'AI-Powered Ophthalmology Platform',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFB3E5FC)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingText() {
    return FadeTransition(
      opacity: _textAnimation,
      child: Text(
        'Initializing AI Systems...',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Powered by Advanced Deep Learning',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}