import 'package:flutter/material.dart';
import '../models/claim.dart';
import '../services/api_service.dart';

class RemarksScreen extends StatefulWidget {
  final Claim claim;

  const RemarksScreen({required this.claim, Key? key}) : super(key: key);

  @override
  State<RemarksScreen> createState() => _RemarksScreenState();
}

class _RemarksScreenState extends State<RemarksScreen> {
  final _notesController = TextEditingController();
  final _recommendationController = TextEditingController();
  double _liability = 100.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingAssessment();
  }

  Future<void> _loadExistingAssessment() async {
    try {
      final assessment = await ApiService.getAssessment(widget.claim.id);
      setState(() {
        _notesController.text = assessment.inspectionNotes;
        _liability = assessment.liability;
        _recommendationController.text = assessment.recommendation;
      });
    } catch (_) {
      // No existing assessment, start fresh
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  Future<void> _submitRemarks() async {
    if (_notesController.text.isEmpty || _recommendationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.saveAssessment(widget.claim.id, {
        'inspection_notes': _notesController.text,
        'liability': _liability,
        'recommendation': _recommendationController.text,
        'final_amount': 0.0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remarks saved successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Remarks & Assessment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inspection Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Enter detailed inspection observations...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Liability Assessment',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Liability Percentage'),
                        Text(
                          '${_liability.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _liability,
                      onChanged: (value) {
                        setState(() => _liability = value);
                      },
                      min: 0,
                      max: 100,
                      divisions: 20,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _liability = 0),
                          child: const Text('No Liability'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _liability = 50),
                          child: const Text('50%'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _liability = 100),
                          child: const Text('Full'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Repair Recommendation',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _recommendationController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Recommended course of action...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Options',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Voice-to-Text Notes'),
                      subtitle: const Text('Record audio notes'),
                      value: false,
                      onChanged: (value) {},
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Attach Documents'),
                      subtitle: const Text('Attach police complaint, etc.'),
                      value: false,
                      onChanged: (value) {},
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRemarks,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Remarks & Continue'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
