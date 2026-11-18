import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/mock/mock_salesmen_data.dart';
import '../../../data/models/territory_model.dart';

enum TerritoryLevel { district, subDistrict, area }

class TerritoryDialog extends StatefulWidget {
  final TerritoryLevel level;
  final DistrictModel? district;
  final SubDistrictModel? subDistrict;
  final AreaModel? area;
  final String? parentId; // districtCode for SubDistrict, subDistrictCode for Area
  final List<DivisionModel>? divisions;
  final String? initialDivisionCode;
  final List<String>? salesmenNames;
  final Function(dynamic) onSave;

  const TerritoryDialog({
    super.key,
    required this.level,
    this.district,
    this.subDistrict,
    this.area,
    this.parentId,
    this.divisions,
    this.initialDivisionCode,
    this.salesmenNames,
    required this.onSave,
  });

  @override
  State<TerritoryDialog> createState() => _TerritoryDialogState();
}

class _TerritoryDialogState extends State<TerritoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _retailersCountController;
  late String _selectedDivisionCode;
  String? _assignedSalesman;

  List<DivisionModel> get _availableDivisions {
    if (widget.divisions != null && widget.divisions!.isNotEmpty) {
      return widget.divisions!;
    }
    return const [
      DivisionModel(id: '1', name: 'Dhaka', code: '1'),
      DivisionModel(id: '2', name: 'Chattogram', code: '2'),
      DivisionModel(id: '3', name: 'Rajshahi', code: '3'),
      DivisionModel(id: '4', name: 'Khulna', code: '4'),
      DivisionModel(id: '5', name: 'Barishal', code: '5'),
      DivisionModel(id: '6', name: 'Sylhet', code: '6'),
      DivisionModel(id: '7', name: 'Rangpur', code: '7'),
      DivisionModel(id: '8', name: 'Mymensingh', code: '8'),
    ];
  }

  @override
  void initState() {
    super.initState();
    String initName = '';
    String initCode = '';
    int initRetailers = 0;

    final divs = _availableDivisions;
    final defaultDiv = (widget.initialDivisionCode != null &&
            widget.initialDivisionCode != 'all' &&
            divs.any((d) => d.code == widget.initialDivisionCode))
        ? widget.initialDivisionCode!
        : divs.first.code;
    _selectedDivisionCode = defaultDiv;

    switch (widget.level) {
      case TerritoryLevel.district:
        initName = widget.district?.name ?? '';
        initCode = widget.district?.code ?? '';
        initRetailers = widget.district?.retailersCount ?? 0;
        if (widget.district != null &&
            divs.any((d) => d.code == widget.district!.divisionId)) {
          _selectedDivisionCode = widget.district!.divisionId;
        }
        break;
      case TerritoryLevel.subDistrict:
        initName = widget.subDistrict?.name ?? '';
        initCode = widget.subDistrict?.code ?? '';
        initRetailers = widget.subDistrict?.retailersCount ?? 0;
        break;
      case TerritoryLevel.area:
        initName = widget.area?.name ?? '';
        initCode = widget.area?.code ?? '';
        initRetailers = widget.area?.retailersCount ?? 0;
        final existing = widget.area?.assignedSalesman;
        _assignedSalesman = (existing == null || existing == 'Unassigned' || existing.isEmpty)
            ? null
            : existing;
        break;
    }

    _nameController = TextEditingController(text: initName);
    _codeController = TextEditingController(text: initCode);
    _retailersCountController =
        TextEditingController(text: initRetailers.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _retailersCountController.dispose();
    super.dispose();
  }

  String get _levelTitle {
    switch (widget.level) {
      case TerritoryLevel.district:
        return 'District';
      case TerritoryLevel.subDistrict:
        return 'Sub-district';
      case TerritoryLevel.area:
        return 'Area';
    }
  }

  bool get _isEdit {
    switch (widget.level) {
      case TerritoryLevel.district:
        return widget.district != null;
      case TerritoryLevel.subDistrict:
        return widget.subDistrict != null;
      case TerritoryLevel.area:
        return widget.area != null;
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final count = int.tryParse(_retailersCountController.text.trim()) ?? 0;

    switch (widget.level) {
      case TerritoryLevel.district:
        final model = DistrictModel(
          id: widget.district?.id ?? 'dist_${DateTime.now().millisecondsSinceEpoch}',
          divisionId: _selectedDivisionCode,
          name: name,
          code: code,
          retailersCount: count,
        );
        widget.onSave(model);
        break;

      case TerritoryLevel.subDistrict:
        final model = SubDistrictModel(
          id: widget.subDistrict?.id ?? 'sub_${DateTime.now().millisecondsSinceEpoch}',
          districtId: widget.subDistrict?.districtId ?? widget.parentId ?? '',
          name: name,
          code: code,
          retailersCount: count,
        );
        widget.onSave(model);
        break;

      case TerritoryLevel.area:
        final model = AreaModel(
          id: widget.area?.id ?? 'area_${DateTime.now().millisecondsSinceEpoch}',
          subDistrictId: widget.area?.subDistrictId ?? widget.parentId ?? '',
          name: name,
          code: code,
          retailersCount: count,
          assignedSalesman: _assignedSalesman,
        );
        widget.onSave(model);
        break;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> salesmen = [
      ...(widget.salesmenNames != null && widget.salesmenNames!.isNotEmpty
          ? widget.salesmenNames!
          : MockSalesmenData.salesmen.map((s) => s.name)),
    ];
    if (_assignedSalesman != null &&
        _assignedSalesman!.isNotEmpty &&
        !salesmen.contains(_assignedSalesman)) {
      salesmen.insert(0, _assignedSalesman!);
    }

    final divs = _availableDivisions;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isEdit ? 'Edit $_levelTitle' : 'Add $_levelTitle',
                        style: AppTypography.heading2,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.level == TerritoryLevel.district) ...[
                    const Text('Division', style: AppTypography.labelBold),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDivisionCode,
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
                      items: divs
                          .map((div) => DropdownMenuItem<String>(
                                value: div.code,
                                child: Text('${div.code} - ${div.name}'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDivisionCode = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  CustomTextField(
                    label: '$_levelTitle Name',
                    hintText: 'e.g. ${widget.level == TerritoryLevel.district ? "Dhaka" : widget.level == TerritoryLevel.subDistrict ? "Mirpur" : "Mirpur-10"}',
                    controller: _nameController,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter $_levelTitle name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Numeric Code / Identifier',
                    hintText: 'e.g. ${widget.level == TerritoryLevel.district ? "1" : widget.level == TerritoryLevel.subDistrict ? "101" : "1001"}',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter numeric code';
                      }
                      if (int.tryParse(val.trim()) == null) {
                        return 'Code must be a number (e.g. 1, 101, 1001)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Retailers Count',
                    hintText: '0',
                    controller: _retailersCountController,
                    keyboardType: TextInputType.number,
                    isRequired: false,
                  ),
                  if (widget.level == TerritoryLevel.area) ...[
                    const SizedBox(height: 14),
                    const Text('Assign Salesman', style: AppTypography.labelBold),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String?>(
                      initialValue: _assignedSalesman,
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
                          _assignedSalesman = val;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: _isEdit ? 'Save Changes' : 'Add $_levelTitle',
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
