import 'package:flutter/material.dart';
import '../models/claim.dart';
import '../models/part.dart';
import '../services/api_service.dart';
import '../services/depreciation_service.dart';

class PartsEditorScreen extends StatefulWidget {
  final Claim claim;

  const PartsEditorScreen({required this.claim, Key? key}) : super(key: key);

  @override
  State<PartsEditorScreen> createState() => _PartsEditorScreenState();
}

class _PartsEditorScreenState extends State<PartsEditorScreen> {
  late List<PartItem> _parts;
  double _vehicleAgeYears = 5.0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _vehicleAgeYears = (DateTime.now().year - widget.claim.manufactureYear)
        .toDouble()
        .clamp(0, 30);
    _parts = [];
    _loadParts();
  }

  Future<void> _loadParts() async {
    try {
      final parts = await ApiService.getParts(widget.claim.id);
      setState(() {
        _parts = parts;
        _isLoading = false;
      });
      if (_parts.isEmpty) {
        _addSampleParts();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // No parts yet, add defaults for editing
      _addSampleParts();
    }
  }

  void _addSampleParts() {
    setState(() {
      _parts = [
        PartItem(
          id: 0,
          claimId: widget.claim.id,
          partName: 'Front Bumper',
          quantity: 1,
          rate: 4500,
          amount: 4500,
          materialType: 'plastic',
        ),
        PartItem(
          id: 0,
          claimId: widget.claim.id,
          partName: 'Headlight Assembly',
          quantity: 2,
          rate: 3000,
          amount: 6000,
          materialType: 'glass',
        ),
      ];
    });
    _calculateDepreciation();
  }

  void _calculateDepreciation() {
    for (var part in _parts) {
      DepreciationService.applyDepreciation(part, _vehicleAgeYears);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Parts & Depreciation'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Age (Years)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _vehicleAgeYears,
                    onChanged: (value) {
                      setState(() => _vehicleAgeYears = value);
                      _calculateDepreciation();
                    },
                    min: 0,
                    max: 15,
                    divisions: 30,
                    label: _vehicleAgeYears.toStringAsFixed(1),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${_vehicleAgeYears.toStringAsFixed(1)} yrs',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Parts Table',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Part Name')),
                  DataColumn(label: Text('Qty')),
                  DataColumn(label: Text('Rate')),
                  DataColumn(label: Text('Material')),
                  DataColumn(label: Text('Depr %')),
                  DataColumn(label: Text('Approved')),
                  DataColumn(label: Text('Accept')),
                ],
                rows: _parts.asMap().entries.map((entry) {
                  int index = entry.key;
                  PartItem part = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            part.partName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(part.quantity.toString()),
                      ),
                      DataCell(
                        Text('₹${part.rate.toStringAsFixed(0)}'),
                      ),
                      DataCell(
                        GestureDetector(
                          onTap: () => _editMaterialType(index),
                          child: Text(
                            part.materialType,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${part.depreciationPercent.toStringAsFixed(0)}%',
                        ),
                      ),
                      DataCell(
                        Text(
                          '₹${part.approvedAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(
                        Checkbox(
                          value: part.accepted,
                          onChanged: (value) {
                            setState(() => part.accepted = value ?? false);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Total Amount',
                    '₹${_parts.fold<double>(0, (sum, p) => sum + p.amount).toStringAsFixed(0)}',
                  ),
                  _buildSummaryRow(
                    'Total Approved',
                    '₹${_parts.fold<double>(0, (sum, p) => sum + p.approvedAmount).toStringAsFixed(0)}',
                  ),
                  _buildSummaryRow(
                    'Savings (Depr)',
                    '₹${(_parts.fold<double>(0, (sum, p) => sum + p.amount) - _parts.fold<double>(0, (sum, p) => sum + p.approvedAmount)).toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveParts,
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Parts'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _editMaterialType(int index) {
    final materials = [
      'metal',
      'plastic',
      'rubber',
      'battery',
      'tyre',
      'glass',
      'labour',
      'paint'
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Material Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: materials
                .map(
                  (material) => ListTile(
                    title: Text(material),
                    onTap: () {
                      setState(() => _parts[index].materialType = material);
                      _calculateDepreciation();
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _saveParts() async {
    setState(() => _isSaving = true);
    try {
      await ApiService.saveParts(widget.claim.id, _parts);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parts saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
