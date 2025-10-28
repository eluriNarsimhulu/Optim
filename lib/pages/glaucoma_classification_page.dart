//root/lib/pages/glaucoma_classification_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GlaucomaClassificationPage extends StatefulWidget {
  @override
  _GlaucomaClassificationPageState createState() =>
      _GlaucomaClassificationPageState();
}

class _GlaucomaClassificationPageState
    extends State<GlaucomaClassificationPage> with TickerProviderStateMixin {
  File? selectedImage;
  bool isAnalyzing = false;
  String? predictedClass;
  Map<String, double>? probabilities;
  String? imageBase64; // To store image for saving

  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

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

    _bounceController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        predictedClass = null;
        probabilities = null;
        imageBase64 = null;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        predictedClass = null;
        probabilities = null;
        imageBase64 = null;
      });
    }
  }

  Future<void> _classifyImage() async {
    if (selectedImage == null) {
      _showErrorDialog('Please upload a fundus image first');
      return;
    }

    setState(() {
      isAnalyzing = true;
      predictedClass = null;
      probabilities = null;
    });

    try {
      // Convert image to base64 for storage
      final bytes = await selectedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['PORT_IP']}/classify'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', selectedImage!.path),
      );

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var data = json.decode(respStr);

        setState(() {
          predictedClass = data['predicted_class'];
          probabilities = Map<String, double>.from(
              data['probabilities'].map((k, v) => MapEntry(k, v.toDouble())));
        });

        _fadeController.forward(from: 0.0);
        _bounceController.forward(from: 0.0);
      } else {
        _showErrorDialog('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog(
          'Connection error: $e\n\nMake sure the backend server is running.');
    }

    setState(() {
      isAnalyzing = false;
    });
  }

  void _showSaveDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.save, color: Colors.blue[700]),
              SizedBox(width: 8),
              Text('Save Result'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  hintText: 'e.g., Raj',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'Patient ID',
                  hintText: 'e.g., 112',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    idController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _saveResult(
                  nameController.text.trim(),
                  idController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
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

  Future<void> _saveResult(String patientName, String patientId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog('Please login to save results');
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving result...'),
                  ],
                ),
              ),
            ),
          );
        },
      );

      await FirebaseFirestore.instance
          .collection('glaucoma_classifications')
          .add({
        'userId': user.uid,
        'patientName': patientName,
        'patientId': patientId,
        'predictedClass': predictedClass,
        'probabilities': probabilities,
        'imageBase64': imageBase64,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Details saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('Failed to save result: $e');
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
      predictedClass = null;
      probabilities = null;
      imageBase64 = null;
    });
  }

  Color _getResultColor() {
    if (predictedClass == null) return Colors.grey;
    if (predictedClass!.toLowerCase().contains('glaucoma')) {
      return Colors.red;
    }
    return Colors.green;
  }

  IconData _getResultIcon() {
    if (predictedClass == null) return Icons.help_outline;
    if (predictedClass!.toLowerCase().contains('glaucoma')) {
      return Icons.warning_amber;
    }
    return Icons.check_circle;
  }

  String _getResultMessage() {
    if (predictedClass == null) return '';
    if (predictedClass!.toLowerCase().contains('glaucoma')) {
      return 'Glaucoma Detected';
    }
    return 'Healthy';
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
              Color(0xFFE3F2FD),
              Colors.white,
              Color(0xFFFCE4EC),
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
                    if (predictedClass != null) ...[
                      SizedBox(height: 16),
                      _buildResultCard(),
                      SizedBox(height: 16),
                      _buildProbabilityCard(),
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
                  Colors.blue.withOpacity(0.15),
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
                  Colors.pink.withOpacity(0.12),
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
                  Colors.cyan.withOpacity(0.08),
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
                Navigator.pushNamed(context, '/glaucoma-classification-results');
              },
              icon: Icon(Icons.history, size: 18),
              label: Text('Previous Results'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue[700],
                backgroundColor: Colors.white.withOpacity(0.7),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (selectedImage != null) ...[
              SizedBox(width: 8),
              TextButton.icon(
                onPressed: _clearAll,
                icon: Icon(Icons.refresh, size: 18),
                label: Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                ),
              ),
            ],
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
            Icons.category,
            size: 32,
            color: Colors.blue[600],
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Glaucoma Classification',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Binary classification: Glaucoma vs. Healthy',
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
                Icon(Icons.image, color: Colors.blue[700]),
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
              'Select a fundus image for glaucoma classification',
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
                    color: Colors.blue[200]!,
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
                              color: Colors.blue[100],
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 32,
                              color: Colors.blue[600],
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
                    icon: Icon(Icons.photo_library, color: Colors.blue[700]),
                    label: Text(
                      'Gallery',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      side: BorderSide(color: Colors.blue[200]!),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: Icon(Icons.camera_alt, color: Colors.blue[700]),
                    label: Text(
                      'Camera',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      side: BorderSide(color: Colors.blue[200]!),
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
                colors: [Colors.blue[600]!, Colors.cyan[600]!],
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
              onPressed: isAnalyzing ? null : _classifyImage,
              icon: isAnalyzing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.psychology, color: Colors.white),
              label: Text(
                isAnalyzing ? 'Classifying...' : 'Classify Image',
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
        onPressed: _showSaveDialog,
        icon: Icon(Icons.save, color: Colors.white),
        label: Text(
          'Save Result',
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

  Widget _buildResultCard() {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          color: Colors.white.withOpacity(0.7),
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _getResultColor().withOpacity(0.5), width: 3),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getResultColor().withOpacity(0.1),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(28),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getResultColor().withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: _getResultColor().withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getResultIcon(),
                      size: 64,
                      color: _getResultColor(),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Classification Result',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getResultMessage(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getResultColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getResultColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getResultColor().withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      predictedClass ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getResultColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProbabilityCard() {
    if (probabilities == null) return SizedBox.shrink();

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
                  Icon(Icons.bar_chart, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Text(
                    'Classification Confidence',
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
                'Probability distribution across classes',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              ...probabilities!.entries.map((entry) {
                return _buildProbabilityBar(entry.key, entry.value);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProbabilityBar(String label, double probability) {
    Color barColor = label.toLowerCase().contains('glaucoma') &&
            !label.toLowerCase().contains('non')
        ? Colors.red
        : Colors.green;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Text(
                '${(probability * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: probability,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        barColor,
                        barColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
            _buildInfoItem('Binary classification: Glaucoma vs. Healthy'),
            _buildInfoItem('AI model trained on fundus image datasets'),
            _buildInfoItem('Results for educational purposes only'),
            _buildInfoItem('Consult healthcare professionals for diagnosis'),
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