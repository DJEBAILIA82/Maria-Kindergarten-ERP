import 'package:flutter/material.dart';

import '../models/section.dart';
import '../section_service.dart';

class AddSectionPage extends StatefulWidget {
  final KindergartenSection? sectionToEdit;

  const AddSectionPage({
    super.key,
    this.sectionToEdit,
  });

  @override
  State<AddSectionPage> createState() => _AddSectionPageState();
}

class _AddSectionPageState extends State<AddSectionPage> {
  final _formKey = GlobalKey<FormState>();
  final SectionService _sectionService = SectionService();

  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _ageGroupController = TextEditingController();
  final _capacityController = TextEditingController();

  String _status = 'نشط';
  bool _isSaving = false;

  bool get _isEditing => widget.sectionToEdit != null;

  @override
  void initState() {
    super.initState();

    final section = widget.sectionToEdit;

    if (section != null) {
      _nameController.text = section.name;
      _teacherController.text = section.teacherName;
      _ageGroupController.text = section.ageGroup;
      _capacityController.text = section.capacity.toString();
      _status = section.status.isEmpty ? 'نشط' : section.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _ageGroupController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveSection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final id = _isEditing
          ? widget.sectionToEdit!.id
          : await _sectionService.generateSectionId();

      final section = KindergartenSection(
        id: id,
        name: _nameController.text.trim(),
        teacherName: _teacherController.text.trim(),
        ageGroup: _ageGroupController.text.trim(),
        capacity: int.tryParse(_capacityController.text.trim()) ?? 0,
        status: _status,
      );

      if (_isEditing) {
        await _sectionService.updateSection(section);
      } else {
        await _sectionService.addSection(section);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'تم تعديل القسم بنجاح'
                : 'تمت إضافة القسم بنجاح',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحفظ: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'هذه الخانة مطلوبة';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'تعديل القسم' : 'إضافة قسم'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _textField(
                controller: _nameController,
                label: 'اسم القسم',
                icon: Icons.groups,
                requiredField: true,
              ),
              _textField(
                controller: _teacherController,
                label: 'اسم المعلمة أو المشرفة',
                icon: Icons.person,
              ),
              _textField(
                controller: _ageGroupController,
                label: 'الفئة العمرية',
                icon: Icons.child_care,
              ),
              _textField(
                controller: _capacityController,
                label: 'الطاقة الاستيعابية',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                requiredField: true,
              ),
              DropdownButtonFormField<String>(
                key: ValueKey(_status),
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'نشط',
                    child: Text('نشط'),
                  ),
                  DropdownMenuItem(
                    value: 'متوقف',
                    child: Text('متوقف'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value ?? 'نشط';
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSection,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'جارٍ الحفظ...' : 'حفظ القسم',
                    style: const TextStyle(fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}