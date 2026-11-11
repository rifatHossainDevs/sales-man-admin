import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/mock/mock_salesmen_data.dart';
import '../../../data/models/territory_model.dart';

class AssignSalesmanDialog extends StatefulWidget {
  final AreaModel area;
  final Function(String? salesmanName) onAssign;

  const AssignSalesmanDialog({
    super.key,
    required this.area,
    required this.onAssign,
  });

  @override
  State<AssignSalesmanDialog> createState() => _AssignSalesmanDialogState();
}

class _AssignSalesmanDialogState extends State<AssignSalesmanDialog> {
  String? _selectedSalesman;

  @override
  void initState() {
    super.initState();
    _selectedSalesman = widget.area.assignedSalesman;
  }

  @override
  Widget build(BuildContext context) {
    final salesmen = MockSalesmenData.salesmen.map((s) => s.name).toList();
    if (!salesmen.contains('Tariqul Islam')) salesmen.insert(0, 'Tariqul Islam');
    if (!salesmen.contains('Rafiqul Islam')) salesmen.insert(1, 'Rafiqul Islam');
    if (!salesmen.contains('Kamrul Hasan')) salesmen.insert(2, 'Kamrul Hasan');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Assign Salesman', style: AppTypography.heading2),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Assign a field representative to territory ${widget.area.name} (Code: ${widget.area.code})',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text('Field Salesman', style: AppTypography.labelBold),
              const SizedBox(height: 6),
              DropdownButtonFormField<String?>(
                initialValue: _selectedSalesman,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                hint: const Text('Select a salesman...'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Unassigned (None)'),
                  ),
                  ...salesmen.map((name) => DropdownMenuItem<String?>(
                        value: name,
                        child: Text(name),
                      )),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedSalesman = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Assignment',
                      onPressed: () {
                        widget.onAssign(_selectedSalesman);
                        Navigator.of(context).pop();
                      },
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
}
