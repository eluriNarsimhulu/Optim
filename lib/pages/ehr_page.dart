//root/lib/pages/ehr_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class EHRPage extends StatefulWidget {
  @override
  _EHRPageState createState() => _EHRPageState();
}

class _EHRPageState extends State<EHRPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  List<Map<String, dynamic>> allPatients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllPatients() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        isLoading = true;
      });

      Set<String> patientIds = {};
      Map<String, Map<String, dynamic>> patientsMap = {};

      // Get all collections
      final collections = [
        'glaucoma_advanced_results',
        'glaucoma_classifications',
      ];

      for (String collection in collections) {
        final snapshot = await FirebaseFirestore.instance
            .collection(collection)
            .where('userId', isEqualTo: user.uid)
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final patientId = data['patientId'] ?? '';
          final patientName = data['patientName'] ?? '';

          if (patientId.isNotEmpty && !patientIds.contains(patientId)) {
            patientIds.add(patientId);
            patientsMap[patientId] = {
              'patientId': patientId,
              'patientName': patientName,
              'lastUpdated': data['timestamp'],
            };
          }
        }
      }

      // Get segmentation results
      final segmentationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('glaucoma_segmentation_results')
          .get();

      for (var doc in segmentationSnapshot.docs) {
        final data = doc.data();
        final patientId = data['patientId'] ?? '';
        final patientName = data['patientName'] ?? '';

        if (patientId.isNotEmpty && !patientIds.contains(patientId)) {
          patientIds.add(patientId);
          patientsMap[patientId] = {
            'patientId': patientId,
            'patientName': patientName,
            'lastUpdated': data['timestamp'],
          };
        }
      }

      setState(() {
        allPatients = patientsMap.values.toList();
        allPatients.sort((a, b) {
          final aTime = a['lastUpdated'] as Timestamp?;
          final bTime = b['lastUpdated'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });
        isLoading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredPatients {
    if (searchQuery.isEmpty) {
      return allPatients;
    }
    return allPatients.where((patient) {
      final name = patient['patientName'].toString().toLowerCase();
      final id = patient['patientId'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || id.contains(query);
    }).toList();
  }

  void _navigateToPatientRecords(String patientId, String patientName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientRecordsPage(
          patientId: patientId,
          patientName: patientName,
        ),
      ),
    );
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
              Color(0xFFFFF3E0),
              Colors.white,
              Color(0xFFE8EAF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredPatients.isEmpty
                        ? _buildEmptyState()
                        : _buildPatientsList(),
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
              Icons.medical_information,
              size: 32,
              color: Colors.orange[700],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Electronic Health Records',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Search and view patient medical history',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by patient name or ID...',
          prefixIcon: Icon(Icons.search, color: Colors.orange[700]),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery.isEmpty ? Icons.folder_open : Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No Patient Records'
                : 'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            searchQuery.isEmpty
                ? 'Start by saving patient results'
                : 'Try searching with a different name or ID',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = filteredPatients[index];
        return _buildPatientCard(patient);
      },
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.7),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => _navigateToPatientRecords(
          patient['patientId'],
          patient['patientName'],
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: Colors.orange[700],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient['patientName'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'ID: ${patient['patientId']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (patient['lastUpdated'] != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            'Last visit: ${_formatTimestamp(patient['lastUpdated'])}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.orange[700],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Today';
    }
  }
}

// Patient Records Page
class PatientRecordsPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  PatientRecordsPage({
    required this.patientId,
    required this.patientName,
  });

  @override
  _PatientRecordsPageState createState() => _PatientRecordsPageState();
}

class _PatientRecordsPageState extends State<PatientRecordsPage> {
  List<Map<String, dynamic>> allRecords = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadPatientRecords();
  }

  Future<void> _loadPatientRecords() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        isLoading = true;
        allRecords = [];
      });

      // Load Advanced Classification Results
      final advancedSnapshot = await FirebaseFirestore.instance
          .collection('glaucoma_advanced_results')
          .where('userId', isEqualTo: user.uid)
          .where('patientId', isEqualTo: widget.patientId)
          .get();

      for (var doc in advancedSnapshot.docs) {
        final data = doc.data();
        allRecords.add({
          'type': 'Advanced Classification',
          'icon': Icons.auto_awesome,
          'color': Colors.deepPurple,
          'data': data,
          'timestamp': data['timestamp'],
          'docId': doc.id,
        });
      }

      // Load Classification Results
      final classificationSnapshot = await FirebaseFirestore.instance
          .collection('glaucoma_classifications')
          .where('userId', isEqualTo: user.uid)
          .where('patientId', isEqualTo: widget.patientId)
          .get();

      for (var doc in classificationSnapshot.docs) {
        final data = doc.data();
        allRecords.add({
          'type': 'Classification',
          'icon': Icons.category,
          'color': Colors.blue,
          'data': data,
          'timestamp': data['timestamp'],
          'docId': doc.id,
        });
      }

      // Load Segmentation Results
      final segmentationSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('glaucoma_segmentation_results')
          .where('patientId', isEqualTo: widget.patientId)
          .get();

      for (var doc in segmentationSnapshot.docs) {
        final data = doc.data();
        allRecords.add({
          'type': 'Segmentation',
          'icon': Icons.healing,
          'color': Colors.green,
          'data': data,
          'timestamp': data['timestamp'],
          'docId': doc.id,
        });
      }

      // Sort by timestamp (newest first)
      allRecords.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading records: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredRecords {
    if (selectedFilter == 'All') {
      return allRecords;
    }
    return allRecords.where((record) => record['type'] == selectedFilter).toList();
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
              Color(0xFFFFF3E0),
              Colors.white,
              Color(0xFFE8EAF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredRecords.isEmpty
                        ? _buildEmptyState()
                        : _buildRecordsList(),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patientName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'ID: ${widget.patientId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.folder, color: Colors.orange[700]),
                SizedBox(width: 8),
                Text(
                  '${allRecords.length} Total Records',
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
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Advanced Classification', 'Classification', 'Segmentation'];
    
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white.withOpacity(0.7),
              selectedColor: Colors.orange[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.orange[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No Records Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            selectedFilter == 'All'
                ? 'No medical records for this patient'
                : 'No $selectedFilter records',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final type = record['type'] as String;
    final icon = record['icon'] as IconData;
    final color = record['color'] as Color;
    final data = record['data'] as Map<String, dynamic>;
    final timestamp = record['timestamp'] as Timestamp?;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.7),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => _showRecordDetails(record),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        if (timestamp != null)
                          Text(
                            _formatTimestamp(timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              _buildRecordPreview(type, data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordPreview(String type, Map<String, dynamic> data) {
    if (type == 'Advanced Classification') {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Result:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                data['predictedClass'] ?? 'N/A',
                style: TextStyle(
                  color: _getAdvancedClassColor(data['predictedClass']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Confidence:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${data['confidence']?.toStringAsFixed(2) ?? '0'}%'),
            ],
          ),
        ],
      );
    } else if (type == 'Classification') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Result:', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            data['predictedClass'] ?? 'N/A',
            style: TextStyle(
              color: (data['predictedClass'] ?? '').toLowerCase().contains('glaucoma')
                  ? Colors.red
                  : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (type == 'Segmentation') {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CDR:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                data['cdrValue']?.toStringAsFixed(2) ?? '0.00',
                style: TextStyle(
                  color: (data['cdrValue'] ?? 0) >= 0.6 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diagnosis:', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                data['diagnosis'] ?? 'N/A',
                style: TextStyle(
                  color: (data['diagnosis'] ?? '').toLowerCase().contains('glaucomatous')
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Color _getAdvancedClassColor(String? predictedClass) {
    if (predictedClass == null) return Colors.grey;
    if (predictedClass == 'normal') return Colors.green;
    if (predictedClass == 'early_glucoma') return Colors.orange;
    if (predictedClass == 'advanced_glucoma') return Colors.red;
    return Colors.grey;
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    final type = record['type'] as String;
    final data = record['data'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(record['icon'], color: record['color']),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$type Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (data['imageBase64'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(data['imageBase64']),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 20),
              _buildDetailSection(type, data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String type, Map<String, dynamic> data) {
    if (type == 'Advanced Classification') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Result', data['predictedClass'] ?? 'N/A'),
          _buildDetailRow('Confidence', '${data['confidence']?.toStringAsFixed(2) ?? '0'}%'),
          SizedBox(height: 12),
          Text('Probabilities:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (data['probabilities'] != null)
            ...(data['probabilities'] as Map<String, dynamic>).entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text('${(e.value * 100).toStringAsFixed(2)}%'),
                  ],
                ),
              ),
            ),
        ],
      );
    } else if (type == 'Classification') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Result', data['predictedClass'] ?? 'N/A'),
          SizedBox(height: 12),
          Text('Probabilities:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          if (data['probabilities'] != null)
            ...(data['probabilities'] as Map<String, dynamic>).entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text('${(e.value * 100).toStringAsFixed(2)}%'),
                  ],
                ),
              ),
            ),
        ],
      );
    } else if (type == 'Segmentation') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('CDR', data['cdrValue']?.toStringAsFixed(2) ?? '0.00'),
          _buildDetailRow('Diagnosis', data['diagnosis'] ?? 'N/A'),
          SizedBox(height: 12),
          if (data['segmentedImage'] != null) ...[
            Text('Segmentation:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(data['segmentedImage']),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}