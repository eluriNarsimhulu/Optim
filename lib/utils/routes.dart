import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/landing_page.dart';
import '../pages/detection_page.dart';
import '../auth_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const LandingPage();
          }
          return const AuthPage();
        },
      ),
  '/detection': (context) => DetectionPage(),
};