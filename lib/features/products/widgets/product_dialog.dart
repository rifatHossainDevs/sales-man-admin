import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/web_platform.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/models/product_model.dart';

class ProductDialog extends StatefulWidget {
  final ProductModel? product;
  final List<String> categories;
  final List<String> suppliers;
  final void Function(ProductModel product, {Uint8List? imageBytes, String? imageName}) onSave;

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

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _existingImageUrl;

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
      text: p?.offerPrice != null ? p!.offerPrice!.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(text: p != null ? p.stock.toString() : '10');
    _unitController = TextEditingController(text: p?.unit ?? 'pack');

    final cleanCats = widget.categories.where((c) => c != 'All categories').toList();
    _selectedCategory = (p != null && cleanCats.contains(p.category))
        ? p.category
        : (cleanCats.isNotEmpty ? cleanCats.first : 'Rice & Grains');

    final cleanSups = widget.suppliers.where((s) => s != 'All suppliers').toList();
    _selectedSupplier = (p != null && cleanSups.contains(p.supplier))
        ? p.supplier
        : (cleanSups.isNotEmpty ? cleanSups.first : 'Golden Mills Ltd.');

    _isActive = p?.isActive ?? true;
    _existingImageUrl = p?.imageUrl;
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

  void _pickImageFromBrowser() {
    WebPlatform.pickImageFromBrowser((bytes, fileName) {
      if (mounted) {
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = fileName;
        });
      }
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final price = double.tryParse(_priceController.text) ?? 0;
    final offerPrice = _offerPriceController.text.isNotEmpty
        ? double.tryParse(_offerPriceController.text)
        : null;
    final stock = int.tryParse(_stockController.text) ?? 0;

    if (offerPrice != null && offerPrice >= price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer price must be lower than the regular price.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

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
      imageUrl: _existingImageUrl,
    );

    widget.onSave(
      productModel,
      imageBytes: _selectedImageBytes,
      imageName: _selectedImageName,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final categoryItems = {
      ...widget.categories.where((c) => c != 'All categories'),
      _selectedCategory,
    }.toList();
    final supplierItems = {
      ...widget.suppliers.where((s) => s != 'All suppliers'),
      _selectedSupplier,
    }.toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 820),
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
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Product Guidelines & System Rules',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '• SKU must be unique across all products.\n'
                                      '• Offer price must be lower than the regular price.\n'
                                      '• Uploaded product image is stored in Cloudinary and synced with the Android Salesman App.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Image Upload Section
                        const Text('Product Cover Image', style: AppTypography.labelBold),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (_selectedImageBytes != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _selectedImageBytes!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _existingImageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.background,
                                    child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: _pickImageFromBrowser,
                              child: Container(
                                width: 110,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 22),
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedImageName ?? 'Choose Image',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

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
                                label: 'SKU (Unique)',
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
                                    initialValue: _selectedCategory,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: categoryItems
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
                                    initialValue: _selectedSupplier,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: supplierItems
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
                                hintText: '720 (Must be lower than price)',
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
