import 'dart:io';

import 'package:flutter/material.dart';

import '../child_service.dart';
import '../models/child.dart';
import '../models/user.dart';
import '../widgets/app_theme.dart';
import '../widgets/section_title.dart';
import '../widgets/stat_card.dart';
import 'add_child_page.dart';

class ChildrenPage extends StatefulWidget {
  final AppUser user;

  const ChildrenPage({
    super.key,
    required this.user,
  });

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  final ChildService _childService = ChildService();

  List<Child> _children = [];
  bool _isLoading = true;
  String? _expandedChildId;
  String _searchQuery = '';
  String _selectedSection = 'الكل';

  bool get _isDirector => widget.user.isDirector;

  String get _teacherSection => widget.user.section.trim();

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visibleChildren = _isDirector
          ? await _childService.getAllChildren()
          : await _childService.getChildrenBySection(_teacherSection);

      if (!mounted) return;

      setState(() {
        _children = visibleChildren;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _children = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddChildPage() async {
    if (!_isDirector) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddChildPage(),
      ),
    );

    if (result == true) {
      await _loadChildren();
    }
  }

  Future<void> _openEditChildPage(Child child) async {
    if (!_isDirector) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddChildPage(childToEdit: child),
      ),
    );

    if (result == true) {
      await _loadChildren();
    }
  }

  Future<void> _deleteChild(Child child) async {
    if (!_isDirector) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حذف الطفل'),
          content: Text(
            'هل تريد حذف بيانات الطفل ${child.firstName} ${child.lastName}؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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

    await _childService.deleteChild(child.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف الطفل بنجاح'),
      ),
    );

    await _loadChildren();
  }

  int _calculateAge(String birthDate) {
    if (birthDate.isEmpty) return 0;

    try {
      final date = DateTime.parse(birthDate);
      final now = DateTime.now();

      int age = now.year - date.year;

      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }

      return age;
    } catch (_) {
      return 0;
    }
  }

  String _value(String text) {
    return text.trim().isEmpty ? 'غير محدد' : text;
  }

  // ---------------------------------------------------------------------
  // فلترة وبحث — عرض فقط، بدون أي استعلام جديد لقاعدة البيانات
  // ---------------------------------------------------------------------

  // منسوخة حرفيًا من AttendancePage لضمان تطابق سلوك الفلترة 100%.
  String _normalizeSection(String value) {
    return value
        .trim()
        .replaceAll('قسم', '')
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll('ـ', '')
        .replaceAll(' ', '')
        .toLowerCase();
  }

  List<String> get _sectionOptions {
    final sections = <String>{};

    for (final child in _children) {
      final section = child.section.trim();
      if (section.isNotEmpty) sections.add(section);
    }

    final sorted = sections.toList()..sort();
    return ['الكل', ...sorted];
  }

  List<Child> get _filteredChildren {
    final query = _searchQuery.trim().toLowerCase();
    final normalizedSelectedSection = _normalizeSection(_selectedSection);

    return _children.where((child) {
      if (_isDirector &&
          _selectedSection != 'الكل' &&
          _normalizeSection(child.section) != normalizedSelectedSection) {
        return false;
      }

      if (query.isEmpty) return true;

      final fullName = '${child.firstName} ${child.lastName}'.toLowerCase();

      return child.firstName.toLowerCase().contains(query) ||
          child.lastName.toLowerCase().contains(query) ||
          fullName.contains(query);
    }).toList();
  }

  int get _maleCount =>
      _filteredChildren.where((c) => c.gender == 'ذكر').length;

  int get _femaleCount =>
      _filteredChildren.where((c) => c.gender == 'أنثى').length;

  bool get _hasActiveFilter =>
      _searchQuery.trim().isNotEmpty ||
      (_isDirector && _selectedSection != 'الكل');

  String get _emptyStateMessage {
    if (_children.isEmpty) {
      if (_isDirector) {
        return 'لا يوجد أطفال مسجلون حالياً';
      }

      return 'لا يوجد أطفال في قسم $_teacherSection\n'
          'تأكد أن القسم المختار عند إضافة الطفل هو $_teacherSection';
    }

    if (_hasActiveFilter) {
      return 'لا توجد نتائج مطابقة للبحث.';
    }

    return _isDirector
        ? 'لا يوجد أطفال مسجلون حالياً'
        : 'لا يوجد أطفال مسجلون في قسم $_teacherSection';
  }

  // ---------------------------------------------------------------------
  // عناصر الواجهة
  // ---------------------------------------------------------------------

  Widget _statsSection() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.groups,
            value: _filteredChildren.length,
            label: 'إجمالي الأطفال',
            color: AppTheme.statTotal,
          ),
        ),
        SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: StatCard(
            icon: Icons.boy,
            value: _maleCount,
            label: 'ذكور',
            color: AppTheme.statLate,
          ),
        ),
        SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: StatCard(
            icon: Icons.girl,
            value: _femaleCount,
            label: 'إناث',
            color: AppTheme.statAbsent,
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'ابحث بالاسم الأول أو الأخير...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppTheme.surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionFilterDropdown() {
    return DropdownButtonFormField<String>(
      key: ValueKey(_selectedSection),
      initialValue: _selectedSection,
      decoration: InputDecoration(
        labelText: 'تصفية حسب القسم',
        filled: true,
        fillColor: AppTheme.surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          borderSide: BorderSide.none,
        ),
      ),
      items: _sectionOptions.map((section) {
        return DropdownMenuItem(value: section, child: Text(section));
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedSection = value);
      },
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryPurple, size: 20),
          SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              '$title: ${_value(value)}',
              style: AppTheme.bodyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _childAvatar(Child child, bool isFemale) {
    final hasImage =
        child.imagePath.isNotEmpty && File(child.imagePath).existsSync();

    return CircleAvatar(
      radius: 30,
      backgroundColor: isFemale
          ? AppTheme.avatarGirlBackground
          : AppTheme.avatarBoyBackground,
      backgroundImage: hasImage ? FileImage(File(child.imagePath)) : null,
      child: hasImage
          ? null
          : Icon(
              isFemale ? Icons.girl : Icons.boy,
              color: isFemale ? Colors.pink : Colors.blue,
              size: 28,
            ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _childCard(Child child, int index) {
    final age = _calculateAge(child.birthDate);
    final isFemale = child.gender == 'أنثى';
    final isActive = child.status.trim() == 'نشط';

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 25).clamp(0, 250)),
      curve: Curves.easeOut,
      builder: (context, t, cardChild) {
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.95 + (0.05 * t),
            child: cardChild,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.shadowSoft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey<String>(child.id),
            leading: _childAvatar(child, isFemale),
            title: Text(
              '${child.firstName} ${child.lastName}',
              style: AppTheme.headingMedium,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: AppTheme.spaceXs),
              child: Wrap(
                spacing: AppTheme.spaceXs,
                runSpacing: AppTheme.spaceXs,
                children: [
                  _badge(child.section, AppTheme.primaryPurple),
                  _badge('$age سنوات', AppTheme.secondaryTurquoise),
                  _badge(
                    _value(child.status),
                    isActive ? AppTheme.statPresent : AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
            onExpansionChanged: (isExpanded) {
              setState(() {
                _expandedChildId = isExpanded ? child.id : null;
              });
            },
            childrenPadding: EdgeInsets.fromLTRB(
              AppTheme.spaceLg,
              0,
              AppTheme.spaceLg,
              AppTheme.spaceLg,
            ),
            children: [
              Divider(color: AppTheme.textSecondary.withValues(alpha: 0.15)),
              const SectionTitle(title: 'المعلومات الأساسية'),
              SizedBox(height: AppTheme.spaceSm),
              _infoRow(Icons.badge, 'رقم الطفل', child.id),
              _infoRow(
                Icons.person,
                'الاسم واللقب',
                '${child.firstName} ${child.lastName}',
              ),
              _infoRow(Icons.wc, 'الجنس', child.gender),
              _infoRow(Icons.cake, 'تاريخ الميلاد', child.birthDate),
              _infoRow(Icons.groups, 'القسم', child.section),
              _infoRow(Icons.directions_bus, 'النقل المدرسي', child.transport),
              SizedBox(height: AppTheme.spaceMd),
              const SectionTitle(title: 'ولي الأمر'),
              SizedBox(height: AppTheme.spaceSm),
              _infoRow(Icons.man, 'اسم الأب', child.fatherName),
              _infoRow(Icons.person, 'اسم الأم', child.motherName),
              _infoRow(Icons.person_outline, 'ولي الأمر', child.guardian),
              _infoRow(Icons.phone, 'رقم هاتف الولي', child.phone1),
              _infoRow(Icons.phone_android, 'رقم هاتف إضافي', child.phone2),
              _infoRow(Icons.location_on, 'العنوان', child.address),
              SizedBox(height: AppTheme.spaceMd),
              const SectionTitle(title: 'معلومات إضافية'),
              SizedBox(height: AppTheme.spaceSm),
              _infoRow(Icons.medical_information, 'الحساسية', child.allergies),
              _infoRow(Icons.info_outline, 'الحالة', child.status),
              _infoRow(Icons.note_alt, 'الملاحظات', child.notes),
              if (_isDirector) ...[
                SizedBox(height: AppTheme.spaceSm),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _openEditChildPage(child),
                        icon: const Icon(Icons.edit),
                        label: const Text('تعديل'),
                        style: FilledButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                          backgroundColor:
                              AppTheme.primaryPurple.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => _deleteChild(child),
                        icon: const Icon(Icons.delete),
                        label: const Text('حذف'),
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredChildren;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundSoft,
        appBar: AppBar(
          title: Text(
            _isDirector ? 'الأطفال' : 'أطفال قسم $_teacherSection',
          ),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: AppTheme.textOnPrimary,
          actions: [
            IconButton(
              onPressed: _loadChildren,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        floatingActionButton: _isDirector && _expandedChildId == null
            ? FloatingActionButton.extended(
                onPressed: _openAddChildPage,
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: AppTheme.textOnPrimary,
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة طفل'),
              )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadChildren,
                child: ListView(
                  padding: EdgeInsets.all(AppTheme.spaceLg),
                  children: [
                    _statsSection(),
                    SizedBox(height: AppTheme.spaceLg),
                    _searchField(),
                    if (_isDirector) ...[
                      SizedBox(height: AppTheme.spaceMd),
                      _sectionFilterDropdown(),
                    ],
                    SizedBox(height: AppTheme.spaceLg),
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spaceXl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.child_care,
                                size: 70,
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.4),
                              ),
                              SizedBox(height: AppTheme.spaceMd),
                              Text(
                                _emptyStateMessage,
                                textAlign: TextAlign.center,
                                style: AppTheme.headingMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...List.generate(
                        filtered.length,
                        (index) => _childCard(filtered[index], index),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}