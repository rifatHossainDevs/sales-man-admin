import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/retailer_model.dart';

class RetailerDialog extends StatefulWidget {
  final RetailerModel? retailer;
  final Function(RetailerModel) onSave;

  const RetailerDialog({
    super.key,
    this.retailer,
    required this.onSave,
  });

  @override
  State<RetailerDialog> createState() => _RetailerDialogState();
}

class _RetailerDialogState extends State<RetailerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _storeNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _subDistrictController;
  late final TextEditingController _areaController;
  late final TextEditingController _registeredByController;

  @override
  void initState() {
    super.initState();
    final r = widget.retailer;
    _storeNameController = TextEditingController(text: r?.storeName ?? '');
    _ownerNameController = TextEditingController(text: r?.ownerName ?? '');
    _phoneController = TextEditingController(text: r?.phone ?? '');
    _addressController = TextEditingController(text: r?.address ?? '');
    _subDistrictController = TextEditingController(text: r?.subDistrict ?? 'Mirpur');
    _areaController = TextEditingController(text: r?.area ?? 'Mirpur-10');
    _registeredByController = TextEditingController(text: r?.registeredBy ?? 'Rakib Hasan');
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _subDistrictController.dispose();
    _areaController.dispose();
    _registeredByController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final model = RetailerModel(
      id: widget.retailer?.id ?? 'ret_${DateTime.now().millisecondsSinceEpoch}',
      storeName: _storeNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      subDistrict: _subDistrictController.text.trim(),
      area: _areaController.text.trim(),
      registeredBy: _registeredByController.text.trim(),
      registeredDate: widget.retailer?.registeredDate ?? 'Today',
      ordersCount: widget.retailer?.ordersCount ?? 0,
      dueAmount: widget.retailer?.dueAmount ?? 0.0,
      isGpsMapped: widget.retailer?.isGpsMapped ?? true,
      lat: widget.retailer?.lat ?? 23.8069,
      lng: widget.retailer?.lng ?? 90.3687,
      orderHistory: widget.retailer?.orderHistory ?? const [],
    );

    widget.onSave(model);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.retailer != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Retailer' : 'Add New Retailer',
                      style: AppTypography.h3Bold,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.cardBorder),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Store Name',
                        hintText: 'e.g. Rahman Store',
                        controller: _storeNameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Owner Name',
                        hintText: 'e.g. Abdur Rahman',
                        controller: _ownerNameController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Phone Number',
                        hintText: 'e.g. 01712-345678',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Registered By (Salesman)',
                        hintText: 'e.g. Rakib Hasan',
                        controller: _registeredByController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Sub-district',
                        hintText: 'e.g. Mirpur',
                        controller: _subDistrictController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Area',
                        hintText: 'e.g. Mirpur-10',
                        controller: _areaController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Street Address',
                  hintText: 'e.g. Road 12, Mirpur-10, Dhaka-1216',
                  controller: _addressController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),

                const Divider(height: 24, color: AppColors.cardBorder),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 140,
                      child: CustomButton(
                        text: isEdit ? 'Save Changes' : 'Add Store',
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
    );
  }
}
