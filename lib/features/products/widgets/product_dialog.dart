import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/product_model.dart';

class ProductDialog extends StatefulWidget {
  final ProductModel? product;
  final List<String> categories;
  final List<String> suppliers;
  final Function(ProductModel) onSave;

  const ProductDialog({
    super.key,
    this.product,
    required this.categories,
    required this.suppliers,
    required this.onSave,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _skuController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _offerPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _unitController;

  late String _selectedCategory;
  late String _selectedSupplier;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _offerPriceController = TextEditingController(
        text: p?.offerPrice != null ? p!.offerPrice!.toStringAsFixed(0) : '');
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '10');
    _unitController = TextEditingController(text: p?.unit ?? 'pack');

    final cleanCats = widget.categories.where((c) => c != 'All categories').toList();
    _selectedCategory = p?.category ?? (cleanCats.isNotEmpty ? cleanCats.first : 'Rice & Grains');

    final cleanSups = widget.suppliers.where((s) => s != 'All suppliers').toList();
    _selectedSupplier = p?.supplier ?? (cleanSups.isNotEmpty ? cleanSups.first : 'Golden Mills Ltd.');

    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _skuController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _offerPriceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text) ?? 0;
    final offerPrice = _offerPriceController.text.isNotEmpty
        ? double.tryParse(_offerPriceController.text)
        : null;
    final stock = int.tryParse(_stockController.text) ?? 0;

    final productModel = ProductModel(
      id: widget.product?.id ?? 'prd_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      sku: _skuController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      supplier: _selectedSupplier,
      price: price,
      offerPrice: offerPrice,
      stock: stock,
      unit: _unitController.text.trim(),
      isActive: _isActive,
    );

    widget.onSave(productModel);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Product' : 'Add New Product',
                    style: AppTypography.h3Bold,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24, color: AppColors.cardBorder),

              // Form Scroll Area
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Product Name',
                          hintText: 'e.g. Basmati Rice 5kg',
                          controller: _nameController,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Brand',
                                hintText: 'e.g. Golden Mills',
                                controller: _brandController,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'SKU',
                                hintText: 'e.g. RIC-5K-002',
                                controller: _skuController,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Description',
                          hintText: 'Product details and specifications',
                          controller: _descController,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Category *', style: AppTypography.labelBold),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: widget.categories.contains(_selectedCategory)
                                        ? _selectedCategory
                                        : widget.categories.firstWhere((c) => c != 'All categories', orElse: () => 'Rice & Grains'),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: widget.categories
                                        .where((c) => c != 'All categories')
                                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedCategory = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Supplier *', style: AppTypography.labelBold),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: widget.suppliers.contains(_selectedSupplier)
                                        ? _selectedSupplier
                                        : widget.suppliers.firstWhere((s) => s != 'All suppliers', orElse: () => 'Golden Mills Ltd.'),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: widget.suppliers
                                        .where((s) => s != 'All suppliers')
                                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _selectedSupplier = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Price (৳)',
                                hintText: '780',
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || double.tryParse(v) == null ? 'Valid price' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Offer Price (৳)',
                                hintText: '720 (optional)',
                                isRequired: false,
                                controller: _offerPriceController,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Unit',
                                hintText: 'e.g. bag, bottle, kg',
                                controller: _unitController,
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Stock Quantity',
                                hintText: '10',
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || int.tryParse(v) == null ? 'Valid stock' : null,
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
                              _isActive ? 'Active (Visible to salesmen)' : 'Inactive (Hidden)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 24, color: AppColors.cardBorder),

              // Actions
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
                      text: isEdit ? 'Save Changes' : 'Add Product',
                      onPressed: _submit,
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
