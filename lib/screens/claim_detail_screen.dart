import 'package:flutter/material.dart';
import '../models/claim.dart';
import 'inspection_screen.dart';
import 'parts_editor_screen.dart';
import 'remarks_screen.dart';
import 'upload_estimate_screen.dart';
import 'report_screen.dart';

class ClaimDetailScreen extends StatefulWidget {
  final Claim claim;

  const ClaimDetailScreen({required this.claim, Key? key}) : super(key: key);

  @override
  State<ClaimDetailScreen> createState() => _ClaimDetailScreenState();
}

class _ClaimDetailScreenState extends State<ClaimDetailScreen> {
  late Claim _claim;
  int _currentStep = 0;

  // estimate upload state
  String _estimateFileName = '';

  @override
  void initState() {
    super.initState();
    _claim = widget.claim;
  }

  Future<void> _openUploadEstimate() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => UploadEstimateScreen(claim: _claim),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _estimateFileName = result;
        _currentStep = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _claim.claimNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _claim.insuredName,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_claim.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _claim.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Survey Workflow',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWorkflowStep(
                    stepNumber: 1,
                    title: 'Upload Estimate',
                    description: _estimateFileName.isEmpty
                        ? 'Tap to upload garage estimate (PDF/Image)'
                        : 'Uploaded: $_estimateFileName',
                    isCompleted: _estimateFileName.isNotEmpty,
                    isCurrent: _currentStep == 0,
                    onTap: () {
                      setState(() => _currentStep = 0);
                      _openUploadEstimate();
                    },
                  ),
                  _buildWorkflowStep(
                    stepNumber: 2,
                    title: 'Extract Parts',
                    description: 'OCR extract parts from estimate',
                    isCompleted: _currentStep > 0,
                    isCurrent: _currentStep == 1,
                    onTap: () => setState(() => _currentStep = 1),
                  ),
                  _buildWorkflowStep(
                    stepNumber: 3,
                    title: 'Edit Parts',
                    description: 'Review and edit parts table',
                    isCompleted: _currentStep > 1,
                    isCurrent: _currentStep == 2,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PartsEditorScreen(claim: _claim),
                      ),
                    ),
                  ),
                  _buildWorkflowStep(
                    stepNumber: 4,
                    title: 'Inspection Photos',
                    description: 'Capture vehicle inspection photos',
                    isCompleted: _currentStep > 2,
                    isCurrent: _currentStep == 3,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InspectionScreen(claim: _claim),
                      ),
                    ),
                  ),
                  _buildWorkflowStep(
                    stepNumber: 5,
                    title: 'Add Remarks',
                    description: 'Add inspection notes & assessment',
                    isCompleted: _currentStep > 3,
                    isCurrent: _currentStep == 4,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RemarksScreen(claim: _claim),
                      ),
                    ),
                  ),
                  _buildWorkflowStep(
                    stepNumber: 6,
                    title: 'Generate Report',
                    description: 'Generate final survey report PDF',
                    isCompleted: _currentStep > 4,
                    isCurrent: _currentStep == 5,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportScreen(claim: _claim),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Claim Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Vehicle', _claim.vehicleModel),
                  _buildInfoRow('Vehicle No.', _claim.vehicleNumber),
                  _buildInfoRow('Policy No.', _claim.policyNumber),
                  _buildInfoRow('Insurer', _claim.insurer),
                  _buildInfoRow('Location', _claim.accidentLocation),
                  _buildInfoRow(
                    'Date',
                    '${_claim.accidentDate.day}/${_claim.accidentDate.month}/${_claim.accidentDate.year}',
                  ),
                  _buildInfoRow('Insured Name', _claim.insuredName),
                  _buildInfoRow('Phone', _claim.phone),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowStep({
    required int stepNumber,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isCurrent,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isCurrent ? Colors.blue : Colors.grey[300]!,
              width: isCurrent ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isCurrent ? Colors.blue[50] : Colors.white,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : Text(
                          stepNumber.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
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
              Icon(
                Icons.chevron_right,
                color: isCurrent ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
