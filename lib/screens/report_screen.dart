import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/claim.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  final Claim claim;

  const ReportScreen({required this.claim, Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _generating = false;
  bool _generated = false;
  Uint8List? _pdfBytes;
  String _statusMessage = '';

  Future<void> _generateReport() async {
    setState(() {
      _generating = true;
      _statusMessage = 'Generating report...';
    });

    try {
      final bytes = await ApiService.generateReport(widget.claim.id);
      setState(() {
        _pdfBytes = bytes;
        _generated = true;
        _statusMessage =
            'Report generated successfully! (${(bytes.length / 1024).toStringAsFixed(1)} KB)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to generate report: $e';
      });
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.claim.claimNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.claim.vehicleModel} - ${widget.claim.vehicleNumber}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Insured: ${widget.claim.insuredName}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Report Generation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will generate a comprehensive PDF report including claim details, '
              'parts estimate with depreciation, inspection photos, and assessment remarks.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _generated ? Colors.green[50] : Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _generated ? Icons.check_circle : Icons.picture_as_pdf,
                  size: 80,
                  color: _generated ? Colors.green : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _generated
                      ? Colors.green[50]
                      : (_statusMessage.contains('Failed')
                          ? Colors.red[50]
                          : Colors.blue[50]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _generated
                        ? Colors.green[800]
                        : (_statusMessage.contains('Failed')
                            ? Colors.red[800]
                            : Colors.blue[800]),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _generating ? null : _generateReport,
                icon: _generating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_generated ? Icons.refresh : Icons.picture_as_pdf),
                label: Text(
                  _generating
                      ? 'Generating...'
                      : (_generated
                          ? 'Regenerate Report'
                          : 'Generate Report'),
                ),
              ),
            ),
            if (_generated) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Report generated. PDF download is available on web.'),
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Complete & Go Back'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
