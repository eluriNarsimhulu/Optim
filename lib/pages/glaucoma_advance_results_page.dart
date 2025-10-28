//root/lib/pages/glaucoma_advance_results_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

class GlaucomaAdvanceResultsPage extends StatefulWidget {
  @override
  _GlaucomaAdvanceResultsPageState createState() =>
      _GlaucomaAdvanceResultsPageState();
}

class _GlaucomaAdvanceResultsPageState
    extends State<GlaucomaAdvanceResultsPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('glaucoma_advanced_results')
                      .where('userId', isEqualTo: user?.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple[600],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error loading results',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No saved results',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Results you save will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;
                        return _buildResultCard(doc.id, data);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
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
              Icons.history,
              size: 32,
              color: Colors.deepPurple[600],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Previous Results',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'View and manage your saved analyses',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String docId, Map<String, dynamic> data) {
    String predictedClass = data['predictedClass'] ?? '';
    double confidence = (data['confidence'] ?? 0).toDouble();
    String patientName = data['patientName'] ?? 'Unknown';
    String patientId = data['patientId'] ?? 'N/A';
    String imageBase64 = data['imageBase64'] ?? '';
    Timestamp? timestamp = data['timestamp'];

    Color resultColor = _getResultColor(predictedClass);
    IconData resultIcon = _getResultIcon(predictedClass);
    String resultMessage = _getResultMessage(predictedClass);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.7),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: resultColor.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(docId, data),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (imageBase64.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(imageBase64),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                patientName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.badge,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'ID: $patientId',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              resultIcon,
                              size: 20,
                              color: resultColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              resultMessage,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: resultColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        'Confidence: ${confidence.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (timestamp != null)
                    Text(
                      _formatDate(timestamp.toDate()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditDialog(docId, data),
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(docId, patientName),
                    icon: Icon(Icons.delete, size: 16),
                    label: Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(String docId, Map<String, dynamic> data) {
    String predictedClass = data['predictedClass'] ?? '';
    double confidence = (data['confidence'] ?? 0).toDouble();
    String patientName = data['patientName'] ?? 'Unknown';
    String patientId = data['patientId'] ?? 'N/A';
    String imageBase64 = data['imageBase64'] ?? '';
    Map<String, dynamic>? probabilities = data['probabilities'];
    Timestamp? timestamp = data['timestamp'];

    Color resultColor = _getResultColor(predictedClass);
    IconData resultIcon = _getResultIcon(predictedClass);
    String resultMessage = _getResultMessage(predictedClass);
    String severityBadge = _getSeverityBadge(predictedClass);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Result Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (imageBase64.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        base64Decode(imageBase64),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 20),
                  _buildDetailRow('Patient Name', patientName, Icons.person),
                  _buildDetailRow('Patient ID', patientId, Icons.badge),
                  if (timestamp != null)
                    _buildDetailRow(
                      'Date',
                      _formatDate(timestamp.toDate()),
                      Icons.calendar_today,
                    ),
                  Divider(height: 32),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: resultColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          resultIcon,
                          size: 48,
                          color: resultColor,
                        ),
                        SizedBox(height: 12),
                        Text(
                          resultMessage,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: resultColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            severityBadge,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: resultColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Confidence: ${confidence.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (probabilities != null) ...[
                    SizedBox(height: 20),
                    Text(
                      'Probability Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 12),
                    ...probabilities.entries.map((entry) {
                      return _buildProbabilityBar(
                        entry.key,
                        (entry.value as num).toDouble(),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(String label, double probability) {
    Color barColor;
    String displayLabel;

    if (label == 'normal') {
      barColor = Colors.green;
      displayLabel = 'Normal';
    } else if (label == 'early_glucoma') {
      barColor = Colors.orange;
      displayLabel = 'Early Glaucoma';
    } else if (label == 'advanced_glucoma') {
      barColor = Colors.red;
      displayLabel = 'Advanced Glaucoma';
    } else {
      barColor = Colors.grey;
      displayLabel = label;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${(probability * 100).toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: probability,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> data) {
    final TextEditingController nameController =
        TextEditingController(text: data['patientName'] ?? '');
    final TextEditingController idController =
        TextEditingController(text: data['patientId'] ?? '');
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Text('Edit Details'),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Patient Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: idController,
                      decoration: InputDecoration(
                        labelText: 'Patient ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter patient ID';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isUpdating = true;
                            });

                            try {
                              await FirebaseFirestore.instance
                                  .collection('glaucoma_advanced_results')
                                  .doc(docId)
                                  .update({
                                'patientName': nameController.text.trim(),
                                'patientId': idController.text.trim(),
                              });

                              Navigator.of(dialogContext).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Details updated successfully!'),
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
                              setDialogState(() {
                                isUpdating = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String docId, String patientName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600]),
              SizedBox(width: 8),
              Text('Confirm Delete'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the result for "$patientName"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteResult(docId, patientName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteResult(String docId, String patientName) async {
    try {
      await FirebaseFirestore.instance
          .collection('glaucoma_advanced_results')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Result deleted successfully!'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getResultColor(String predictedClass) {
    if (predictedClass == 'normal') return Colors.green;
    if (predictedClass == 'early_glucoma') return Colors.orange;
    if (predictedClass == 'advanced_glucoma') return Colors.red;
    return Colors.grey;
  }

  IconData _getResultIcon(String predictedClass) {
    if (predictedClass == 'normal') return Icons.check_circle;
    if (predictedClass == 'early_glucoma') return Icons.warning_amber;
    if (predictedClass == 'advanced_glucoma') return Icons.dangerous;
    return Icons.help_outline;
  }

  String _getResultMessage(String predictedClass) {
    if (predictedClass == 'normal') return 'Healthy';
    if (predictedClass == 'early_glucoma') return 'Early Glaucoma';
    if (predictedClass == 'advanced_glucoma') return 'Advanced Glaucoma';
    return predictedClass;
  }

  String _getSeverityBadge(String predictedClass) {
    if (predictedClass == 'normal') return 'NO RISK';
    if (predictedClass == 'early_glucoma') return 'MODERATE RISK';
    if (predictedClass == 'advanced_glucoma') return 'HIGH RISK';
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}