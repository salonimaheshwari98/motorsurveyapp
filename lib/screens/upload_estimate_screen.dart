import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/claim.dart';
import '../services/api_service.dart';

class UploadEstimateScreen extends StatefulWidget {
  final Claim claim;

  const UploadEstimateScreen({required this.claim, Key? key}) : super(key: key);

  @override
  State<UploadEstimateScreen> createState() => _UploadEstimateScreenState();
}

class _UploadEstimateScreenState extends State<UploadEstimateScreen> {
  String _fileName = '';
  Uint8List? _fileBytes;
  bool _uploading = false;
  bool _uploaded = false;
  String _statusMessage = '';

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        setState(() => _statusMessage = 'Could not read file data');
        return;
      }

      final ext = file.extension?.toLowerCase() ?? '';
      if (!['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
        setState(
            () => _statusMessage = 'Please select a PDF or image file');
        return;
      }

      setState(() {
        _fileName = file.name;
        _fileBytes = file.bytes;
        _statusMessage = 'File selected: ${file.name} (${(file.size / 1024).toStringAsFixed(1)} KB)';
        _uploaded = false;
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error picking file: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_fileBytes == null) {
      setState(() => _statusMessage = 'No file selected');
      return;
    }

    setState(() {
      _uploading = true;
      _statusMessage = 'Uploading...';
    });

    try {
      final result = await ApiService.uploadEstimate(
        widget.claim.id,
        _fileBytes!,
        _fileName,
      );

      setState(() {
        _uploaded = true;
        _statusMessage = 'Uploaded successfully!';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estimate uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Upload error: $e';
      });
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Garage Estimate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Claim: ${widget.claim.claimNumber}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.claim.vehicleModel} - ${widget.claim.vehicleNumber}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Upload area
            GestureDetector(
              onTap: _uploading ? null : _pickFile,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: _fileName.isEmpty
                      ? Colors.grey[100]
                      : (_uploaded ? Colors.green[50] : Colors.blue[50]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fileName.isEmpty
                        ? Colors.grey[400]!
                        : (_uploaded ? Colors.green : Colors.blue),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _fileName.isEmpty
                          ? Icons.cloud_upload_outlined
                          : (_uploaded
                              ? Icons.check_circle
                              : Icons.description),
                      size: 48,
                      color: _fileName.isEmpty
                          ? Colors.grey
                          : (_uploaded ? Colors.green : Colors.blue),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _fileName.isEmpty
                          ? 'Tap to select estimate file'
                          : _fileName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _fileName.isEmpty ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported: PDF, JPG, PNG',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status message
            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _uploaded
                      ? Colors.green[50]
                      : (_statusMessage.contains('Error') ||
                              _statusMessage.contains('failed')
                          ? Colors.red[50]
                          : Colors.blue[50]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _uploaded
                        ? Colors.green[800]
                        : (_statusMessage.contains('Error') ||
                                _statusMessage.contains('failed')
                            ? Colors.red[800]
                            : Colors.blue[800]),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickFile,
                    icon: const Icon(Icons.folder_open),
                    label: Text(
                        _fileName.isEmpty ? 'Choose File' : 'Change File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_fileBytes != null && !_uploading && !_uploaded)
                        ? _uploadFile
                        : null,
                    icon: _uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_uploading
                        ? 'Uploading...'
                        : (_uploaded ? 'Uploaded' : 'Upload')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                          _uploaded ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Instructions
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInstruction(
              '1',
              'Take a clear photo of the garage estimate or use the PDF copy',
            ),
            _buildInstruction(
              '2',
              'Select the file using the Choose File button above',
            ),
            _buildInstruction(
              '3',
              'Click Upload to send the estimate to the server',
            ),
            _buildInstruction(
              '4',
              'OCR will automatically extract parts from the estimate',
            ),
            const SizedBox(height: 24),

            // Done button
            if (_uploaded)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _fileName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Continue to Parts Extraction',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[100],
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
