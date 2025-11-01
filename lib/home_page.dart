//root/lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_page.dart';
import 'services/google_auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleAuthService = GoogleAuthService();
  String userName = '';
  String userEmail = '';
  String joinDate = '';
  String? photoURL;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          userEmail = user.email ?? '';
          userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
          photoURL = user.photoURL;
        });

        try {
          final doc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 5));

          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            setState(() {
              userName = data['name'] ?? userName;
              if (data['createdAt'] != null) {
                final timestamp = data['createdAt'] as Timestamp;
                final date = timestamp.toDate();
                joinDate = "${date.day}/${date.month}/${date.year}";
              } else {
                joinDate = "Recently";
              }
            });
          } else {
            setState(() {
              joinDate = "Recently";
            });
          }
        } catch (e) {
          setState(() {
            joinDate = "Recently";
          });
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          userName = 'User';
          userEmail = '';
          joinDate = '';
          _isLoading = false;
        });
      }
    } catch (e) {
      final user = _auth.currentUser;
      setState(() {
        userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
        userEmail = user?.email ?? '';
        photoURL = user?.photoURL;
        joinDate = 'Recently';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[400]),
            const SizedBox(width: 8),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Sign out from both Firebase and Google
              await _googleAuthService.signOut();
              
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8EAF6),
                Colors.white,
                Color(0xFFFFF3E0),
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple[600]!),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8EAF6),
              Colors.white,
              Color(0xFFFFF3E0),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundElements(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildStatsCards(),
                    const SizedBox(height: 20),
                    _buildWelcomeCard(),
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
          top: 80,
          right: 40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.deepPurple.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.orange.withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.indigo.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
            ),
            Text(
              'Back',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
                backgroundColor: Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Icon(
            Icons.account_circle,
            size: 32,
            color: Colors.deepPurple[600],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'My Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your account information',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.deepPurple.withOpacity(0.3), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.withOpacity(0.1),
              Colors.white.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              // Profile Avatar - Show Google photo if available
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.2),
                      Colors.indigo.withOpacity(0.2),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: photoURL != null
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(photoURL!),
                        backgroundColor: Colors.transparent,
                      )
                    : Container(
                        padding: const EdgeInsets.all(20),
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.deepPurple[600],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        _buildDetailCard(
          icon: Icons.email,
          label: 'Email Address',
          value: userEmail,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          icon: Icons.calendar_today,
          label: 'Member Since',
          value: joinDate,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.5),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: Colors.white.withOpacity(0.5),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[800]),
                const SizedBox(width: 8),
                Text(
                  'Welcome to Optim!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your account has been successfully set up. Start exploring and optimizing your experience with our AI-powered ophthalmology platform!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: Explore different analysis types for comprehensive eye health insights',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}