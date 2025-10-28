//root/lib/utils/routes.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/landing_page.dart';
import '../pages/detection_page.dart';
import '../pages/vqa_page.dart';
import '../pages/glaucoma_decision_page.dart';
import '../pages/glaucoma_segmentation_page.dart';
import '../pages/glaucoma_segmentation_results_page.dart';  // Add this import
import '../pages/glaucoma_classification_page.dart';
import '../pages/glaucoma_classification_results_page.dart';
import '../pages/glaucoma_advance_classify.dart';
import '../pages/glaucoma_advance_results_page.dart';
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
  // '/detection': (context) => DetectionPage(),
  '/vqa': (context) => VQAPage(),
  '/glaucoma-decision': (context) => GlaucomaDecisionPage(),
  '/glaucoma-segmentation': (context) => GlaucomaSegmentationPage(),
  '/glaucoma-segmentation-results': (context) => GlaucomaSegmentationResultsPage(),  // Add this route
  '/glaucoma-classification': (context) => GlaucomaClassificationPage(),
  '/glaucoma-classification-results': (context) => GlaucomaClassificationResultsPage(),
  '/glaucoma-advance': (context) => GlaucomaAdvanceClassifyPage(),
  '/glaucoma-advance-results': (context) => GlaucomaAdvanceResultsPage(),
};