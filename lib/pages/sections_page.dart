import 'package:flutter/material.dart';

import '../models/section.dart';
import '../section_service.dart';
import 'add_section_page.dart';

class SectionsPage extends StatefulWidget {
  const SectionsPage({super.key});

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  final SectionService _sectionService = SectionService();

  List<KindergartenSection> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    setState(() {
      _isLoading = true;
    });

    final sections = await _sectionService.getAllSections();

    if (!mounted) return;

    setState(() {
      _sections = sections;
      _isLoading = false;
    });
  }

  Future<void> _openAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSectionPage(),
      ),
    );

    if (result == true) {
      _loadSections();
    }
  }

  Future<void> _openEditPage(KindergartenSection section) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSectionPage(
          sectionToEdit: section,
        ),
      ),
    );

    if (result == true) {
      _loadSections();
    }
  }

  Future<void> _deleteSection(KindergartenSection section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف القسم'),
          content: Text('هل تريد حذف قسم "${section.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _sectionService.deleteSection(section.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف القسم بنجاح'),
      ),
    );

    _loadSections();
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${value.trim().isEmpty ? 'غير محدد' : value}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(KindergartenSection section) {
    final isActive = section.status == 'نشط';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isActive
              ? Colors.deepPurple.shade100
              : Colors.grey.shade300,
          child: Icon(
            Icons.groups,
            color: isActive ? Colors.deepPurple : Colors.grey.shade700,
          ),
        ),
        title: Text(
          section.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${section.ageGroup.isEmpty ? 'الفئة العمرية غير محددة' : section.ageGroup} • الطاقة: ${section.capacity}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          _infoRow(Icons.badge, 'رقم القسم', section.id),
          _infoRow(Icons.groups, 'اسم القسم', section.name),
          _infoRow(Icons.person, 'المعلمة / المشرفة', section.teacherName),
          _infoRow(Icons.child_care, 'الفئة العمرية', section.ageGroup),
          _infoRow(Icons.people, 'الطاقة الاستيعابية', '${section.capacity} طفل'),
          _infoRow(Icons.info_outline, 'الحالة', section.status),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openEditPage(section),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteSection(section),
                  icon: const Icon(Icons.delete),
                  label: const Text('حذف'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأقسام'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _loadSections,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddPage,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة قسم'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _sections.isEmpty
                ? const Center(
                    child: Text(
                      'لا توجد أقسام مسجلة حالياً',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSections,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _sections.length,
                      itemBuilder: (context, index) {
                        return _sectionCard(_sections[index]);
                      },
                    ),
                  ),
      ),
    );
  }
}