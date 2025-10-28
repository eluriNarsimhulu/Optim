//root/lib/pages/glaucoma_segmentation_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlaucomaSegmentationPage extends StatefulWidget {
  @override
  _GlaucomaSegmentationPageState createState() =>
      _GlaucomaSegmentationPageState();
}

class _GlaucomaSegmentationPageState extends State<GlaucomaSegmentationPage>
    with TickerProviderStateMixin {
  File? selectedImage;
  bool isAnalyzing = false;
  Uint8List? segmentedImageBytes;
  double? cdrValue;
  String? diagnosis;
  String? originalImageBase64;

  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    _patientNameController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        segmentedImageBytes = null;
        cdrValue = null;
        diagnosis = null;
        originalImageBase64 = null;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        segmentedImageBytes = null;
        cdrValue = null;
        diagnosis = null;
        originalImageBase64 = null;
      });
    }
  }

  Future<void> _analyzeSegmentation() async {
    if (selectedImage == null) {
      _showErrorDialog('Please upload a fundus image first');
      return;
    }

    setState(() {
      isAnalyzing = true;
      segmentedImageBytes = null;
      cdrValue = null;
      diagnosis = null;
    });

    _progressController.forward(from: 0.0);

    try {
      // Convert original image to base64 for storage
      List<int> imageBytes = await selectedImage!.readAsBytes();
      originalImageBase64 = base64Encode(imageBytes);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['PORT_IP']}/segment'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', selectedImage!.path),
      );

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var data = json.decode(respStr);

        String base64Image = data['segmentation_overlay'];
        Uint8List imageBytes = base64Decode(base64Image);

        setState(() {
          segmentedImageBytes = imageBytes;
          cdrValue = data['cdr'].toDouble();
          diagnosis = data['diagnosis'];
        });

        _fadeController.forward(from: 0.0);
      } else {
        _showErrorDialog('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e\n\nMake sure the backend server is running.');
    }

    setState(() {
      isAnalyzing = false;
    });
  }

  void _showSaveDialog() {
    _patientNameController.clear();
    _patientIdController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.save, color: Colors.green[600]),
              SizedBox(width: 8),
              Text('Save Results'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _patientNameController,
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _patientIdController,
                decoration: InputDecoration(
                  labelText: 'Patient ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveResults();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveResults() async {
    if (_patientNameController.text.isEmpty || _patientIdController.text.isEmpty) {
      _showErrorDialog('Please enter both patient name and ID');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('User not authenticated');
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('glaucoma_segmentation_results')
          .add({
        'patientName': _patientNameController.text,
        'patientId': _patientIdController.text,
        'originalImage': originalImageBase64,
        'segmentedImage': base64Encode(segmentedImageBytes!),
        'cdrValue': cdrValue,
        'diagnosis': diagnosis,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Details saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('Error saving results: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[400]),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearAll() {
    setState(() {
      selectedImage = null;
      segmentedImageBytes = null;
      cdrValue = null;
      diagnosis = null;
      originalImageBase64 = null;
    });
  }

  Color _getDiagnosisColor() {
    if (diagnosis == null) return Colors.grey;
    if (diagnosis!.toLowerCase().contains('glaucomatous')) {
      return Colors.red;
    }
    return Colors.green;
  }

  IconData _getDiagnosisIcon() {
    if (diagnosis == null) return Icons.help_outline;
    if (diagnosis!.toLowerCase().contains('glaucomatous')) {
      return Icons.warning;
    }
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9),
              Colors.white,
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundElements(),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildImageUploadCard(),
                    SizedBox(height: 16),
                    if (selectedImage != null) _buildAnalyzeButton(),
                    if (segmentedImageBytes != null) ...[
                      SizedBox(height: 16),
                      _buildResultsCard(),
                      SizedBox(height: 16),
                      _buildSegmentedImageCard(),
                      SizedBox(height: 16),
                      _buildCDRInfoCard(),
                      SizedBox(height: 16),
                      _buildSaveButton(),
                    ],
                    SizedBox(height: 16),
                    _buildInfoCard(),
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
                  Colors.green.withOpacity(0.15),
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
                  Colors.blue.withOpacity(0.12),
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
            Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/glaucoma-segmentation-results');
              },
              icon: Icon(Icons.history, size: 18),
              label: Text('Previous Results'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700],
              ),
            ),
            if (selectedImage != null)
              TextButton.icon(
                onPressed: _clearAll,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green[700],
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Icon(
            Icons.healing,
            size: 32,
            color: Colors.green[600],
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Glaucoma Segmentation',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Optic disc & cup segmentation with CDR analysis',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildImageUploadCard() {
    return Card(
      color: Colors.white.withOpacity(0.5),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.4)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image, color: Colors.green[700]),
                SizedBox(width: 8),
                Text(
                  'Upload Fundus Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Select a fundus image for optic disc segmentation',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.3),
                ),
                child: selectedImage != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tap to change image',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green[100],
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: Colors.green[600],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tap to upload fundus image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Supports JPG, PNG formats',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: Icon(Icons.photo_library, color: Colors.green[700]),
                    label: Text(
                      'Gallery',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      side: BorderSide(color: Colors.green[200]!),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: Icon(Icons.camera_alt, color: Colors.green[700]),
                    label: Text(
                      'Camera',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      side: BorderSide(color: Colors.green[200]!),
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

  Widget _buildAnalyzeButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isAnalyzing ? 1.0 : _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.teal[600]!],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isAnalyzing ? null : _analyzeSegmentation,
              icon: isAnalyzing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.analytics, color: Colors.white),
              label: Text(
                isAnalyzing ? 'Analyzing Segmentation...' : 'Segment & Analyze',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _showSaveDialog,
        icon: Icon(Icons.save, color: Colors.white),
        label: Text(
          'Save Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        color: Colors.white.withOpacity(0.6),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _getDiagnosisColor().withOpacity(0.3), width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getDiagnosisColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getDiagnosisIcon(),
                      color: _getDiagnosisColor(),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          diagnosis ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _getDiagnosisColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getDiagnosisColor().withOpacity(0.1),
                      _getDiagnosisColor().withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDiagnosisColor().withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Cup-to-Disc Ratio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          cdrValue?.toStringAsFixed(2) ?? '0.00',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getDiagnosisColor(),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDiagnosisColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cdrValue != null && cdrValue! >= 0.6
                                ? 'High Risk'
                                : 'Normal Range',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getDiagnosisColor(),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSegmentedImageCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        color: Colors.white.withOpacity(0.5),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.layers, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Text(
                    'Segmentation Overlay',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Optic disc (red) and optic cup (green) boundaries',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  segmentedImageBytes!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(Colors.red, 'Optic Disc'),
                  _buildLegendItem(Colors.green, 'Optic Cup'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCDRInfoCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        color: Colors.white.withOpacity(0.5),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.4)),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Text(
                    'Understanding CDR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildCDRInfoItem(
                'Normal CDR',
                'Typically ranges from 0.3 to 0.5',
                Colors.green,
              ),
              SizedBox(height: 12),
              _buildCDRInfoItem(
                'Borderline CDR',
                'Between 0.5 and 0.6 requires monitoring',
                Colors.orange,
              ),
              SizedBox(height: 12),
              _buildCDRInfoItem(
                'High Risk CDR',
                'Above 0.6 indicates potential glaucoma',
                Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCDRInfoItem(String title, String description, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.white.withOpacity(0.5),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.4)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[800]),
                SizedBox(width: 8),
                Text(
                  'Important Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoItem(
                'AI-powered segmentation for educational purposes'),
            _buildInfoItem('CDR is a key indicator for glaucoma assessment'),
            _buildInfoItem('Results should not replace professional diagnosis'),
            _buildInfoItem('Upload high-quality fundus images for accuracy'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
    }