import 'dart:io';

import 'package:flutter/material.dart';

import '../models/photo.dart';
import '../models/user.dart';
import '../services/photo_service.dart';
import '../widgets/app_theme.dart';

/// صفحة مراجعة الصور المعلقة — خاصة بالمديرة فقط.
class PendingPhotosPage extends StatefulWidget {
  final AppUser user;

  const PendingPhotosPage({
    super.key,
    required this.user,
  });

  @override
  State<PendingPhotosPage> createState() => _PendingPhotosPageState();
}

class _PendingPhotosPageState extends State<PendingPhotosPage> {
  final PhotoService _photoService = PhotoService();

  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final photos = await _photoService.getPendingPhotos();

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
        SnackBar(content: Text('تعذر تحميل الصور المعلقة: $error')),
      );
    }
  }

  Future<void> _approve(Photo photo) async {
    try {
      await _photoService.approvePhoto(
        id: photo.id,
        approvedByUserId: widget.user.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم اعتماد الصورة بنجاح')),
      );

      _loadPending();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الاعتماد: $error')),
      );
    }
  }

  Future<void> _reject(Photo photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('رفض الصورة'),
          content: Text('هل تريدين رفض صورة "${photo.title}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('رفض'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _photoService.rejectPhoto(
        id: photo.id,
        approvedByUserId: widget.user.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض الصورة')),
      );

      _loadPending();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الرفض: $error')),
      );
    }
  }

  Future<void> _delete(Photo photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الصورة'),
          content: Text('هل تريدين حذف صورة "${photo.title}" نهائيًا؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _photoService.deletePhoto(photo.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الصورة')),
      );

      _loadPending();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحذف: $error')),
      );
    }
  }

  Widget _pendingCard(Photo photo) {
    final hasImage =
        photo.localImagePath.isNotEmpty && File(photo.localImagePath).existsSync();

    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: hasImage
                        ? Image.file(File(photo.localImagePath), fit: BoxFit.cover)
                        : Container(
                            color: AppTheme.lightPurple,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported),
                          ),
                  ),
                ),
                SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.title.isEmpty ? 'بدون عنوان' : photo.title,
                        style: AppTheme.headingMedium,
                      ),
                      SizedBox(height: AppTheme.spaceXs),
                      Text('القسم: ${photo.section}', style: AppTheme.caption),
                      Text('بواسطة: ${photo.uploaderName}', style: AppTheme.caption),
                    ],
                  ),
                ),
              ],
            ),
            if (photo.description.isNotEmpty) ...[
              SizedBox(height: AppTheme.spaceSm),
              Text(photo.description, style: AppTheme.bodyText),
            ],
            SizedBox(height: AppTheme.spaceMd),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _approve(photo),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('اعتماد'),
                    style: FilledButton.styleFrom(
                      foregroundColor: AppTheme.statPresent,
                      backgroundColor: AppTheme.statPresent.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => _reject(photo),
                    icon: const Icon(Icons.cancel),
                    label: const Text('رفض'),
                    style: FilledButton.styleFrom(
                      foregroundColor: AppTheme.statAbsent,
                      backgroundColor: AppTheme.statAbsent.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spaceSm),
                IconButton(
                  onPressed: () => _delete(photo),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // حماية إضافية: هذه الصفحة للمديرة فقط، حتى لو تم فتحها بطريقة مباشرة.
    if (!widget.user.isDirector) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('مراجعة الصور المعلقة'),
            backgroundColor: AppTheme.primaryPurple,
            foregroundColor: AppTheme.textOnPrimary,
          ),
          body: const Center(
            child: Text('هذه الصفحة مخصصة للمديرة فقط'),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundSoft,
        appBar: AppBar(
          title: const Text('مراجعة الصور المعلقة'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: AppTheme.textOnPrimary,
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _loadPending,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _photos.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spaceXl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 60,
                            color: AppTheme.textSecondary.withValues(alpha: 0.4),
                          ),
                          SizedBox(height: AppTheme.spaceMd),
                          const Text('لا توجد صور بانتظار المراجعة'),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPending,
                    child: ListView(
                      padding: EdgeInsets.all(AppTheme.spaceLg),
                      children: _photos.map(_pendingCard).toList(),
                    ),
                  ),
      ),
    );
  }
}