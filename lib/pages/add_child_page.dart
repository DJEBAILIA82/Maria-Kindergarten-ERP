import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../child_service.dart';
import '../models/child.dart';

class AddChildPage extends StatefulWidget {
  final Child? childToEdit;

  const AddChildPage({
    super.key,
    this.childToEdit,
  });

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final ChildService _childService = ChildService();
  final ImagePicker _imagePicker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _sectionController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _addressController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicalFileController = TextEditingController();
  final _notesController = TextEditingController();

  String _gender = 'ذكر';
  String _transport = 'لا';
  String _imagePath = '';
  bool _isSaving = false;

  bool get _isEditing => widget.childToEdit != null;

  @override
  void initState() {
    super.initState();

    final child = widget.childToEdit;

    if (child != null) {
      _firstNameController.text = child.firstName;
      _lastNameController.text = child.lastName;
      _birthDateController.text = child.birthDate;

      // عند فتح طفل قديم: نُوحّد اسم القسم تلقائيًا حسب تاريخ الميلاد.
      final birthDate = _parseBirthDate(child.birthDate);
      if (birthDate != null) {
        _sectionController.text = _getSectionByAge(birthDate);
      } else {
        _sectionController.text = _normalizeSectionName(child.section);
      }

      _fatherNameController.text = child.fatherName;
      _motherNameController.text = child.motherName;
      _phone1Controller.text = child.phone1;
      _phone2Controller.text = child.phone2;
      _addressController.text = child.address;
      _allergiesController.text = child.allergies;
      _medicalFileController.text = child.medicalFile;
      _notesController.text = child.notes;

      _gender = child.gender.isEmpty ? 'ذكر' : child.gender;
      _transport = child.transport.isEmpty ? 'لا' : child.transport;
      _imagePath = child.imagePath;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _sectionController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _medicalFileController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<String> _generateChildId() async {
    final children = await _childService.getAllChildren();
    final nextNumber = children.length + 1;

    return 'KM-${nextNumber.toString().padLeft(4, '0')}';
  }

  DateTime? _parseBirthDate(String value) {
    try {
      return DateTime.parse(value.trim());
    } catch (_) {
      return null;
    }
  }

  // أسماء الأقسام الرسمية في التطبيق.
  String _getSectionByAge(DateTime birthDate) {
    final now = DateTime.now();

    int ageInMonths =
        (now.year - birthDate.year) * 12 + now.month - birthDate.month;

    if (now.day < birthDate.day) {
      ageInMonths--;
    }

    if (ageInMonths < 24) {
      return 'الرضع';
    }

    if (ageInMonths < 36) {
      return 'قبل التمهيدي';
    }

    if (ageInMonths < 48) {
      return 'التمهيدي';
    }

    return 'التحضيري';
  }

  // لتصحيح أسماء الأقسام القديمة تلقائيًا عند تعديل طفل قديم.
  String _normalizeSectionName(String section) {
    final value = section.trim();

    if (value == 'قسم الرضع' || value == 'الرضع') {
      return 'الرضع';
    }

    if (value == 'قسم قبل التمهيدي' ||
    value == 'قسم ما قبل التمهيدي' ||
    value == 'قبل التمهيدي') {
  return 'قبل التمهيدي';
}

    if (value == 'قسم تمهيدي' || value == 'التمهيدي') {
      return 'التمهيدي';
    }

    if (value == 'قسم تحضيري' || value == 'التحضيري') {
      return 'التحضيري';
    }

    return value;
  }

  Future<void> _selectBirthDate() async {
    final oldDate = _parseBirthDate(_birthDateController.text);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: oldDate ?? DateTime(2022),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() {
      _birthDateController.text =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

      _sectionController.text = _getSectionByAge(selectedDate);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
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
                if (_imagePath.isNotEmpty)
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'حذف الصورة',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);

                      setState(() {
                        _imagePath = '';
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ ميلاد الطفل'),
        ),
      );
      return;
    }

    final birthDate = _parseBirthDate(_birthDateController.text);

    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تاريخ الميلاد غير صحيح'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final childId = _isEditing
          ? widget.childToEdit!.id
          : await _generateChildId();

      // القسم يُحسب دائمًا من العمر ولا يُكتب يدويًا.
      final automaticSection = _getSectionByAge(birthDate);

      final child = Child(
        id: childId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _gender,
        birthDate: _birthDateController.text.trim(),
        section: automaticSection,
        guardian: _fatherNameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        motherName: _motherNameController.text.trim(),
        phone1: _phone1Controller.text.trim(),
        phone2: _phone2Controller.text.trim(),
        address: _addressController.text.trim(),
        transport: _transport,
        allergies: _allergiesController.text.trim(),
        medicalFile: _medicalFileController.text.trim(),
        notes: _notesController.text.trim(),
        username: childId,
        password: _isEditing ? widget.childToEdit!.password : '1234',
        status: _isEditing ? widget.childToEdit!.status : 'نشط',
        imagePath: _imagePath,
      );

      if (_isEditing) {
        await _childService.updateChild(child);
      } else {
        await _childService.addChild(child);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'تم تعديل بيانات الطفل وقسمه: $automaticSection'
                : 'تم حفظ الطفل في قسم: $automaticSection',
          ),
          duration: const Duration(seconds: 4),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool requiredField = false,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
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

  Widget _buildPhotoPicker() {
    final hasImage = _imagePath.isNotEmpty && File(_imagePath).existsSync();

    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: _showImageOptions,
            borderRadius: BorderRadius.circular(70),
            child: CircleAvatar(
              radius: 65,
              backgroundColor: Colors.pink.shade100,
              backgroundImage: hasImage ? FileImage(File(_imagePath)) : null,
              child: hasImage
                  ? null
                  : const Icon(
                      Icons.add_a_photo,
                      size: 42,
                      color: Colors.pink,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showImageOptions,
            icon: const Icon(Icons.photo_camera),
            label: Text(hasImage ? 'تغيير صورة الطفل' : 'إضافة صورة الطفل'),
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
          title: Text(_isEditing ? 'تعديل بيانات الطفل' : 'إضافة طفل'),
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPhotoPicker(),
              const SizedBox(height: 18),
              const Text(
                'معلومات الطفل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _firstNameController,
                label: 'اسم الطفل',
                icon: Icons.child_care,
                requiredField: true,
              ),
              _buildTextField(
                controller: _lastNameController,
                label: 'لقب الطفل',
                icon: Icons.badge,
                requiredField: true,
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'الجنس',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                  DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _gender = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _birthDateController,
                label: 'تاريخ الميلاد',
                icon: Icons.calendar_today,
                requiredField: true,
                readOnly: true,
                onTap: _selectBirthDate,
              ),
              _buildTextField(
                controller: _sectionController,
                label: 'القسم المحدد تلقائيًا حسب العمر',
                icon: Icons.groups,
                readOnly: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'معلومات الأب والأم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fatherNameController,
                label: 'اسم الأب (ولي الأمر)',
                icon: Icons.man,
                requiredField: true,
              ),
              _buildTextField(
                controller: _motherNameController,
                label: 'اسم الأم',
                icon: Icons.woman,
              ),
              _buildTextField(
                controller: _phone1Controller,
                label: 'رقم الهاتف الأساسي',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                requiredField: true,
              ),
              _buildTextField(
                controller: _phone2Controller,
                label: 'رقم هاتف إضافي',
                icon: Icons.phone_android,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'العنوان',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              const Text(
                'معلومات إضافية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _transport,
                decoration: const InputDecoration(
                  labelText: 'النقل المدرسي',
                  prefixIcon: Icon(Icons.directions_bus),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'لا', child: Text('لا')),
                  DropdownMenuItem(value: 'نعم', child: Text('نعم')),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _transport = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _allergiesController,
                label: 'الحساسية أو الأمراض',
                icon: Icons.medical_information,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _medicalFileController,
                label: 'ملاحظات طبية',
                icon: Icons.health_and_safety,
                maxLines: 2,
              ),
              _buildTextField(
                controller: _notesController,
                label: 'ملاحظات إضافية',
                icon: Icons.note_alt,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveChild,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(_isEditing ? Icons.save : Icons.person_add),
                  label: Text(
                    _isSaving
                        ? 'جارٍ الحفظ...'
                        : _isEditing
                            ? 'حفظ التعديلات'
                            : 'حفظ الطفل',
                    style: const TextStyle(fontSize: 17),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}