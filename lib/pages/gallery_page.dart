import 'dart:io';

import 'package:flutter/material.dart';

import '../models/photo.dart';
import '../models/user.dart';
import '../services/photo_service.dart';
import '../widgets/app_theme.dart';
import 'pending_photos_page.dart';
import 'upload_photo_page.dart';

/// الأقسام الرسمية الوحيدة المعتمدة في التطبيق لهذه الميزة.
/// لا يجوز إضافة أي اسم قسم آخر.
const List<String> kGallerySections = [
  'رضع',
  'تحضيري',
  'تمهيدي',
  'صغير',
  'متوسط',
  'كبير',
];

class GalleryPage extends StatefulWidget {
  final AppUser user;

  const GalleryPage({
    super.key,
    required this.user,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final PhotoService _photoService = PhotoService();

  List<Photo> _photos = [];
  bool _isLoading = true;
  String _selectedSection = 'الكل';

  bool get _isDirector => widget.user.isDirector;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await _photoService.getApprovedPhotos();
      for (final p in photos) {
  debugPrint(
    'PHOTO => title=${p.title} | section="${p.section}" | status=${p.status}',
  );
}

      if (!mounted) return;

      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحميل معرض الصور: $error')),
      );
    }
  }

  List<Photo> get _filteredPhotos {
    if (_selectedSection == 'الكل') return _photos;

    return _photos.where((photo) => photo.section == _selectedSection).toList();
  }

  Future<void> _openUploadPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadPhotoPage(user: widget.user),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع الصورة بنجاح، وهي الآن بانتظار موافقة المديرة'),
        ),
      );
    }
  }

  Future<void> _openPendingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PendingPhotosPage(user: widget.user),
      ),
    );

    _loadPhotos();
  }

  void _openFullImage(Photo photo) {
    final hasImage =
        photo.localImagePath.isNotEmpty && File(photo.localImagePath).existsSync();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              InteractiveViewer(
                child: hasImage
                    ? Image.file(
                        File(photo.localImagePath),
                        fit: BoxFit.contain,
                      )
                    : Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(30),
                        child: const Text(
                          'الصورة غير متوفرة على هذا الجهاز',
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        photo.title.isEmpty ? 'بدون عنوان' : photo.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (photo.description.isNotEmpty)
                        Text(
                          photo.description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'القسم: ${photo.section}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _photoTile(Photo photo) {
    final hasImage =
        photo.localImagePath.isNotEmpty && File(photo.localImagePath).existsSync();

    return GestureDetector(
      onTap: () => _openFullImage(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.shadowSoft,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.file(File(photo.localImagePath), fit: BoxFit.cover)
            : Container(
                color: AppTheme.lightPurple,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppTheme.primaryPurple,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = _filteredPhotos;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundSoft,
        appBar: AppBar(
          title: const Text('معرض الصور'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: AppTheme.textOnPrimary,
          actions: [
            if (_isDirector)
              IconButton(
                onPressed: _openPendingPage,
                icon: const Icon(Icons.pending_actions),
                tooltip: 'الصور المعلقة للمراجعة',
              ),
            IconButton(
              onPressed: _isLoading ? null : _loadPhotos,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openUploadPage,
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: AppTheme.textOnPrimary,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('رفع صورة'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadPhotos,
                child: ListView(
                  padding: EdgeInsets.all(AppTheme.spaceLg),
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSection,
                      decoration: InputDecoration(
                        labelText: 'تصفية حسب القسم',
                        filled: true,
                        fillColor: AppTheme.surfaceWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ['الكل', ...kGallerySections]
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
                    ),
                    SizedBox(height: AppTheme.spaceLg),
                    if (photos.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(AppTheme.spaceXl),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 70,
                                color: AppTheme.textSecondary.withValues(alpha: 0.4),
                              ),
                              SizedBox(height: AppTheme.spaceMd),
                              Text(
                                'لا توجد صور معتمدة بعد',
                                style: AppTheme.headingMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (_, index) => _photoTile(photos[index]),
                      ),
                    SizedBox(height: AppTheme.spaceXl),
                  ],
                ),
              ),
      ),
    );
  }
}