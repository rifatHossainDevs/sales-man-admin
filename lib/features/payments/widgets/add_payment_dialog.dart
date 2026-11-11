import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/payment_model.dart';

class AddPaymentDialog extends StatefulWidget {
  final Function(PaymentModel) onSave;

  const AddPaymentDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _invoiceController;
  late final TextEditingController _salesmanController;
  late final TextEditingController _retailerController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  String _status = 'Paid';

  @override
  void initState() {
    super.initState();
    _invoiceController = TextEditingController(text: 'INV-0043');
    _salesmanController = TextEditingController(text: 'Rakib Hasan');
    _retailerController = TextEditingController(text: 'Rahman Store');
    _amountController = TextEditingController(text: '');
    _notesController = TextEditingController(text: 'Cash collected on visit');
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _salesmanController.dispose();
    _retailerController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final now = DateTime.now();
    final model = PaymentModel(
      id: 'pay_${now.millisecondsSinceEpoch}',
      trxId: 'CSH-${now.millisecondsSinceEpoch.toString().substring(7)}',
      invoiceNo: _invoiceController.text.trim(),
      salesmanName: _salesmanController.text.trim(),
      retailerName: _retailerController.text.trim(),
      amount: amount,
      status: _status,
      paidAt: 'Today, ${TimeOfDay.now().format(context)}',
      paymentMethod: 'Cash',
      notes: _notesController.text.trim(),
    );

    widget.onSave(model);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Record Cash Collection', style: AppTypography.h3Bold),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.cardBorder),

                // Method Display: Cash Only notice
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.infoBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.infoBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.payments_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Method: Cash Payment Only',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Invoice No.',
                        hintText: 'e.g. INV-0043',
                        controller: _invoiceController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Amount Collected (৳)',
                        hintText: 'e.g. 15000',
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Valid amount required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Salesman',
                        hintText: 'e.g. Rakib Hasan',
                        controller: _salesmanController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Retailer',
                        hintText: 'e.g. Rahman Store',
                        controller: _retailerController,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                const Text('Payment Status', style: AppTypography.labelBold),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Paid', child: Text('Paid (Completed)')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending (Awaiting Deposit)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Collection Notes',
                  hintText: 'Verification note, deposit slip, etc.',
                  controller: _notesController,
                  isRequired: false,
                ),

                const Divider(height: 24, color: AppColors.cardBorder),

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
                      width: 150,
                      child: CustomButton(
                        text: 'Save Payment',
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
