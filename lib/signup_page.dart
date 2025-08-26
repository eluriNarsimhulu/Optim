// signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'dart:async';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _emailSent = false;
  bool _isVerifying = false;
  bool _emailVerified = false;
  bool _showPhoneVerification = false;
  bool _otpSent = false;
  bool _isVerifyingOTP = false;
  
  Timer? _verificationTimer;
  int _resendCooldown = 0;
  int _otpResendCooldown = 0;
  Timer? _resendTimer;
  Timer? _otpResendTimer;
  
  String? _verificationId;
  String? _tempPassword;
  UserCredential? _tempUserCredential;

  Future<void> _signup() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showSnackBar("Please fill in all fields", isError: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters long", isError: true);
      return;
    }

    // Validate phone number format
    String phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      _showSnackBar("Phone number must include country code (e.g., +91XXXXXXXXXX)", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user with email & password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store temporarily
      _tempUserCredential = userCredential;
      _tempPassword = _passwordController.text.trim();

      // Update display name immediately
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });

      _showSnackBar("Verification email sent! Please check your inbox.", isError: false);
      
      // Start checking for email verification
      _startEmailVerificationCheck();

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          message = "An account already exists with this email address.";
          break;
        case 'invalid-email':
          message = "Invalid email address format.";
          break;
        case 'operation-not-allowed':
          message = "Email/password accounts are not enabled.";
          break;
        default:
          message = "Registration failed: ${e.message}";
      }
      _showSnackBar(message, isError: true);
      setState(() => _isLoading = false);
    } catch (e) {
      _showSnackBar("An unexpected error occurred. Please try again.", isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _startEmailVerificationCheck() {
    setState(() => _isVerifying = true);
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkEmailVerification();
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      // Reload user to get latest verification status
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user?.emailVerified ?? false) {
        // Email is verified, proceed to phone verification
        _verificationTimer?.cancel();
        setState(() {
          _isVerifying = false;
          _emailVerified = true;
          _showPhoneVerification = true;
        });
        
        _showSnackBar("Email verified! Now verify your phone number.", isError: false);
      }
    } catch (e) {
      print("Error checking email verification: $e");
    }
  }

  Future<void> _sendOTP() async {
    String phoneNumber = _phoneController.text.trim();
    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _linkPhoneNumber(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          _showSnackBar("Phone verification failed: ${e.message}", isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
          });
          _showSnackBar("OTP sent to your phone!", isError: false);
          _startOTPResendCooldown();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Failed to send OTP. Please try again.", isError: true);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      _showSnackBar("Please enter a valid 6-digit OTP", isError: true);
      return;
    }

    setState(() => _isVerifyingOTP = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      await _linkPhoneNumber(credential);
    } on FirebaseAuthException catch (e) {
      setState(() => _isVerifyingOTP = false);
      String message;
      switch (e.code) {
        case 'invalid-verification-code':
          message = "Invalid OTP. Please check and try again.";
          break;
        case 'session-expired':
          message = "OTP has expired. Please request a new one.";
          break;
        default:
          message = "OTP verification failed: ${e.message}";
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      setState(() => _isVerifyingOTP = false);
      _showSnackBar("An error occurred. Please try again.", isError: true);
    }
  }

  Future<void> _linkPhoneNumber(PhoneAuthCredential credential) async {
    try {
      // Link phone number to the existing account
      await _auth.currentUser?.linkWithCredential(credential);

      // Both email and phone are verified, save to Firestore
      await _saveUserToFirestore();
      
      setState(() => _isVerifyingOTP = false);
      
      _showSnackBar("Phone verified successfully! Account created!", isError: false);
      
      // Navigate to home page
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isVerifyingOTP = false);
      if (e.code == 'credential-already-in-use') {
        _showSnackBar("This phone number is already in use by another account.", isError: true);
      } else {
        _showSnackBar("Failed to link phone number: ${e.message}", isError: true);
      }
    } catch (e) {
      setState(() => _isVerifyingOTP = false);
      _showSnackBar("An error occurred while linking phone number.", isError: true);
    }
  }

  Future<void> _saveUserToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).set({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "createdAt": FieldValue.serverTimestamp(),
          "uid": user.uid,
          "emailVerified": true,
          "phoneVerified": true,
        }).timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      print("Error saving to Firestore: $e");
      // Even if Firestore fails, we continue since both verifications are complete
    }
  }

  void _startOTPResendCooldown() {
    setState(() => _otpResendCooldown = 60);
    _otpResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _otpResendCooldown--);
      if (_otpResendCooldown <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    try {
      await _auth.currentUser?.sendEmailVerification();
      _showSnackBar("Verification email sent again!", isError: false);
      
      // Start cooldown
      setState(() => _resendCooldown = 60);
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _resendCooldown--);
        if (_resendCooldown <= 0) {
          timer.cancel();
        }
      });
    } catch (e) {
      _showSnackBar("Failed to resend email. Please try again.", isError: true);
    }
  }

  Future<void> _resendOTP() async {
    if (_otpResendCooldown > 0) return;
    
    setState(() {
      _otpSent = false;
      _otpController.clear();
    });
    await _sendOTP();
  }

  Future<void> _goBackAndDeleteAccount() async {
    try {
      // Delete the unverified account
      await _auth.currentUser?.delete();
    } catch (e) {
      print("Error deleting account: $e");
    } finally {
      _verificationTimer?.cancel();
      _resendTimer?.cancel();
      _otpResendTimer?.cancel();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _verificationTimer?.cancel();
    _resendTimer?.cancel();
    _otpResendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,           // ← Add this
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf093fb),
              Color(0xFF667eea),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: _emailSent ? _goBackAndDeleteAccount : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 40),
                
                if (!_emailSent && !_showPhoneVerification) ...[
                  // Signup Form
                  _buildSignupForm(),
                ] else if (_emailSent && !_emailVerified) ...[
                  // Email Verification Screen
                  _buildEmailVerificationScreen(),
                ] else if (_showPhoneVerification && !_otpSent) ...[
                  // Phone Number Input Screen
                  _buildPhoneInputScreen(),
                ] else if (_otpSent) ...[
                  // OTP Verification Screen
                  _buildOTPVerificationScreen(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create\nAccount",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Join us and start your optimization journey",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 60),
        
        // Glass container with form
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.white24, Colors.white10],
            ),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: Column(
            children: [
              // Name field
              _GlassTextField(
                controller: _nameController,
                hintText: "Full Name",
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              
              // Email field
              _GlassTextField(
                controller: _emailController,
                hintText: "Email Address",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              
              // Phone field
              _GlassTextField(
                controller: _phoneController,
                hintText: "Phone Number (+91XXXXXXXXXX)",
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              
              // Password field
              _GlassTextField(
                controller: _passwordController,
                hintText: "Password (min 6 characters)",
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white60,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 30),
              
              // Signup button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFf093fb),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFf093fb)),
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailVerificationScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify\nYour Email",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Step 1 of 2 - We've sent a verification link to\n${_emailController.text}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 60),
        
        // Verification status container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.white24, Colors.white10],
            ),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: Column(
            children: [
              // Email icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [Colors.white30, Colors.white30],
                  ),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              if (_isVerifying) ...[
                const Text(
                  "Checking verification status...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 24),
              ],
              
              const Text(
                "Please check your email and click the verification link.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              // Resend button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _resendCooldown > 0 ? null : _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white60, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _resendCooldown > 0 
                        ? "Resend in ${_resendCooldown}s" 
                        : "Resend Verification Email",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Manual check button
              TextButton(
                onPressed: _checkEmailVerification,
                child: const Text(
                  "I've verified, check now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify Phone\nNumber",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Step 2 of 2 - We'll send an OTP to verify your phone number",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 60),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.white24, Colors.white10],
            ),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: Column(
            children: [
              // Phone icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [Colors.white30, Colors.white30],
                  ),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Icon(
                  Icons.phone_android_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // Phone number display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.white60),
                    const SizedBox(width: 16),
                    Text(
                      _phoneController.text,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Send OTP button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFf093fb),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFf093fb)),
                          ),
                        )
                      : const Text(
                          "Send OTP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPVerificationScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter OTP",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "We've sent a 6-digit code to\n${_phoneController.text}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 60),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.white24, Colors.white10],
            ),
            border: Border.all(color: Colors.white30, width: 1),
          ),
          child: Column(
            children: [
              // OTP icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [Colors.white30, Colors.white30],
                  ),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              
              // OTP input
              _GlassTextField(
                controller: _otpController,
                hintText: "Enter 6-digit OTP",
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              
              // Verify OTP button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifyingOTP ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFf093fb),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifyingOTP
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFf093fb)),
                          ),
                        )
                      : const Text(
                          "Verify OTP",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Resend OTP button
              TextButton(
                onPressed: _otpResendCooldown > 0 ? null : _resendOTP,
                child: Text(
                  _otpResendCooldown > 0 
                      ? "Resend OTP in ${_otpResendCooldown}s" 
                      : "Resend OTP",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _GlassTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(prefixIcon, color: Colors.white60),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}