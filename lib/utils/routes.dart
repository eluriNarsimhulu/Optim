//root/lib/utils/routes.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/landing_page.dart';
import '../pages/detection_page.dart';
import '../pages/vqa_page.dart';
import '../pages/glaucoma_decision_page.dart';
import '../pages/glaucoma_segmentation_page.dart';
import '../pages/glaucoma_segmentation_results_page.dart';
import '../pages/glaucoma_classification_page.dart';
import '../pages/glaucoma_classification_results_page.dart';
import '../pages/glaucoma_advance_classify.dart';
import '../pages/glaucoma_advance_results_page.dart';
import '../auth_page.dart';
import '../pages/splash_screen.dart';
import '../pages/ehr_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  // Splash screen as initial route - it will handle navigation
  '/': (context) => const SplashScreen(),
  
  // Auth route - for when splash screen navigates based on auth status
  '/auth': (context) => const AuthPage(),
  
  // Landing page - main app screen after authentication
  '/landing': (context) => const LandingPage(),
  
  // VQA - Visual Question Answering
  '/vqa': (context) => VQAPage(),
  
  // Glaucoma Decision Page - Choose between classification, segmentation, or advanced
  '/glaucoma-decision': (context) => GlaucomaDecisionPage(),
  
  // Glaucoma Segmentation - Optic disc & cup segmentation
  '/glaucoma-segmentation': (context) => GlaucomaSegmentationPage(),
  '/glaucoma-segmentation-results': (context) => GlaucomaSegmentationResultsPage(),
  
  // Glaucoma Classification - Binary classification (Glaucoma vs Healthy)
  '/glaucoma-classification': (context) => GlaucomaClassificationPage(),
  '/glaucoma-classification-results': (context) => GlaucomaClassificationResultsPage(),
  
  // Glaucoma Advanced Classification - Multi-class (Normal, Early, Advanced)
  '/glaucoma-advance': (context) => GlaucomaAdvanceClassifyPage(),
  '/glaucoma-advance-results': (context) => GlaucomaAdvanceResultsPage(),
  
  // EHR - Electronic Health Records
  '/ehr': (context) => EHRPage(),
  
  // Detection Page (commented out - uncomment if needed)
  // '/detection': (context) => DetectionPage(),
};