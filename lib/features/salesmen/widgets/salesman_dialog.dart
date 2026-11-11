import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/salesman_model.dart';

class SalesmanDialog extends StatefulWidget {
  final SalesmanModel? salesman;
  final Function(SalesmanModel) onSave;

  const SalesmanDialog({
    super.key,
    this.salesman,
    required this.onSave,
  });

  @override
  State<SalesmanDialog> createState() => _SalesmanDialogState();
}

class _SalesmanDialogState extends State<SalesmanDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nidController;
  late final TextEditingController _territoryController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final s = widget.salesman;
    _nameController = TextEditingController(text: s?.name ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _nidController = TextEditingController(text: s?.nid ?? '');
    _territoryController = TextEditingController(text: s?.assignedTerritory ?? 'Mirpur, Dhaka');
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nidController.dispose();
    _territoryController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'SM';
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final model = SalesmanModel(
      id: widget.salesman?.id ?? 'sm_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      nid: _nidController.text.trim(),
      assignedTerritory: _territoryController.text.trim(),
      status: _isActive ? 'Active' : 'Inactive',
      isOnline: widget.salesman?.isOnline ?? _isActive,
      lastSeen: widget.salesman?.lastSeen ?? (_isActive ? 'Online' : 'Never'),
      totalOrders: widget.salesman?.totalOrders ?? 0,
      totalCollected: widget.salesman?.totalCollected ?? 0.0,
      avatarInitials: widget.salesman?.avatarInitials ?? _getInitials(name),
    );

    widget.onSave(model);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.salesman != null;

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
                      isEdit ? 'Edit Salesman' : 'Add New Salesman',
                      style: AppTypography.h3Bold,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.cardBorder),

                // Form Fields
                CustomTextField(
                  label: 'Full Name',
                  hintText: 'e.g. Rakib Hasan',
                  controller: _nameController,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Email',
                        hintText: 'e.g. rakib@mail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Phone Number',
                        hintText: 'e.g. 01811-223344',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
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
                        label: 'NID Number',
                        hintText: 'e.g. 1990123456789',
                        controller: _nidController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Assigned Territory',
                        hintText: 'e.g. Mirpur, Dhaka',
                        controller: _territoryController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Switch(
                      value: _isActive,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isActive ? 'Status: Active' : 'Status: Inactive',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
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
                        text: isEdit ? 'Save Changes' : 'Add Salesman',
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
