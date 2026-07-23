import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../activity_service.dart';

class ActivityDetailsPage extends StatefulWidget {
  final Map<String, dynamic> activity;

  const ActivityDetailsPage({
    super.key,
    required this.activity,
  });

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  final ActivityService _service = ActivityService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _photos = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _loading = true;
    });

    final data = await _service.getPhotos(widget.activity["id"]);

    if (!mounted) return;

    setState(() {
      _photos = data;
      _loading = false;
    });
  }

  Future<void> _takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (file == null) return;

    await _service.addPhoto(
      activityId: widget.activity["id"],
      imagePath: file.path,
    );

    _loadPhotos();
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file == null) return;

    await _service.addPhoto(
      activityId: widget.activity["id"],
      imagePath: file.path,
    );

    _loadPhotos();
  }

  Future<void> _confirmDeletePhoto(Map<String, dynamic> photo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("حذف الصورة؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("حذف"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _service.deletePhoto(photo["id"]);
    _loadPhotos();
  }

  void _openFullImage(Map<String, dynamic> photo) {
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
                child: Image.file(
                  File(photo["imagePath"]),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(dynamic rawDate) {
    if (rawDate == null) return '';

    DateTime? date;

    if (rawDate is DateTime) {
      date = rawDate;
    } else {
      date = DateTime.tryParse(rawDate.toString());
    }

    if (date == null) return rawDate.toString();

    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Widget _infoCard() {
    final title = widget.activity["title"]?.toString() ?? '';
    final description = widget.activity["description"]?.toString() ?? '';
    final section = widget.activity["section"]?.toString() ?? '';
    final date = _formatDate(widget.activity["activityDate"]);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.celebration,
                  color: Colors.deepPurple,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                if (section.isNotEmpty) ...[
                  Chip(
                    avatar: const Icon(Icons.groups, size: 18),
                    label: Text(section),
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.08),
                  ),
                  const SizedBox(width: 8),
                ],
                if (date.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 18),
                    label: Text(date),
                    backgroundColor: Colors.amber.withValues(alpha: 0.15),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  "التقاط صورة",
                  style: TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text(
                  "اختيار من المعرض",
                  style: TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoTile(Map<String, dynamic> photo) {
    return GestureDetector(
      onTap: () => _openFullImage(photo),
      onLongPress: () => _confirmDeletePhoto(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(photo["imagePath"]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              "لا توجد صور لهذا النشاط",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.activity["title"]?.toString() ?? "تفاصيل النشاط"),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadPhotos,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _infoCard(),
                    _actionButtons(),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Text(
                            "معرض الصور",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_photos.isNotEmpty)
                            Text(
                              "(${_photos.length})",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_photos.isEmpty)
                      _emptyState()
                    else
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _photos.length,
                        itemBuilder: (_, index) {
                          return _photoTile(_photos[index]);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}