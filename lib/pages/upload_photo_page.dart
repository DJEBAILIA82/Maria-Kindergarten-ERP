import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/photo.dart';
import '../models/user.dart';
import '../services/photo_service.dart';
import '../widgets/app_theme.dart';
import 'gallery_page.dart' show kGallerySections;

class UploadPhotoPage extends StatefulWidget {
  final AppUser user;

  const UploadPhotoPage({
    super.key,
    required this.user,
  });

  @override
  State<UploadPhotoPage> createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  final _formKey = GlobalKey<FormState>();
  final PhotoService _photoService = PhotoService();
  final ImagePicker _imagePicker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _imagePath = '';
  String _selectedSection = '';
  bool _isSaving = false;

  bool get _isDirector => widget.user.isDirector;

  @override
  void initState() {
    super.initState();

    // المعلمة: قسمها مضبوط تلقائيًا ولا يمكن تغييره.
    // المديرة: تختار القسم يدويًا من القائمة الرسمية.
    if (!_isDirector && widget.user.section.isNotEmpty) {
      _selectedSection = widget.user.section;
    } else {
      _selectedSection = kGallerySections.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _imagePath = image.path;
    });
  }

  Future<void> _showImageOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('التقاط صورة بالكاميرا'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('اختيار صورة من الهاتف'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة أولًا')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final photo = Photo(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        localImagePath: _imagePath,
        section: _selectedSection,
        uploadedBy: widget.user.id,
        uploaderName: widget.user.fullName,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await _photoService.addPhoto(photo);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء رفع الصورة: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imagePath.isNotEmpty && File(_imagePath).existsSync();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('رفع صورة جديدة'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: AppTheme.textOnPrimary,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppTheme.spaceLg),
            children: [
              Center(
                child: InkWell(
                  onTap: _showImageOptions,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.lightPurple,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasImage
                        ? Image.file(File(_imagePath), fit: BoxFit.cover)
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 42,
                                  color: AppTheme.primaryPurple,
                                ),
                                SizedBox(height: 8),
                                Text('اضغط لاختيار صورة'),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spaceLg),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الصورة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال عنوان للصورة';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppTheme.spaceMd),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppTheme.spaceMd),
              if (_isDirector)
                DropdownButtonFormField<String>(
                  key: ValueKey(_selectedSection),
                  initialValue: _selectedSection,
                  decoration: const InputDecoration(
                    labelText: 'القسم',
                    prefixIcon: Icon(Icons.groups),
                    border: OutlineInputBorder(),
                  ),
                  items: kGallerySections
                      .map(
                        (section) => DropdownMenuItem(
                          value: section,
                          child: Text(section),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedSection = value;
                    });
                  },
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups, color: AppTheme.primaryPurple),
                      SizedBox(width: AppTheme.spaceSm),
                      Text('سيتم رفع الصورة لقسم: $_selectedSection'),
                    ],
                  ),
                ),
              SizedBox(height: AppTheme.spaceLg),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isSaving ? 'جارٍ الرفع...' : 'رفع الصورة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: AppTheme.textOnPrimary,
                  ),
                ),
              ),
              SizedBox(height: AppTheme.spaceMd),
              Text(
                'ملاحظة: لن تظهر الصورة في المعرض العام إلا بعد اعتمادها من قِبل المديرة.',
                style: AppTheme.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}