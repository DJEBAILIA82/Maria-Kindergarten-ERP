/// نموذج بيانات الصورة الخاص بمعرض الصور.
/// يُخزَّن في Firestore، مع الاحتفاظ بمسار الصورة المحلي على الجهاز
/// (بدون استخدام Firebase Storage حاليًا).
class Photo {
  final String id;
  final String title;
  final String description;
  final String localImagePath;
  final String section;
  final String uploadedBy;
  final String uploaderName;
  final DateTime createdAt;

  /// pending / approved / rejected
  final String status;
  final String approvedBy;
  final DateTime? approvedAt;

  Photo({
    required this.id,
    required this.title,
    required this.description,
    required this.localImagePath,
    required this.section,
    required this.uploadedBy,
    required this.uploaderName,
    required this.createdAt,
    this.status = 'pending',
    this.approvedBy = '',
    this.approvedAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'localImagePath': localImagePath,
      'section': section,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }

  factory Photo.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return Photo(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      localImagePath: map['localImagePath'] as String? ?? '',
      section: map['section'] as String? ?? '',
      uploadedBy: map['uploadedBy'] as String? ?? '',
      uploaderName: map['uploaderName'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
      status: map['status'] as String? ?? 'pending',
      approvedBy: map['approvedBy'] as String? ?? '',
      approvedAt: parseNullableDate(map['approvedAt']),
    );
  }

  Photo copyWith({
    String? title,
    String? description,
    String? localImagePath,
    String? section,
    String? status,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return Photo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      localImagePath: localImagePath ?? this.localImagePath,
      section: section ?? this.section,
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      createdAt: createdAt,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}