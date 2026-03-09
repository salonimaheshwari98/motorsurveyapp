import 'package:flutter/material.dart';
import '../models/claim.dart';
import '../services/api_service.dart';

class InspectionScreen extends StatefulWidget {
  final Claim claim;

  const InspectionScreen({required this.claim, Key? key}) : super(key: key);

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  final List<String> _photoTypes = [
    'Front View',
    'Rear View',
    'Left Side',
    'Right Side',
    'Odometer',
    'Chassis',
    'Damage Photo 1',
    'Damage Photo 2',
  ];

  final Map<String, bool> _capturedPhotos = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (var type in _photoTypes) {
      _capturedPhotos[type] = false;
    }
    _loadExistingPhotos();
  }

  Future<void> _loadExistingPhotos() async {
    try {
      final photos = await ApiService.getPhotos(widget.claim.id);
      setState(() {
        for (var photo in photos) {
          if (_capturedPhotos.containsKey(photo.photoType)) {
            _capturedPhotos[photo.photoType] = true;
          }
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Photos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capture inspection photos in sequence',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _photoTypes.length,
              itemBuilder: (context, index) {
                final photoType = _photoTypes[index];
                final isCaptured = _capturedPhotos[photoType] ?? false;
                return _buildPhotoCard(photoType, isCaptured);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (_capturedPhotos.values.every((v) => v) &&
                        !_isSubmitting)
                    ? _submitPhotos
                    : null,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Complete Inspection'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(String photoType, bool isCaptured) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isCaptured ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: isCaptured
                  ? const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    )
                  : const Icon(Icons.camera_alt, size: 32, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photoType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCaptured ? 'Captured ✓' : 'Not captured',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCaptured ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _capturePhoto(photoType),
              child: const Text('Capture'),
            ),
          ],
        ),
      ),
    );
  }

  void _capturePhoto(String photoType) async {
    // Save photo record to backend
    try {
      await ApiService.addPhoto(widget.claim.id, {
        'photo_type': photoType,
        'timestamp': DateTime.now().toIso8601String(),
        'gps_location': 'GPS pending',
        'image_url': '',
      });
      setState(() => _capturedPhotos[photoType] = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo captured: $photoType')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  void _submitPhotos() async {
    setState(() => _isSubmitting = true);
    try {
      await ApiService.updateClaim(
          widget.claim.id, {'status': 'in_progress'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All photos submitted'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
