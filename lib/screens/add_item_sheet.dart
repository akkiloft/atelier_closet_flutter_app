import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';
import '../services/background_removal_service.dart';
import '../widgets/garment_visual.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  const AddItemSheet({super.key});

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bgService = BackgroundRemovalService();
  final _picker = ImagePicker();

  ClothingCategory _category = ClothingCategory.tops;
  String? _processedImagePath;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndRemoveBg(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isProcessing = true);
    final cutoutPath = await _bgService.removeBackgroundAndSave(picked.path);
    if (!mounted) return;
    setState(() {
      _processedImagePath = cutoutPath;
      _isProcessing = false;
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    final item = ClothingItem(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      imagePath: _processedImagePath ?? 'icon:custom',
      isAsset: _processedImagePath == null,
      category: _category,
      brand: _brandCtrl.text.trim(),
      purchasePrice: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      purchaseDate: DateTime.now(),
    );

    await ref.read(wardrobeProvider.notifier).addItem(item);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Digitize New Piece',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _pickAndRemoveBg(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _pickAndRemoveBg(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(
                child: Text('Removing background with ML Kit...'),
              ),
            ] else if (_processedImagePath != null) ...[
              const SizedBox(height: 12),
              Center(
                child: GarmentVisual(
                  size: 110,
                  item: ClothingItem(
                    id: 'preview',
                    name: 'Preview',
                    imagePath: _processedImagePath!,
                    isAsset: false,
                    category: _category,
                    purchaseDate: DateTime.now(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Item Name (e.g., Oversized White Linen Shirt)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ClothingCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ClothingCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _brandCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF18181B),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Save to Closet'),
            ),
          ],
        ),
      ),
    );
  }
}
